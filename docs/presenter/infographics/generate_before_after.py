#!/usr/bin/env python3
"""
GitHub Copilot for IT Pros - Before/After Comparison Poster Generator

This script generates a professional side-by-side comparison poster
showing the transformation when IT Pros adopt GitHub Copilot.

Requirements:
    pip install matplotlib numpy pillow

Usage:
    python generate_before_after.py

Output:
    - before-after-poster.png (high-res for print)
    - before-after-poster-web.png (optimized for web)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Rectangle
import numpy as np
from pathlib import Path

# Color palette
COLORS = {
    'primary': '#0078D4',      # Azure blue
    'secondary': '#50E6FF',    # Light azure
    'accent': '#00B294',       # Teal
    'success': '#107C10',      # Green
    'danger': '#D13438',       # Red
    'warning': '#FFB900',      # Yellow
    'dark': '#201F1E',         # Near black
    'light': '#F3F2F1',        # Light gray
    'white': '#FFFFFF',
    'before_bg': '#FFF4F4',    # Light red tint
    'after_bg': '#F0FFF4',     # Light green tint
}


def draw_workflow_icon(ax, x, y, icon_type, color):
    """Draw simple workflow icons."""
    if icon_type == 'search':
        # Magnifying glass
        circle = Circle((x, y), 0.15, facecolor='none', edgecolor=color, linewidth=2)
        ax.add_patch(circle)
        ax.plot([x + 0.1, x + 0.25], [y - 0.1, y - 0.25], color=color, linewidth=2)
    elif icon_type == 'code':
        # Code brackets
        ax.text(x, y, '</>', fontsize=12, fontweight='bold', color=color,
                ha='center', va='center', fontfamily='monospace')
    elif icon_type == 'debug':
        # Bug icon (simple)
        ax.text(x, y, '🐛', fontsize=14, ha='center', va='center')
    elif icon_type == 'doc':
        # Document
        ax.text(x, y, '📄', fontsize=14, ha='center', va='center')
    elif icon_type == 'check':
        # Checkmark
        ax.text(x, y, '✓', fontsize=16, fontweight='bold', color=color,
                ha='center', va='center')
    elif icon_type == 'x':
        # X mark
        ax.text(x, y, '✗', fontsize=16, fontweight='bold', color=color,
                ha='center', va='center')
    elif icon_type == 'clock':
        ax.text(x, y, '⏱️', fontsize=14, ha='center', va='center')
    elif icon_type == 'rocket':
        ax.text(x, y, '🚀', fontsize=14, ha='center', va='center')
    elif icon_type == 'brain':
        ax.text(x, y, '🧠', fontsize=14, ha='center', va='center')
    elif icon_type == 'copilot':
        ax.text(x, y, '🤖', fontsize=14, ha='center', va='center')


def create_before_after_poster():
    """Generate the before/after comparison poster."""
    
    # Create figure (landscape orientation for poster)
    fig = plt.figure(figsize=(20, 12), facecolor=COLORS['white'])
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # === HEADER ===
    header_bg = FancyBboxPatch(
        (0, 10.5), 20, 1.5,
        boxstyle="square,pad=0",
        facecolor=COLORS['primary'],
        edgecolor='none'
    )
    ax.add_patch(header_bg)
    
    ax.text(10, 11.5, 'The IT Pro Transformation', 
            fontsize=32, fontweight='bold', color=COLORS['white'],
            ha='center', va='center')
    ax.text(10, 10.9, 'How GitHub Copilot Changes Infrastructure Development', 
            fontsize=16, color=COLORS['secondary'],
            ha='center', va='center')
    
    # === BEFORE SECTION (Left) ===
    before_bg = FancyBboxPatch(
        (0.3, 1.5), 9.2, 8.7,
        boxstyle="round,pad=0.05,rounding_size=0.2",
        facecolor=COLORS['before_bg'],
        edgecolor=COLORS['danger'],
        linewidth=3
    )
    ax.add_patch(before_bg)
    
    ax.text(4.9, 9.7, '❌  BEFORE COPILOT', 
            fontsize=20, fontweight='bold', color=COLORS['danger'],
            ha='center', va='center')
    
    # Before workflow steps
    before_steps = [
        ('1', 'Research Documentation', '15-30 min', 'Searching Azure docs, Stack Overflow'),
        ('2', 'Find & Adapt Examples', '20-40 min', 'Copy-paste, trial and error'),
        ('3', 'Write Infrastructure Code', '30-60 min', 'Manual Bicep/Terraform authoring'),
        ('4', 'Debug Deployment Errors', '15-45 min', 'Cryptic error messages'),
        ('5', 'Add Security Controls', '20-30 min', 'Often forgotten or incomplete'),
        ('6', 'Write Documentation', '30-60 min', 'Usually skipped or outdated'),
    ]
    
    y_pos = 8.8
    for step_num, title, time, desc in before_steps:
        # Step circle
        circle = Circle((1.2, y_pos), 0.25, facecolor=COLORS['danger'], edgecolor='none')
        ax.add_patch(circle)
        ax.text(1.2, y_pos, step_num, fontsize=11, fontweight='bold', 
                color=COLORS['white'], ha='center', va='center')
        
        # Step content
        ax.text(1.7, y_pos + 0.1, title, fontsize=11, fontweight='bold',
                color=COLORS['dark'], va='center')
        ax.text(1.7, y_pos - 0.25, desc, fontsize=9, color=COLORS['dark'],
                va='center', style='italic')
        
        # Time badge
        time_bg = FancyBboxPatch(
            (7.5, y_pos - 0.15), 1.7, 0.35,
            boxstyle="round,pad=0.02,rounding_size=0.1",
            facecolor=COLORS['danger'],
            edgecolor='none',
            alpha=0.8
        )
        ax.add_patch(time_bg)
        ax.text(8.35, y_pos + 0.02, time, fontsize=9, fontweight='bold',
                color=COLORS['white'], ha='center', va='center')
        
        y_pos -= 1.1
    
    # Before totals
    ax.text(4.9, 2.3, 'TOTAL: 2-4 hours per task', 
            fontsize=14, fontweight='bold', color=COLORS['danger'],
            ha='center', va='center')
    ax.text(4.9, 1.9, '😫 Frustrating  •  🔄 Repetitive  •  📉 Error-prone', 
            fontsize=10, color=COLORS['dark'],
            ha='center', va='center')
    
    # === CENTER ARROW ===
    arrow = FancyArrowPatch(
        (9.7, 5.5), (10.3, 5.5),
        arrowstyle='->,head_length=0.3,head_width=0.2',
        connectionstyle='arc3,rad=0',
        color=COLORS['primary'],
        linewidth=4
    )
    ax.add_patch(arrow)
    
    ax.text(10, 6.2, 'GitHub', fontsize=12, fontweight='bold',
            color=COLORS['primary'], ha='center', va='center')
    ax.text(10, 5.8, 'Copilot', fontsize=12, fontweight='bold',
            color=COLORS['primary'], ha='center', va='center')
    
    # === AFTER SECTION (Right) ===
    after_bg = FancyBboxPatch(
        (10.5, 1.5), 9.2, 8.7,
        boxstyle="round,pad=0.05,rounding_size=0.2",
        facecolor=COLORS['after_bg'],
        edgecolor=COLORS['success'],
        linewidth=3
    )
    ax.add_patch(after_bg)
    
    ax.text(15.1, 9.7, '✅  WITH COPILOT', 
            fontsize=20, fontweight='bold', color=COLORS['success'],
            ha='center', va='center')
    
    # After workflow steps
    after_steps = [
        ('1', 'Describe Your Intent', '2 min', 'Natural language prompt'),
        ('2', 'Review AI Suggestions', '3 min', 'Context-aware code generation'),
        ('3', 'Refine & Customize', '5 min', 'Iterative improvement'),
        ('4', 'Validate & Deploy', '5 min', 'Built-in best practices'),
    ]
    
    y_pos = 8.8
    for step_num, title, time, desc in after_steps:
        # Step circle
        circle = Circle((11.4, y_pos), 0.25, facecolor=COLORS['success'], edgecolor='none')
        ax.add_patch(circle)
        ax.text(11.4, y_pos, step_num, fontsize=11, fontweight='bold', 
                color=COLORS['white'], ha='center', va='center')
        
        # Step content
        ax.text(11.9, y_pos + 0.1, title, fontsize=11, fontweight='bold',
                color=COLORS['dark'], va='center')
        ax.text(11.9, y_pos - 0.25, desc, fontsize=9, color=COLORS['dark'],
                va='center', style='italic')
        
        # Time badge
        time_bg = FancyBboxPatch(
            (17.7, y_pos - 0.15), 1.5, 0.35,
            boxstyle="round,pad=0.02,rounding_size=0.1",
            facecolor=COLORS['success'],
            edgecolor='none'
        )
        ax.add_patch(time_bg)
        ax.text(18.45, y_pos + 0.02, time, fontsize=9, fontweight='bold',
                color=COLORS['white'], ha='center', va='center')
        
        y_pos -= 1.1
    
    # Benefits section
    y_pos = 4.8
    benefits = [
        ('🔒', 'Security Built-In', 'Best practices by default'),
        ('📝', 'Auto-Documentation', 'Generated as you code'),
        ('🎯', 'Consistent Quality', 'Follows your patterns'),
    ]
    
    for emoji, title, desc in benefits:
        ax.text(11.4, y_pos, emoji, fontsize=14, ha='center', va='center')
        ax.text(11.9, y_pos, f'{title}: {desc}', fontsize=10,
                color=COLORS['dark'], va='center')
        y_pos -= 0.6
    
    # After totals
    ax.text(15.1, 2.3, 'TOTAL: 15-20 minutes per task', 
            fontsize=14, fontweight='bold', color=COLORS['success'],
            ha='center', va='center')
    ax.text(15.1, 1.9, '🚀 Fast  •  ✨ Consistent  •  🛡️ Secure', 
            fontsize=10, color=COLORS['dark'],
            ha='center', va='center')
    
    # === BOTTOM STATS BAR ===
    stats_bg = FancyBboxPatch(
        (0, 0), 20, 1.3,
        boxstyle="square,pad=0",
        facecolor=COLORS['dark'],
        edgecolor='none'
    )
    ax.add_patch(stats_bg)
    
    # Stats
    stats = [
        ('78%', 'Time Saved', 'on IaC development'),
        ('83%', 'Faster', 'documentation'),
        ('10+', 'Hours/Week', 'recovered per IT Pro'),
        ('Week 1', 'Break-Even', 'on investment'),
    ]
    
    x_positions = [2.5, 7.5, 12.5, 17.5]
    for i, (value, label, sublabel) in enumerate(stats):
        x = x_positions[i]
        ax.text(x, 0.85, value, fontsize=24, fontweight='bold',
                color=COLORS['secondary'], ha='center', va='center')
        ax.text(x, 0.45, label, fontsize=11, fontweight='bold',
                color=COLORS['white'], ha='center', va='center')
        ax.text(x, 0.18, sublabel, fontsize=9,
                color=COLORS['light'], ha='center', va='center')
    
    return fig


def save_poster(fig, output_dir: Path):
    """Save the poster in multiple formats."""
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # High-res for print
    print_path = output_dir / 'before-after-poster.png'
    fig.savefig(print_path, dpi=300, bbox_inches='tight',
                facecolor=COLORS['white'], edgecolor='none')
    print(f"✅ Saved print version: {print_path}")
    
    # Web-optimized
    web_path = output_dir / 'before-after-poster-web.png'
    fig.savefig(web_path, dpi=150, bbox_inches='tight',
                facecolor=COLORS['white'], edgecolor='none')
    print(f"✅ Saved web version: {web_path}")
    
    # PDF
    pdf_path = output_dir / 'before-after-poster.pdf'
    fig.savefig(pdf_path, format='pdf', bbox_inches='tight',
                facecolor=COLORS['white'], edgecolor='none')
    print(f"✅ Saved PDF version: {pdf_path}")


def main():
    """Main entry point."""
    print("🎨 Generating Before/After Comparison Poster...")
    print("-" * 50)
    
    script_dir = Path(__file__).parent
    output_dir = script_dir / 'generated'
    
    fig = create_before_after_poster()
    save_poster(fig, output_dir)
    
    print("-" * 50)
    print("✨ Poster generation complete!")
    print(f"📁 Output directory: {output_dir}")
    
    plt.close(fig)


if __name__ == '__main__':
    main()
