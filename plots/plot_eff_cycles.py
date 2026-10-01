#
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
import matplotlib.patches as mpatches
##########


colors=['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']


color_dict = {
    'Sobel': colors[0],  
    'Gauss': colors[1],  
    'Cascaded': colors[2]
}

######################## plot 5
############

# Throughput (Mpixels/s) and LUT Counts
# Area Efficiency= Mpixels/s by 1000 LUTs (kLUT)
########################
LUT_sobel = [ 2340, 10025, 4677, 32232]
T_sobel = [ 67.11859856, 52.05351101, 53.73166407, 51.03082262]

LUT_gauss = [ 2316, 7864, 4544, 21200]
T_gauss = [ 77.19027403, 65.07874528, 69.00358819, 62.39860227]

LUT_casc = [ 4721, 23008, 9028, 59267]
T_casc = [ 75.86677794, 52.8262018, 57.34273754, 47.01457452]


a_eff_sobel = (np.array(T_sobel) / np.array(LUT_sobel)) * 1000
a_eff_gauss = (np.array(T_gauss) / np.array(LUT_gauss)) * 1000
a_eff_casc = (np.array(T_casc) / np.array(LUT_casc)) * 1000

cases = ['3x3 Integer', '3x3 IEEE', '5x5 Integer', '5x5 IEEE']

a_eff_data = {
    'Sobel': (np.array(T_sobel) / np.array(LUT_sobel)) * 1000,
    'Gauss': (np.array(T_gauss) / np.array(LUT_gauss)) * 1000,
    'Cascaded': (np.array(T_casc) / np.array(LUT_casc)) * 1000,
}


x = np.arange(len(cases))
width = 0.25  # Width of each bar

x_positions = []
curr_x = 0.0

# Build positions: pair Int & IEEE tightly, leave a gap for window size, large gap between filters
for i in range(12):
    x_positions.append(curr_x)
    if (i + 1) % 4 == 0:
        curr_x += width + 0.20   # Large separator gap between filter families
    elif (i + 1) % 2 == 0:
        curr_x += width + 0.10   # Medium gap separating 3x3 from 5x5
    else:
        curr_x += width + 0.05   # Small gap between Integer and IEEE pair

x_positions = np.array(x_positions)

fig, ax = plt.subplots(figsize=(10, 6), dpi=150)

all_bars = []
idx = 0

