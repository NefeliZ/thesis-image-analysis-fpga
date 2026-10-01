import matplotlib.pyplot as plt
import numpy as np
import matplotlib.patches as mpatches

colors = ['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']

color_dict = {
    'Sobel': colors[0],  
    'Gauss': colors[1],  
    'Cascaded': colors[2]
}

# ==============================================================================
# PLOT 1: Device Utilization (%)
# ==============================================================================


LUT_sobel = [ 2340, 10025, 4677, 32232]
FF_sobel  = [6092, 6716, 12173, 14556]
DSP_sobel = [0, 14, 0, 66]

LUT_gauss = [ 2316, 7864, 4544, 21200]
FF_gauss  = [6093, 6666, 12173, 13738]
DSP_gauss = [0, 18, 0, 50]

LUT_casc  =  [ 4721, 23008, 9028, 59267]
FF_casc   = [12233, 30705, 24482, 64667]
DSP_casc  = [0, 34, 0, 118]



# Standard device capacity (Artix-7 XC7A100T)
LUT_t = 134600
FF_t  = 269200
DSP_t = 740

# Larger device capacity (Target only for Cascaded 5x5 IEEE, index 3)
l_LUT_t = 134600
l_FF_t  = 269200
l_DSP_t = 740

# Per-element normalization arrays for Cascaded
casc_lut_totals = np.array([LUT_t, LUT_t, LUT_t, l_LUT_t])
casc_ff_totals  = np.array([FF_t,  FF_t,  FF_t,  l_FF_t])
casc_dsp_totals = np.array([DSP_t, DSP_t, DSP_t, l_DSP_t])

# Convert to % of device capacity
pct_data = {
    'Sobel': {
        'LUT': (np.array(LUT_sobel) / LUT_t) * 100,
        'FF':  (np.array(FF_sobel) / FF_t) * 100,
        'DSP': (np.array(DSP_sobel) / DSP_t) * 100,
    },
    'Gauss': {
        'LUT': (np.array(LUT_gauss) / LUT_t) * 100,
        'FF':  (np.array(FF_gauss) / FF_t) * 100,
        'DSP': (np.array(DSP_gauss) / DSP_t) * 100,
    },
    'Cascaded': {
        'LUT': (np.array(LUT_casc) / casc_lut_totals) * 100,
        'FF':  (np.array(FF_casc) / casc_ff_totals) * 100,
        'DSP': (np.array(DSP_casc) / casc_dsp_totals) * 100,
    },
}

res_colors = {
    'LUT': colors[3], 
    'FF':  colors[5], 
    'DSP': colors[4]  
}

filters = ['Sobel', 'Gauss', 'Cascaded']
width = 0.24  

fig1, (ax_3x3, ax_5x5) = plt.subplots(2, 1, figsize=(13, 8.5), dpi=150, sharey=True)
fig1.subplots_adjust(hspace=0.35)

def plot_window_panel(ax, win_idx_int, win_idx_ieee, title_text):
    x_positions = []
    curr_x = 0.0
    
    for i in range(6):
        x_positions.append(curr_x)
        if (i + 1) % 2 == 0:
            curr_x += 1.2
        else:
            curr_x += 0.7
            
    x_positions = np.array(x_positions)
    idx = 0
    all_bars = []
    
    for flt in filters:
        for arch_idx, win_idx in enumerate([win_idx_int, win_idx_ieee]):
            is_ieee = (arch_idx == 1)
            pos = x_positions[idx]
            
            lut_v = pct_data[flt]['LUT'][win_idx]
            ff_v  = pct_data[flt]['FF'][win_idx]
            dsp_v = pct_data[flt]['DSP'][win_idx]
            
            for r_idx, (r_name, r_val) in enumerate([('LUT', lut_v), ('FF', ff_v), ('DSP', dsp_v)]):
                offset = (r_idx - 1) * width
                c = res_colors[r_name]
                
                if not is_ieee:
                    bar = ax.bar(pos + offset, r_val, width, color=c, edgecolor=c, zorder=3)
                else:
                    bar = ax.bar(pos + offset, r_val, width, color='white', edgecolor=c, 
                                 hatch='//', linewidth=1.4, zorder=3)
                
                all_bars.append(bar[0])
            idx += 1

    # Annotate bar values (Larger Font: 11pt bold)
    for b in all_bars:
        h = b.get_height()
        if h > 0.0:
            ax.annotate(f'{h:.1f}%',
                        xy=(b.get_x() + b.get_width() / 2, h),
                        xytext=(0, 3),
                        textcoords="offset points",
                        ha='center', va='bottom', fontsize=11, fontweight='bold')
        else:
            ax.annotate('0%',
                        xy=(b.get_x() + b.get_width() / 2, 0),
                        xytext=(0, 2),
                        textcoords="offset points",
                        ha='center', va='bottom', fontsize=10, color='gray')

    # Visual group dividers
    div1 = (x_positions[1] + x_positions[2]) / 2
    div2 = (x_positions[3] + x_positions[4]) / 2
    ax.axvline(div1, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)
    ax.axvline(div2, color='lightgray', linestyle=':', linewidth=1.2, zorder=1)

    filter_centers = [
        (x_positions[0] + x_positions[1]) / 2,
        (x_positions[2] + x_positions[3]) / 2,
        (x_positions[4] + x_positions[5]) / 2
    ]
    for c_pos, flt in zip(filter_centers, filters):
        ax.text(c_pos, 92, flt, ha='center', va='bottom', fontsize=12, fontweight='bold', color='#1E293B')

    ax.set_xticks(x_positions)
    ax.set_xticklabels(['Integer', 'IEEE-754', 'Integer', 'IEEE-754', 'Integer', 'IEEE-754'], 
                       fontsize=10, fontweight='medium')
    ax.set_title(title_text, fontsize=12, fontweight='bold', pad=10, loc='left')
    ax.set_ylabel('Device Utilization (%)', fontsize=11)
    ax.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

