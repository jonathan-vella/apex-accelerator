#!/usr/bin/env node
/**
 * Workflow Generator Script
 *
 * Generates PNG, SVG, animated GIF, and MP4 from a Mermaid diagram.
 *
 * Usage:
 *   node generate-workflow.js [options]
 *
 * Options:
 *   --png-only   Generate only PNG
 *   --svg-only   Generate only SVG
 *   --gif-only   Generate only GIF (requires PNG first)
 *   --no-zip     Skip ZIP packaging
 */

import { execSync, spawn } from "child_process";
import {
  createWriteStream,
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
  unlinkSync,
  readdirSync,
} from "fs";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";
import archiver from "archiver";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Configuration
const CONFIG = {
  inputFile: join(__dirname, "workflow.mmd"),
  outputDir: join(__dirname, "output"),
  puppeteerConfig: join(__dirname, "puppeteer-config.json"),
  animationDelay: 1200, // ms per node
  gifFrameDelay: 100, // ms between GIF frames
  width: 1200,
  height: 600,
  backgroundColor: "transparent",
  theme: "neutral",
};

// ANSI colors for console output
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  red: "\x1b[31m",
  cyan: "\x1b[36m",
  dim: "\x1b[2m",
};

function log(message, type = "info") {
  const prefix = {
    info: `${colors.blue}ℹ${colors.reset}`,
    success: `${colors.green}✓${colors.reset}`,
    warn: `${colors.yellow}⚠${colors.reset}`,
    error: `${colors.red}✗${colors.reset}`,
    step: `${colors.cyan}→${colors.reset}`,
  };
  console.log(`${prefix[type] || prefix.info} ${message}`);
}

function logSection(title) {
  console.log(`\n${colors.cyan}━━━ ${title} ━━━${colors.reset}\n`);
}

/**
 * Ensure output directory exists
 */
function ensureOutputDir() {
  if (!existsSync(CONFIG.outputDir)) {
    mkdirSync(CONFIG.outputDir, { recursive: true });
    log(`Created output directory: ${CONFIG.outputDir}`, "success");
  }
}

/**
 * Check if required tools are installed
 */
function checkDependencies() {
  logSection("Checking Dependencies");

  // Check for mmdc (Mermaid CLI)
  try {
    execSync("npx mmdc --version", { stdio: "pipe" });
    log("Mermaid CLI (mmdc) available", "success");
  } catch {
    log("Mermaid CLI not found. Installing...", "warn");
    execSync("npm install @mermaid-js/mermaid-cli", { stdio: "inherit" });
  }

  // Check for ffmpeg (for MP4/GIF conversion)
  try {
    execSync("which ffmpeg", { stdio: "pipe" });
    log("FFmpeg available", "success");
    return true;
  } catch {
    log("FFmpeg not found. GIF/MP4 generation will be skipped.", "warn");
    log(
      "Install with: apt-get install ffmpeg (Linux) or brew install ffmpeg (macOS)",
      "warn"
    );
    return false;
  }
}

/**
 * Create Puppeteer configuration for Mermaid CLI
 */
function createPuppeteerConfig() {
  const config = {
    executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || undefined,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
    ],
  };

  writeFileSync(CONFIG.puppeteerConfig, JSON.stringify(config, null, 2));
  log("Created Puppeteer configuration", "success");
}

/**
 * Generate static PNG from Mermaid diagram
 */
async function generatePNG() {
  logSection("Generating PNG");

  const outputFile = join(CONFIG.outputDir, "workflow.png");

  try {
    const cmd = `npx mmdc -i "${CONFIG.inputFile}" -o "${outputFile}" -w ${CONFIG.width} -H ${CONFIG.height} -b transparent -t ${CONFIG.theme} -p "${CONFIG.puppeteerConfig}"`;

    log(`Running: ${colors.dim}${cmd}${colors.reset}`, "step");
    execSync(cmd, { stdio: "inherit" });

    if (existsSync(outputFile)) {
      log(`Generated: ${outputFile}`, "success");
      return outputFile;
    } else {
      throw new Error("PNG file was not created");
    }
  } catch (error) {
    log(`Failed to generate PNG: ${error.message}`, "error");
    throw error;
  }
}

