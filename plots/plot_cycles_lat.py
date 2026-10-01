import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np

# 12 Filter Implementations in standard presentation order
categories = [
    'Sobel 3x3 Int', 'Sobel 3x3 IEEE', 'Sobel 5x5 Int', 'Sobel 5x5 IEEE',
    'Gauss 3x3 Int', 'Gauss 3x3 IEEE', 'Gauss 5x5 Int', 'Gauss 5x5 IEEE',
    'Cascaded 3x3 Int', 'Cascaded 3x3 IEEE', 'Cascaded 5x5 Int', 'Cascaded 5x5 IEEE'
]

colors = ['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']

# Total execution cycles
total_cycles = np.array([
    177512, 177516, 179218, 179224,   # sobel
    177512, 177516, 179218, 179223,   # gauss
    179220, 179229, 182656, 182668    # cascade
])

# Initial buffer warm-up / pipeline latency cycles before valid pixel_out starts
initial_latency = np.array([
    737, 741, 1479, 1485,   # sobel
    737, 741, 1479, 1484,   # gauss
    1481, 1490, 2989, 3001  # cascade
])

color_dict = {
    'Sobel':    colors[0],
    'Gauss':    colors[1],
    'Cascaded': colors[2]
}

# Cluster spacing layout
width = 0.55
x_positions = []
curr_x = 0.0

for i in range(len(categories)):
    x_positions.append(curr_x)
    if (i + 1) % 4 == 0:
        curr_x += width + 0.90   # Gap between filter families
    elif (i + 1) % 2 == 0:
        curr_x += width + 0.45   # Gap between 3x3 and 5x5
    else:
        curr_x += width + 0.15   # Gap between Integer and IEEE

x_positions = np.array(x_positions)

fig, (ax_tot, ax_lat) = plt.subplots(2, 1, figsize=(13, 8.5), dpi=150, sharex=True)
fig.subplots_adjust(hspace=0.28)

# ==========================================
# (A) Subplot 1: Total Frame Cycles (Top)
# ==========================================
bars_tot = []
for i in range(len(categories)):
    flt, win, arch = categories[i].split()
    c = color_dict[flt]
    pos = x_positions[i]
    is_ieee = (arch == 'IEEE')
    
    if not is_ieee:
        b = ax_tot.bar(pos, total_cycles[i], width, color=c, edgecolor=c, zorder=3)
    else:
        b = ax_tot.bar(pos, total_cycles[i], width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
    bars_tot.append(b[0])

# Top bar labels for total cycles (Font: 9.5pt bold)
for b in bars_tot:
    h = b.get_height()
    ax_tot.annotate(f'{int(h):,}',
                    xy=(b.get_x() + b.get_width() / 2, h),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=9.5, fontweight='bold')

ax_tot.set_ylim(0, max(total_cycles)*1.5)
ax_tot.set_ylabel('Total Execution Cycles', fontsize=11)
ax_tot.set_title('(A) Total Execution Cycles', fontsize=12, loc='left', fontweight='bold')
ax_tot.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

# ==========================================
# (B) Subplot 2: Initial Warm-Up Latency (Bottom)
# ==========================================
bars_lat = []
for i in range(len(categories)):
    flt, win, arch = categories[i].split()
    c = color_dict[flt]
    pos = x_positions[i]
    is_ieee = (arch == 'IEEE')
    
    if not is_ieee:
        b = ax_lat.bar(pos, initial_latency[i], width, color=c, edgecolor=c, zorder=3)
    else:
        b = ax_lat.bar(pos, initial_latency[i], width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
    bars_lat.append(b[0])

# Top bar labels for latency (Font: 10pt bold)
for b in bars_lat:
    h = b.get_height()
    ax_lat.annotate(f'{int(h):,}',
                    xy=(b.get_x() + b.get_width() / 2, h),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

ax_lat.set_ylim(0, max(initial_latency)*1.2)
ax_lat.set_ylabel('Latency (Clock Cycles)', fontsize=11)
ax_lat.set_title('(B) Initial (Warm-Up) Latency', fontsize=12, loc='left', fontweight='bold')
ax_lat.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

# ==========================================
# Group Dividers & Filter Headers
# ==========================================
for ax in (ax_tot, ax_lat):
    div1 = (x_positions[3] + x_positions[4]) / 2
    div2 = (x_positions[7] + x_positions[8]) / 2
    ax.axvline(div1, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)
    ax.axvline(div2, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)

filter_headers = [
    ((x_positions[0] + x_positions[3]) / 2, 'Sobel Filter'),
    ((x_positions[4] + x_positions[7]) / 2, 'Gaussian Filter'),
    ((x_positions[8] + x_positions[11]) / 2, 'Cascaded Filter')
]

for x_center, text in filter_headers:
    ax_tot.text(x_center, 250000, text, ha='center', va='bottom', fontsize=11.5, fontweight='bold', color='black')
    ax_lat.text(x_center, 3350, text, ha='center', va='bottom', fontsize=11.5, fontweight='bold', color='black')

x_labels = [
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754'
]
ax_lat.set_xticks(x_positions)
ax_lat.set_xticklabels(x_labels, fontsize=10, rotation=35, ha='right', fontweight='medium')

# ==========================================
# Legend & Title (Fixed Position at Top Right)
# ==========================================
legend_patches = [
    mpatches.Patch(facecolor=color_dict['Sobel'], edgecolor=color_dict['Sobel'], label='Sobel'),
    mpatches.Patch(facecolor=color_dict['Gauss'], edgecolor=color_dict['Gauss'], label='Gaussian'),
    mpatches.Patch(facecolor=color_dict['Cascaded'], edgecolor=color_dict['Cascaded'], label='Cascaded'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer (Shift)'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]

# Placed at top-right (matching your other plots exactly)
fig.legend(handles=legend_patches, loc='upper right', bbox_to_anchor=(0.995, 0.97),
           ncol=2, fontsize=10, frameon=True, framealpha=0.95)

fig.suptitle('Total Execution Cycles and Initial Warm-Up Latency', 
             fontsize=15, y=0.98, fontweight='bold')

plt.tight_layout()
plt.subplots_adjust(top=0.88, bottom=0.12)
plt.show()