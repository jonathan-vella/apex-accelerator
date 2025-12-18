#!/usr/bin/env python3
"""
Executive Pitch Banner Generator

Creates a compact banner for the executive pitch page.

Requirements:
    pip install matplotlib numpy pillow

Usage:
    python generate_exec_banner.py
"""

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from pathlib import Path

# Color palette
COLORS = {
    'primary': '#0078D4',
    'secondary': '#50E6FF',
    'success': '#107C10',
    'dark': '#201F1E',
    'white': '#FFFFFF',
}


def create_banner():
    """Generate a compact executive pitch banner."""
    
    # Wide and short banner format
    fig = plt.figure(figsize=(12, 2), facecolor=COLORS['primary'])
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 2)
    ax.axis('off')
    ax.set_facecolor(COLORS['primary'])
    
    # Main message
    ax.text(0.5, 1.0, '78%', fontsize=42, fontweight='bold',
            color=COLORS['white'], va='center')
    
    ax.text(2.2, 1.15, 'Time Saved on Infrastructure Tasks', 
            fontsize=16, fontweight='bold', color=COLORS['white'], va='center')
    ax.text(2.2, 0.7, 'Backed by Stanford, Forrester, MIT & McKinsey research', 
            fontsize=11, color=COLORS['secondary'], va='center')
    
    # Divider
    ax.plot([8.2, 8.2], [0.4, 1.6], color=COLORS['secondary'], linewidth=1, alpha=0.5)
    
    # Key stats on right
    stats = [
        ('$19/user/mo', 'Investment'),
        ('Week 1', 'Break-even'),
    ]
    
    x_positions = [9.2, 11]
    for i, (value, label) in enumerate(stats):
        x = x_positions[i]
        ax.text(x, 1.15, value, fontsize=14, fontweight='bold',
                color=COLORS['white'], ha='center', va='center')
        ax.text(x, 0.7, label, fontsize=9,
                color=COLORS['secondary'], ha='center', va='center')
    
    return fig


def save_banner(fig, output_dir: Path):
    """Save the banner."""
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Web-optimized only (banners don't need high-res print)
    web_path = output_dir / 'exec-pitch-banner.png'
    fig.savefig(web_path, dpi=150, bbox_inches='tight',
                facecolor=COLORS['primary'], edgecolor='none')
    print(f"✅ Saved: {web_path}")


def main():
    print("🎨 Generating Executive Pitch Banner...")
    
    script_dir = Path(__file__).parent
    output_dir = script_dir / 'generated'
    
    fig = create_banner()
    save_banner(fig, output_dir)
    
    print("✨ Complete!")
    plt.close(fig)


if __name__ == '__main__':
    main()