/**
 * Generate static SVG from Mermaid diagram
 */
async function generateSVG() {
  logSection("Generating SVG");

  const outputFile = join(CONFIG.outputDir, "workflow.svg");

  try {
    const cmd = `npx mmdc -i "${CONFIG.inputFile}" -o "${outputFile}" -w ${CONFIG.width} -H ${CONFIG.height} -b transparent -t ${CONFIG.theme} -p "${CONFIG.puppeteerConfig}"`;

    log(`Running: ${colors.dim}${cmd}${colors.reset}`, "step");
    execSync(cmd, { stdio: "inherit" });

    if (existsSync(outputFile)) {
      // Post-process SVG to add animation
      await addSVGAnimation(outputFile);
      log(`Generated: ${outputFile}`, "success");
      return outputFile;
    } else {
      throw new Error("SVG file was not created");
    }
  } catch (error) {
    log(`Failed to generate SVG: ${error.message}`, "error");
    throw error;
  }
}

/**
 * Add CSS animations to SVG for a more dynamic presentation
 */
async function addSVGAnimation(svgPath) {
  let svgContent = readFileSync(svgPath, "utf-8");

  // Add animation styles to SVG
  const animationStyles = `
  <style>
    /* Fade in animation for nodes */
    .node {
      opacity: 0;
      animation: fadeIn 0.8s ease-out forwards;
    }

    /* Stagger animations for each node */
    .node:nth-of-type(1) { animation-delay: 0s; }
    .node:nth-of-type(2) { animation-delay: 0.3s; }
    .node:nth-of-type(3) { animation-delay: 0.6s; }
    .node:nth-of-type(4) { animation-delay: 0.9s; }
    .node:nth-of-type(5) { animation-delay: 1.2s; }
    .node:nth-of-type(6) { animation-delay: 1.5s; }

    /* Draw animation for edges/arrows */
    .edgePath path {
      stroke-dasharray: 1000;
      stroke-dashoffset: 1000;
      animation: drawLine 1.5s ease-out forwards;
      animation-delay: 1.8s;
    }

    /* Pulse animation for optional integrations */
    .edgePath.LS-MCP path,
    .edgePath.LS-D path {
      animation: drawLine 1.5s ease-out forwards, pulse 2s ease-in-out infinite;
      animation-delay: 2.2s, 3.7s;
    }

    @keyframes fadeIn {
      from {
        opacity: 0;
        transform: translateY(10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    @keyframes drawLine {
      to {
        stroke-dashoffset: 0;
      }
    }

    @keyframes pulse {
      0%, 100% {
        opacity: 1;
      }
      50% {
        opacity: 0.6;
      }
    }

    /* Subgraph labels fade in */
    .cluster-label {
      opacity: 0;
      animation: fadeIn 0.5s ease-out forwards;
    }

    .cluster-label:nth-of-type(1) { animation-delay: 0s; }
    .cluster-label:nth-of-type(2) { animation-delay: 0.2s; }
    .cluster-label:nth-of-type(3) { animation-delay: 0.4s; }
    .cluster-label:nth-of-type(4) { animation-delay: 0.6s; }
  </style>`;

  // Insert styles after the opening <svg> tag
  svgContent = svgContent.replace(/<svg([^>]*)>/, `<svg$1>${animationStyles}`);

  writeFileSync(svgPath, svgContent);
  log("Added CSS animations to SVG", "success");
}

/**
 * Generate progressive Mermaid diagrams for animation frames
 */