for flt in ['Sobel', 'Gauss', 'Cascaded']:
    eff_values = a_eff_data[flt]
    c = color_dict[flt]
    
    for case_idx in range(4):
        val = eff_values[case_idx]
        pos = x_positions[idx]
        is_ieee = (case_idx % 2 == 1)
        
        # Solid fill for Integer, hatched white fill for IEEE-754
        if not is_ieee:
            b = ax.bar(pos, val, width, color=c, edgecolor=c, zorder=3)
        else:
            b = ax.bar(pos, val, width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
            
        all_bars.append(b[0])
        idx += 1

# Annotate value labels directly on top of each bar
for b in all_bars:
    h = b.get_height()
    ax.annotate(f'{h:.1f}',
                xy=(b.get_x() + b.get_width() / 2, h),
                xytext=(0, 4),
                textcoords="offset points",
                ha='center', va='bottom', fontsize=8.5, fontweight='semibold')

# Vertical dividers separating filter categories
div1 = (x_positions[3] + x_positions[4]) / 2
div2 = (x_positions[7] + x_positions[8]) / 2
ax.axvline(div1, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)
ax.axvline(div2, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)

# Window-size sub-labels below the ticks
#window_group_labels = [
#    ((x_positions[0] + x_positions[1]) / 2, '3x3'),
#    ((x_positions[2] + x_positions[3]) / 2, '5x5'),
#    ((x_positions[4] + x_positions[5]) / 2, '3x3'),
#    ((x_positions[6] + x_positions[7]) / 2, '5x5'),
#    ((x_positions[8] + x_positions[9]) / 2, '3x3'),
#    ((x_positions[10] + x_positions[11]) / 2, '5x5')
#]
#
#for x_center, label in window_group_labels:
#    ax.text(x_center, -2.8, label, ha='center', va='top', fontsize=9, fontweight='bold', color='#333333')

# Filter family headers positioned above each cluster
filter_headers = [
    ((x_positions[0] + x_positions[3]) / 2, 'Sobel Filter',    '#000000'),# color_dict['Sobel']),
    ((x_positions[4] + x_positions[7]) / 2, 'Gaussian Filter', '#000000'),# color_dict['Gauss']),
    ((x_positions[8] + x_positions[11]) / 2, 'Cascaded Filters','#000000')# color_dict['Cascaded'])
]

max_val = max(np.concatenate(list(a_eff_data.values())))
for x_center, text, col in filter_headers:
    ax.text(x_center, max_val * 1.05, text, ha='center', va='bottom', fontsize=11, fontweight='bold', color=col)

# X-axis tick formatting (individual bar architecture)
ax.set_xticks(x_positions)
ax.set_xticklabels(cases * 3, fontsize=8.5, rotation=35, ha='right')

ax.set_ylim(0, max_val * 1.18)
ax.set_ylabel('Area Efficiency (Mpixels/s per kLUT)', fontsize=11)#, fontweight='bold')
#fig.text(0.015, 0.55, "Area Efficiency (Mpixels/s per kLUT)", va="center", rotation="vertical", fontsize=11 )

ax.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

# Multi-column structured legend
legend_patches = [
    mpatches.Patch(facecolor=color_dict['Sobel'], edgecolor=color_dict['Sobel'], label='Sobel'),
    mpatches.Patch(facecolor=color_dict['Gauss'], edgecolor=color_dict['Gauss'], label='Gaussian'),
    mpatches.Patch(facecolor=color_dict['Cascaded'], edgecolor=color_dict['Cascaded'], label='Cascaded'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]
ax.legend(handles=legend_patches, loc='upper right', ncol=2, bbox_to_anchor=(1.01, 1.13), fontsize=10, framealpha=0.95)

fig.suptitle('Hardware Area Efficiency', fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout()
plt.subplots_adjust(bottom=0.14, top=0.90)
plt.show()

##########################
##########################
##########################


######################## plot 2
############

categories = [
    'Sobel 3x3 Int', 'Sobel 3x3 IEEE', 'Sobel 5x5 Int', 'Sobel 5x5 IEEE',
    'Gauss 3x3 Int', 'Gauss 3x3 IEEE', 'Gauss 5x5 Int', 'Gauss 5x5 IEEE',
    'Cascaded 3x3 Int', 'Cascaded 3x3 IEEE', 'Cascaded 5x5 Int', 'Cascaded 5x5 IEEE'
]

# Total execution cycles
total_cycles = np.array([
177512, 177516, 179218, 179224,   #sobel
177512, 177516, 179218, 179223,   #gauss
179220, 179229, 182656, 182668 ]) #cascade


# Initial buffer warm-up / pipeline latency cycles before valid pixel_out starts
initial_latency = np.array([
737, 741, 1479, 1485,   #sobel
737, 741, 1479, 1484,   #gauss
1481, 1490, 2989, 3001])#cascade


# Active streaming cycles (Total - Initial Latency)
streaming_cycles = total_cycles - initial_latency

# Base color palette for filter families
color_dict = {
    'Sobel': colors[0],  
    'Gauss': colors[1],  
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

fig, ax = plt.subplots(figsize=(10, 6), dpi=150)

bars = []
for i in range(len(categories)):
    flt, win, arch = categories[i].split()
    c = color_dict[flt]
    pos = x_positions[i]
    is_ieee = (arch == 'IEEE')
    
    if not is_ieee:
        b = ax.bar(pos, total_cycles[i], width, color=c, edgecolor=c, zorder=3)
    else:
        b = ax.bar(pos, total_cycles[i], width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
    bars.append(b[0])

# Top bar labels with exact values
for b in bars:
    h = b.get_height()
    ax.annotate(f'{int(h):,}',
                xy=(b.get_x() + b.get_width() / 2, h),
                xytext=(0, 4),
                textcoords="offset points",
                ha='center', va='bottom', fontsize=8, fontweight='semibold')

# Vertical separators between filter types
div1 = (x_positions[3] + x_positions[4]) / 2
div2 = (x_positions[7] + x_positions[8]) / 2
ax.axvline(div1, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)
ax.axvline(div2, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)

# Filter family headers above clusters
filter_headers = [
    ((x_positions[0] + x_positions[3]) / 2, 'Sobel Filter', color_dict['Sobel']),
    ((x_positions[4] + x_positions[7]) / 2, 'Gaussian Filter', color_dict['Gauss']),
    ((x_positions[8] + x_positions[11]) / 2, 'Cascaded Filter', color_dict['Cascaded'])
]
for x_center, text, col in filter_headers:
    ax.text(x_center, 183800, text, ha='center', va='bottom', fontsize=11, fontweight='bold', color='#000000')

# X-axis setup: explicitly shows Window Size and Architecture per tick
x_labels = [
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754'
]
ax.set_xticks(x_positions)
ax.set_xticklabels(x_labels, fontsize=9, rotation=35, ha='right', fontweight='medium')

# Y-axis scaling to accentuate cycle differences
ax.set_ylim(173000, 184500)
ax.set_ylabel('Execution Time (Total Clock Cycles)', fontsize=11)#, fontweight='bold')
#ax.set_xlabel('Window Size & Architecture', fontsize=11,  labelpad=10) #fontweight='bold',
ax.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

# Legend placed outside at the top
legend_patches = [
    mpatches.Patch(facecolor=color_dict['Sobel'], edgecolor=color_dict['Sobel'], label='Sobel'),
    mpatches.Patch(facecolor=color_dict['Gauss'], edgecolor=color_dict['Gauss'], label='Gaussian'),
    mpatches.Patch(facecolor=color_dict['Cascaded'], edgecolor=color_dict['Cascaded'], label='Cascaded'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer (Shift)'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]
ax.legend(handles=legend_patches, loc='lower right', bbox_to_anchor=(1, 1.0), ncol=2, fontsize=10, frameon=True, framealpha=0.95)

# Overall Title
ax.set_title('Total Execution Cycles', fontsize=15, fontweight='bold', pad=45)

plt.tight_layout()
plt.subplots_adjust(bottom=0.16)
plt.show()