plot_window_panel(ax_3x3, win_idx_int=0, win_idx_ieee=1, title_text='(A) 3x3 Window')
plot_window_panel(ax_5x5, win_idx_int=2, win_idx_ieee=3, title_text='(B) 5x5 Window')

ax_3x3.set_ylim(0, 108)
ax_5x5.set_ylim(0, 108)

legend_patches_1 = [
    mpatches.Patch(facecolor=res_colors['LUT'], edgecolor=res_colors['LUT'], label='LUTs'),
    mpatches.Patch(facecolor=res_colors['FF'], edgecolor=res_colors['FF'], label='FFs'),
    mpatches.Patch(facecolor=res_colors['DSP'], edgecolor=res_colors['DSP'], label='DSPs'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]

fig1.legend(handles=legend_patches_1, loc='upper right', bbox_to_anchor=(1, 0.98), 
            ncol=2, fontsize=10, frameon=True, framealpha=0.95)

fig1.suptitle('FPGA Device Utilization Percentage', 
              fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout()
plt.subplots_adjust(top=0.88)
plt.show()


# ==============================================================================
# PLOT 2: Maximum Frequency (Fmax) & Worst Negative Slack (WNS)
# ==============================================================================

categories = [
    'Sobel 3x3 Int', 'Sobel 3x3 IEEE', 'Sobel 5x5 Int', 'Sobel 5x5 IEEE',
    'Gauss 3x3 Int', 'Gauss 3x3 IEEE', 'Gauss 5x5 Int', 'Gauss 5x5 IEEE',
    'Cascaded 3x3 Int', 'Cascaded 3x3 IEEE', 'Cascaded 5x5 Int', 'Cascaded 5x5 IEEE'
]

WNS = np.array([
    5.101, 0.789, 1.389, 0.404,
    7.045, 4.634, 5.508, 3.974,
    6.819, 1.07, 2.561, -1.270
])

F_max= 1000/(20-WNS)

width = 0.55
x_positions = []
curr_x = 0.0

for i in range(len(categories)):
    x_positions.append(curr_x)
    if (i + 1) % 4 == 0:
        curr_x += width + 0.90
    elif (i + 1) % 2 == 0:
        curr_x += width + 0.45
    else:
        curr_x += width + 0.15

x_positions = np.array(x_positions)

fig2, (ax_fmax, ax_wns) = plt.subplots(2, 1, figsize=(13, 8.5), dpi=150, sharex=False)
fig2.subplots_adjust(hspace=0.35)

# --- (A) Subplot 1: Maximum Frequency ---
bars_fmax = []
for i in range(len(categories)):
    flt, win, arch = categories[i].split()
    c = color_dict[flt]
    pos = x_positions[i]
    is_ieee = (arch == 'IEEE')
    
    if not is_ieee:
        b = ax_fmax.bar(pos, F_max[i], width, color=c, edgecolor=c, zorder=3)
    else:
        b = ax_fmax.bar(pos, F_max[i], width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
    bars_fmax.append(b[0])

# Bar labels for Fmax (Font: 10.5pt bold)
for b in bars_fmax:
    h = b.get_height()
    ax_fmax.annotate(f'{h:.1f}',
                     xy=(b.get_x() + b.get_width() / 2, h),
                     xytext=(0, 3),
                     textcoords="offset points",
                     ha='center', va='bottom', fontsize=10.5, fontweight='bold')

ax_fmax.axhline(50.0, color='gray', linestyle='--', linewidth=1.1, alpha=0.7, zorder=2)
ax_fmax.text(x_positions[-1] + 0.5, 51.2, '50 MHz Target', color='gray', fontsize=9.5, ha='right', fontweight='medium')

x_labels = [
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754',
    '3x3 Integer', '3x3 IEEE-754', '5x5 Integer', '5x5 IEEE-754'
]
ax_fmax.set_xticks(x_positions)
ax_fmax.set_xticklabels(x_labels, fontsize=10, rotation=35, ha='right', fontweight='medium')
ax_fmax.set_ylim(0, max(F_max) * 1.18)
ax_fmax.set_ylabel('Max Frequency $F_{max}$ (MHz)', fontsize=11)
ax_fmax.set_title('(A) Maximum Operating Frequency ($F_{max}$)', fontsize=12, loc='left', fontweight='bold')
ax_fmax.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

# --- (B) Subplot 2: Worst Negative Slack (WNS) ---
bars_wns = []
for i in range(len(categories)):
    flt, win, arch = categories[i].split()
    c = color_dict[flt]
    pos = x_positions[i]
    is_ieee = (arch == 'IEEE')
    
    if not is_ieee:
        b = ax_wns.bar(pos, WNS[i], width, color=c, edgecolor=c, zorder=3)
    else:
        b = ax_wns.bar(pos, WNS[i], width, color='white', edgecolor=c, hatch='//', linewidth=1.5, zorder=3)
    bars_wns.append(b[0])

# Bar labels for WNS (Font: 10.5pt bold)
for b in bars_wns:
    h = b.get_height()
    if h >= 0:
        ax_wns.annotate(f'{h:.2f}',
                        xy=(b.get_x() + b.get_width() / 2, h),
                        xytext=(0, 3),
                        textcoords="offset points",
                        ha='center', va='bottom', fontsize=10.5, fontweight='bold')
    else:
        # Negative value placed below bar
        ax_wns.annotate(f'{h:.2f}',
                        xy=(b.get_x() + b.get_width() / 2, h),
                        xytext=(0, -4),
                        textcoords="offset points",
                        ha='center', va='top', fontsize=10.5, fontweight='bold', color='#B91C1C')

ax_wns.axhline(0.0, color='black', linewidth=1.1, zorder=2)

wns_min = min(WNS)
wns_max = max(WNS)
ax_wns.set_ylim(wns_min - 1.2, wns_max * 1.25)
ax_wns.set_ylabel('Worst Negative Slack (ns)', fontsize=11)
ax_wns.set_title('(B) Worst Negative Slack (WNS) Relative to Target Clock Constraint', fontsize=12, fontweight='bold', loc='left')
ax_wns.grid(axis='y', linestyle='--', alpha=0.45, zorder=0)

for ax in (ax_fmax, ax_wns):
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
    ax_fmax.text(x_center, max(F_max) * 1.07, text, ha='center', va='bottom', fontsize=11.5, fontweight='bold')

ax_wns.set_xticks(x_positions)
ax_wns.set_xticklabels(x_labels, fontsize=10, rotation=35, ha='right', fontweight='medium')

legend_patches_2 = [
    mpatches.Patch(facecolor=color_dict['Sobel'], edgecolor=color_dict['Sobel'], label='Sobel'),
    mpatches.Patch(facecolor=color_dict['Gauss'], edgecolor=color_dict['Gauss'], label='Gaussian'),
    mpatches.Patch(facecolor=color_dict['Cascaded'], edgecolor=color_dict['Cascaded'], label='Cascaded'),
    mpatches.Patch(facecolor='gray', edgecolor='gray', label='Integer (Shift)'),
    mpatches.Patch(facecolor='white', edgecolor='gray', hatch='//', label='IEEE-754 (Float)')
]

fig2.legend(handles=legend_patches_2, loc='upper right', bbox_to_anchor=(1, 0.98), 
            ncol=2, fontsize=10, frameon=True, framealpha=0.95)

fig2.suptitle('Maximum Operating Frequency ($F_{max}$) and Worst Timing Slack (WNS)', 
              fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout()
plt.subplots_adjust(top=0.88, bottom=0.12)
plt.show()