function getProgressiveMermaidDiagrams() {
  // Each step builds on the previous one to show workflow progression
  return [
    // Frame 1: Empty - just the structure hint
    `%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Step 1: Requirements"
        P["Plan"]
    end

    style P fill:#e1f5fe`,

    // Frame 2: Step 1 complete, arrow appears
    `%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Step 1: Requirements"
        P["Plan"]
    end
    subgraph "Step 2: Architecture"
        A["azure-principal-<br/>architect"]
    end

    P -->|requirements| A

    style P fill:#e1f5fe
    style A fill:#fff3e0`,

    // Frame 3: Architecture with optional integrations
    `%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Step 1: Requirements"
        P["Plan"]
    end
    subgraph "Step 2: Architecture"
        A["azure-principal-<br/>architect"]
        MCP["💰 Azure Pricing<br/>MCP"]
        D["📊 diagram-<br/>generator"]
    end

    P -->|requirements| A

    MCP -.->|"real-time<br/>pricing"| A
    D -.->|"architecture<br/>visualization"| A

    style P fill:#e1f5fe
    style A fill:#fff3e0
    style MCP fill:#fff9c4
    style D fill:#f3e5f5`,

    // Frame 4: Add planning step
    `%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Step 1: Requirements"
        P["Plan"]
    end
    subgraph "Step 2: Architecture"
        A["azure-principal-<br/>architect"]
        MCP["💰 Azure Pricing<br/>MCP"]
        D["📊 diagram-<br/>generator"]
    end
    subgraph "Step 3: Planning"
        B["bicep-plan"]
    end

    P -->|requirements| A
    A --> B

    MCP -.->|"real-time<br/>pricing"| A
    D -.->|"architecture<br/>visualization"| A

    style P fill:#e1f5fe
    style A fill:#fff3e0
    style MCP fill:#fff9c4
    style D fill:#f3e5f5
    style B fill:#e8f5e9`,

    // Frame 5: Complete workflow
    `%%{init: {'theme':'neutral'}}%%
graph LR
    subgraph "Step 1: Requirements"
        P["Plan"]
    end
    subgraph "Step 2: Architecture"
        A["azure-principal-<br/>architect"]
        MCP["💰 Azure Pricing<br/>MCP"]
        D["📊 diagram-<br/>generator"]
    end
    subgraph "Step 3: Planning"
        B["bicep-plan"]
    end
    subgraph "Step 4: Implementation"
        I["bicep-code"]
    end

    P -->|requirements| A
    A --> B
    B -->|plan| I

    MCP -.->|"real-time<br/>pricing"| A
    D -.->|"architecture<br/>visualization"| A

    style P fill:#e1f5fe
    style A fill:#fff3e0
    style MCP fill:#fff9c4
    style D fill:#f3e5f5
    style B fill:#e8f5e9
    style I fill:#fce4ec`,
  ];
}

/**
 * Generate animated frames for GIF/MP4
 */
async function generateAnimatedFrames() {
  logSection("Generating Animation Frames");

  const framesDir = join(CONFIG.outputDir, "frames");
  if (!existsSync(framesDir)) {
    mkdirSync(framesDir, { recursive: true });
  }

  const diagrams = getProgressiveMermaidDiagrams();
  const frames = [];
  let frameIndex = 0;

  // Generate one PNG per step (not duplicates - we'll handle timing in ffmpeg)
  for (let i = 0; i < diagrams.length; i++) {
    const tempMmdFile = join(framesDir, `temp-step-${i}.mmd`);
    const frameFile = join(framesDir, `step-${i}.png`);

    writeFileSync(tempMmdFile, diagrams[i]);

    const cmd = `npx mmdc -i "${tempMmdFile}" -o "${frameFile}" -w ${CONFIG.width} -H ${CONFIG.height} -b white -t ${CONFIG.theme} -p "${CONFIG.puppeteerConfig}"`;

    execSync(cmd, { stdio: "pipe" });
    frames.push(frameFile);

    // Clean up temp mmd file
    unlinkSync(tempMmdFile);
    log(`Generated step ${i + 1}/${diagrams.length}`, "step");
  }

  // Now create numbered frames with proper timing using file copies
  // Each step shows for ~1.5 seconds (3 frames at 2fps)
  const stepDurations = [3, 3, 3, 3, 6]; // frames per step (last step longer)
  let outputFrameIndex = 0;

  for (let step = 0; step < frames.length; step++) {
    const duration = stepDurations[step] || 3;
    for (let j = 0; j < duration; j++) {
      const outputFrame = join(
        framesDir,
        `frame-${String(outputFrameIndex).padStart(3, "0")}.png`
      );
      execSync(`cp "${frames[step]}" "${outputFrame}"`);
      outputFrameIndex++;
    }
  }

  log(`Generated ${outputFrameIndex} animation frames`, "success");
  return framesDir;
}

