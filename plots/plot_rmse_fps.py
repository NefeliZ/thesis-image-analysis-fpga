import matplotlib.pyplot as plt
import numpy as np
import matplotlib.lines as mlines
import matplotlib.patches as mpatches

categories = [
    'Sobel 3x3 Integer', 'Sobel 3x3 IEEE', 'Gauss 3x3 Integer', 'Gauss 3x3 IEEE',  'Cascaded 3x3 Integer', 'Cascaded 3x3 IEEE',
    'Sobel 5x5 Integer', 'Sobel 5x5 IEEE', 'Gauss 5x5 Integer', 'Gauss 5x5 IEEE',  'Cascaded 5x5 Integer', 'Cascaded 5x5 IEEE'
]

colors = ['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']

color_dict = {
    'Sobel': colors[4],     # Blue
    'Gauss': colors[7],     # Magenta/Purple
    'Cascaded': colors[8]   # Green
}

# ==============================================================================
# PLOT 4: LUT Count vs Root Mean Squared Error (RMSE)
# ==============================================================================

# RMSE values in grayscale intensity units (LSB)
RMSE = [
    0.0, 0.0, 1.396180868, 0.086517446, 1.19404304, 0.009539722, 
    0.0, 0.0, 0.752312362, 0.009833321, 0.870081365, 0.002384931
]

LUT_count = [
    2340, 10025, 2316, 7864, 4721, 23008,
    4677, 32232, 4544, 21200, 9028, 59267
]

fig, ax = plt.subplots(figsize=(12, 7), dpi=150)

# Set up log scale for RMSE (ranges from ~1.40 down to ~0.0024 LSB)
ax.set_yscale('log')

# Floor threshold to cleanly anchor the exact zero values (Sobel)
ZERO_FLOOR = 1e-4

for i in range(len(categories)):
    title = categories[i]
    flt, win, arch = title.split()

    c = color_dict[flt]

    # Marker based on window size
    if win == '3x3':
        m = 'D'
        sm = 200
        z = 4
    else:  # 5x5
        m = 's'
        sm = 200
        z = 5

    # Fill based on architecture
    f = c if arch == 'Integer' else '#FFFFFF'

    # Handle true 0.0 values by placing them at the visual baseline
    val = RMSE[i]
    is_exact_zero = (val == 0.0)
    y_plot = ZERO_FLOOR if is_exact_zero else val

    ax.scatter(LUT_count[i], y_plot, color=c, marker=m, facecolors=f, 
               edgecolors=c, s=sm, linewidths=1.6, zorder=z)

# Demarcation line for exact zero (bit-identical verification)
ax.axhline(ZERO_FLOOR, color='black', linestyle=':', linewidth=1.2, alpha=0.7, zorder=2)
ax.text(62000, ZERO_FLOOR * 1.5, 'RMSE = 0.0', color='black', 
        fontsize=9.5, fontweight='bold', ha='right', va='bottom')

# Axes limits and labels
ax.set_xlim(-1000, 65000)
ax.set_ylim(3e-5, 3.0)

ax.set_xlabel("Hardware Complexity (Total LUT Count)", fontsize=11, fontweight='bold', labelpad=8)
ax.set_ylabel("Root Mean Squared Error (RMSE) (Log Scale)", fontsize=11, fontweight='bold', labelpad=8)
ax.grid(True, which="both", linestyle='--', alpha=0.45, zorder=0)

# Structured Legend
legend_elements = [
    # Filters
    mlines.Line2D([], [], color="white", marker="o", markerfacecolor=color_dict['Sobel'],
                  markeredgecolor=color_dict['Sobel'], markersize=8.5, label="Sobel"),
    mlines.Line2D([], [], color="white", marker="o", markerfacecolor=color_dict['Gauss'],
                  markeredgecolor=color_dict['Gauss'], markersize=8.5, label="Gaussian"),
    mlines.Line2D([], [], color="white", marker="o", markerfacecolor=color_dict['Cascaded'],
                  markeredgecolor=color_dict['Cascaded'], markersize=8.5, label="Cascaded"),
    # Window sizes
    mlines.Line2D([], [], color="white", marker="D", markerfacecolor="gray",
                  markeredgecolor="gray", markersize=8.5, label="3x3 Window"),
    mlines.Line2D([], [], color="white", marker="s", markerfacecolor="gray",
                  markeredgecolor="gray", markersize=8.5, label="5x5 Window"),
    # Architectures
    mlines.Line2D([], [], color="white", marker="o", markerfacecolor="gray",
                  markeredgecolor="gray", markersize=8.5, label="Integer (Shift)"),
    mlines.Line2D([], [], color="white", marker="o", markerfacecolor="white",
                  markeredgecolor="gray", markersize=8.5, label="IEEE-754 (Float)")
]