/**
 * Generate MP4 video from frames
 */
async function generateMP4(framesDir) {
  logSection("Generating MP4");

  const outputFile = join(CONFIG.outputDir, "workflow.mp4");
  const framePattern = join(framesDir, "frame-%03d.png");

  try {
    const cmd = `ffmpeg -y -framerate 2 -i "${framePattern}" -c:v libx264 -pix_fmt yuv420p -vf "scale=${CONFIG.width}:${CONFIG.height}" "${outputFile}"`;

    log(`Running: ${colors.dim}ffmpeg...${colors.reset}`, "step");
    execSync(cmd, { stdio: "pipe" });

    if (existsSync(outputFile)) {
      log(`Generated: ${outputFile}`, "success");
      return outputFile;
    } else {
      throw new Error("MP4 file was not created");
    }
  } catch (error) {
    log(`Failed to generate MP4: ${error.message}`, "error");
    throw error;
  }
}

/**
 * Generate GIF from MP4 or frames
 */
async function generateGIF(framesDir) {
  logSection("Generating GIF");

  const outputFile = join(CONFIG.outputDir, "workflow.gif");
  const framePattern = join(framesDir, "frame-%03d.png");
  const paletteFile = join(CONFIG.outputDir, "palette.png");

  try {
    // Two-pass encoding for better GIF quality
    // Pass 1: Generate palette
    log("Pass 1: Generating color palette...", "step");
    execSync(
      `ffmpeg -y -framerate 2 -i "${framePattern}" -vf "fps=10,scale=${CONFIG.width}:-1:flags=lanczos,palettegen=stats_mode=diff" "${paletteFile}"`,
      { stdio: "pipe" }
    );

    // Pass 2: Generate GIF using palette
    log("Pass 2: Creating GIF with optimized palette...", "step");
    execSync(
      `ffmpeg -y -framerate 2 -i "${framePattern}" -i "${paletteFile}" -lavfi "fps=10,scale=${CONFIG.width}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" "${outputFile}"`,
      { stdio: "pipe" }
    );

    // Clean up palette file
    if (existsSync(paletteFile)) {
      unlinkSync(paletteFile);
    }

    if (existsSync(outputFile)) {
      log(`Generated: ${outputFile}`, "success");
      return outputFile;
    } else {
      throw new Error("GIF file was not created");
    }
  } catch (error) {
    log(`Failed to generate GIF: ${error.message}`, "error");
    throw error;
  }
}

/**
 * Create a simpler animated GIF directly from static image
 * This is a fallback when frame-by-frame animation is not needed
 */
async function generateSimpleGIF() {
  logSection("Generating Simple GIF");

  const pngFile = join(CONFIG.outputDir, "workflow.png");
  const outputFile = join(CONFIG.outputDir, "workflow.gif");

  if (!existsSync(pngFile)) {
    log("PNG file not found. Generate PNG first.", "error");
    return null;
  }

  try {
    // Convert PNG to GIF with a simple fade effect
    const cmd = `ffmpeg -y -loop 1 -i "${pngFile}" -t 3 -vf "fade=t=in:st=0:d=1,fade=t=out:st=2:d=1" "${outputFile}"`;

    log(`Running: ${colors.dim}ffmpeg...${colors.reset}`, "step");
    execSync(cmd, { stdio: "pipe" });

    if (existsSync(outputFile)) {
      log(`Generated: ${outputFile}`, "success");
      return outputFile;
    }
  } catch (error) {
    log(`Failed to generate simple GIF: ${error.message}`, "error");
  }

  return null;
}

/**
 * Package all outputs into a ZIP file
 */
async function createZipPackage() {
  logSection("Creating ZIP Package");

  const outputFile = join(CONFIG.outputDir, "workflow-package.zip");
  const output = createWriteStream(outputFile);
  const archive = archiver("zip", { zlib: { level: 9 } });

  return new Promise((resolve, reject) => {
    output.on("close", () => {
      log(
        `Created: ${outputFile} (${(archive.pointer() / 1024).toFixed(1)} KB)`,
        "success"
      );
      resolve(outputFile);
    });

    archive.on("error", (err) => {
      log(`Failed to create ZIP: ${err.message}`, "error");
      reject(err);
    });

    archive.pipe(output);

    // Add all generated files
    const files = [
      "workflow.png",
      "workflow.svg",
      "workflow.gif",
      "workflow.mp4",
    ];
    for (const file of files) {
      const filePath = join(CONFIG.outputDir, file);
      if (existsSync(filePath)) {
        archive.file(filePath, { name: file });
        log(`Added to ZIP: ${file}`, "step");
      }
    }

    archive.finalize();
  });
}

/**
 * Clean up temporary files
 */
function cleanup() {
  const framesDir = join(CONFIG.outputDir, "frames");
  if (existsSync(framesDir)) {
    execSync(`rm -rf "${framesDir}"`);
    log("Cleaned up temporary frames", "success");
  }
}

/**
 * Main execution
 */
async function main() {
  console.log(`
${colors.cyan}╔═══════════════════════════════════════════════════════════╗
║           Workflow Diagram Generator                       ║
║       PNG • SVG • GIF • MP4 • ZIP Package                  ║
╚═══════════════════════════════════════════════════════════╝${colors.reset}
`);

  const args = process.argv.slice(2);
  const pngOnly = args.includes("--png-only");
  const svgOnly = args.includes("--svg-only");
  const gifOnly = args.includes("--gif-only");
  const noZip = args.includes("--no-zip");

  try {
    // Ensure output directory exists
    ensureOutputDir();

    // Check dependencies
    const hasFFmpeg = checkDependencies();

    // Create Puppeteer config
    createPuppeteerConfig();

    // Check if input file exists
    if (!existsSync(CONFIG.inputFile)) {
      log(`Input file not found: ${CONFIG.inputFile}`, "error");
      process.exit(1);
    }

    log(`Input: ${CONFIG.inputFile}`, "info");

    // Generate outputs based on flags
    if (pngOnly) {
      await generatePNG();
    } else if (svgOnly) {
      await generateSVG();
    } else if (gifOnly) {
      if (hasFFmpeg) {
        const framesDir = await generateAnimatedFrames();
        await generateGIF(framesDir);
        cleanup();
      } else {
        log("FFmpeg required for GIF generation", "error");
      }
    } else {
      // Generate all outputs
      await generatePNG();
      await generateSVG();

      if (hasFFmpeg) {
        const framesDir = await generateAnimatedFrames();
        await generateMP4(framesDir);
        await generateGIF(framesDir);
        cleanup();
      } else {
        log("Skipping MP4/GIF generation (FFmpeg not available)", "warn");
      }

      if (!noZip) {
        await createZipPackage();
      }
    }

    logSection("Complete!");
    log(`Output directory: ${CONFIG.outputDir}`, "success");

    // List generated files
    const files = readdirSync(CONFIG.outputDir).filter(
      (f) => !f.startsWith(".")
    );
    log(`Generated files: ${files.join(", ")}`, "info");
  } catch (error) {
    log(`Generation failed: ${error.message}`, "error");
    console.error(error);
    process.exit(1);
  }
}

main();