ax.legend(
    handles=legend_elements,
    loc="upper right",
    ncol=3,
    fontsize=9.5,
    frameon=True,
    facecolor="#f9f9f9",
    framealpha=0.95
)

fig.suptitle("Hardware Cost vs Image Accuracy (LUT Count vs RMSE)", 
             fontsize=14, fontweight='bold', y=0.98)

plt.tight_layout()
plt.subplots_adjust(top=0.91)
plt.show()


# ==============================================================================
# PLOT 6: FPS by Case
# ==============================================================================

categories_fps = [
    'Sobel 3x3 Integer', 'Sobel 3x3 IEEE', 'Sobel 5x5 Integer', 'Sobel 5x5 IEEE',
    'Gauss 3x3 Integer', 'Gauss 3x3 IEEE', 'Gauss 5x5 Integer', 'Gauss 5x5 IEEE',  
    'Cascaded 3x3 Integer', 'Cascaded 3x3 IEEE', 'Cascaded 5x5 Integer', 'Cascaded 5x5 IEEE'
]

FPS = [
    378.1073875, 293.2327847, 299.8117604, 284.7320817, 
    434.8453852, 366.6077722, 385.0259917, 348.1617999, 
    423.316471, 294.7413744,  313.9384282, 257.3771789
]



color_dict_fps = {
    'Sobel': colors[0],  
    'Gauss': colors[1],  
    'Cascaded': colors[2]
}

x = np.arange(len(categories_fps))
width = 0.60

fig2, ax2 = plt.subplots(figsize=(12, 6.5), dpi=150)
bars = []

for i in range(len(categories_fps)):
    title = categories_fps[i]
    flt, win, arch = title.split()

    c = color_dict_fps[flt]

    if arch == 'Integer':
        ec = c
        h = ''
    else:
        ec = c
        c = '#FFFFFF'
        h = '//'

    bar = ax2.bar(x[i], FPS[i], width, color=c, edgecolor=ec, hatch=h, 
                  linewidth=1.5, zorder=3, label=title)
    bars.append(bar[0])

# Bar annotations (Font: 9.5pt bold)
for bar in bars:
    height = bar.get_height()
    ax2.annotate(f'{height:.1f}',
                 xy=(bar.get_x() + bar.get_width() / 2, height),
                 xytext=(0, 3),
                 textcoords="offset points",
                 ha='center', va='bottom', fontsize=9.5, fontweight='bold')

# Standard target framerate lines
ax2.axhline(60, color='gray', linestyle='--', linewidth=1, alpha=0.7, zorder=2)
ax2.text(len(categories_fps) - 0.5, 63, '60 FPS Target', color='gray', fontsize=9, ha='right', fontweight='medium')

ax2.axhline(120, color='gray', linestyle='--', linewidth=1, alpha=0.7, zorder=2)
ax2.text(len(categories_fps) - 0.5, 123, '120 FPS Target', color='gray', fontsize=9, ha='right', fontweight='medium')

ax2.set_ylim(0, max(FPS) * 1.18)
ax2.set_ylabel('Frame Rate (FPS)', fontsize=11, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(categories_fps, fontsize=9.5, rotation=35, ha='right', fontweight='medium')
ax2.grid(axis='y', linestyle='--', alpha=0.4, zorder=0)

# Group dividers
div1 = 3.5
div2 = 7.5
ax2.axvline(div1, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)
ax2.axvline(div2, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)

legend_patches = [
    mpatches.Patch(facecolor=color_dict_fps['Sobel'], edgecolor=color_dict_fps['Sobel'], label='Sobel'),
    mpatches.Patch(facecolor=color_dict_fps['Gauss'], edgecolor=color_dict_fps['Gauss'], label='Gaussian'),
    mpatches.Patch(facecolor=color_dict_fps['Cascaded'], edgecolor=color_dict_fps['Cascaded'], label='Cascaded'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]
ax2.legend(handles=legend_patches, loc='upper right', ncol=2, fontsize=10, bbox_to_anchor=(1, 1.1), framealpha=0.95)

fig2.suptitle('Achieved Frame Rate (FPS)', 
              fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout()
plt.subplots_adjust(top=0.90, bottom=0.18)
plt.show()