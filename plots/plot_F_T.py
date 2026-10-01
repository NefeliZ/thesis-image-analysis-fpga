#
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
##########

categories = ['Sobel Integer', 'Sobel IEEE', 'Gauss Integer', 'Gauss IEEE', 'Cascade Integer', 'Cascade IEEE']

colors=['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']

x = np.arange(len(categories))
width = 0.25  # Width of each bar

c1 = 0
c2 = 1
c3 = 5

########################
###### 3x3
LUT = [ 2342, 10027, 2317, 21284, 4720, 17837]
FF = [6092, 6716, 6093, 13643, 12233, 13331]
DSP = [0, 14, 0, 44, 0, 26]


fig, ax1 = plt.subplots(figsize=(10, 6))
ax2 = ax1.twinx()  # Secondary axis for the tiny value

# 1. Plot grouped bars
val1 = ax1.bar(x - width, LUT, width, label='LUT Number', color=colors[c1])
val2 = ax1.bar(x, FF, width, label='FF Number', color=colors[c2])
val3 = ax2.bar(x + width, DSP, width, label='DSP Number', color=colors[c3])

# 2. Scale primary and secondary axes properly
ax1.set_ylim(0, max(max(LUT), max(FF)) * 1.15)
ax2.set_ylim(0, max(LUT) -21000 )  # Scales proportional to the small DSP metric

# 3. Axis labels & styling
ax1.set_ylabel('LUT / FF Count', fontsize=11)
ax2.set_ylabel('DSP Count', color=colors[c3], fontsize=11)
ax2.tick_params(axis='y', labelcolor=colors[c3])

# 4. Values on top of each bar
ax1.bar_label(val1, padding=3, fmt='%g', fontsize=8)
ax1.bar_label(val2, padding=3, fmt='%g', fontsize=8)
ax2.bar_label(val3, padding=3, fmt='%g', fontsize=8, color=colors[c3])

# 5. Fix x-tick alignment (fixes the skipped/shifted label)
ax1.set_xticks(x)
ax1.set_xticklabels(categories, fontsize=10, rotation=15)

# 6. Combined legend
all_bars = [val1, val2, val3]
all_labels = [bar.get_label() for bar in all_bars]
ax1.legend(all_bars, all_labels, loc='upper left', frameon=True)

#fig.title('3x3 Window - Resource metrics for each case')

plt.tight_layout()
plt.show()

##########################
##########################
##########################

fmax = [74.57121551,51.26364895,74.51564829,65.75054244,70.08199594,51.2295082]

T = [74.57121551, 51.26364895, 74.51564829, 65.75054244, 70.08199594, 51.2295082]
FPS = [422.3825426, 290.3584133, 422.0678015, 372.4103812, 395.2891312, 288.9392573]
  

fig, ax1 = plt.subplots(figsize=(10, 6))

# 1. Plot grouped bars
val1 = ax1.bar(x - width, fmax, width, label='Fmax', color=colors[c1])
val2 = ax1.bar(x, FPS, width, label='Throughput', color=colors[c2])

# 2. Scale primary and secondary axes properly
#ax1.set_ylim(0, max(max(LUT), max(FF)) * 1.15)

# 3. Axis labels & styling
ax1.set_ylabel('LUT / FF Count', fontsize=11)

# 4. Values on top of each bar
ax1.bar_label(val1, padding=3, fmt='%g', fontsize=8)
ax1.bar_label(val2, padding=3, fmt='%g', fontsize=8)

# 5. Fix x-tick alignment (fixes the skipped/shifted label)
ax1.set_xticks(x)
ax1.set_xticklabels(categories, fontsize=10, rotation=15)

# 6. Combined legend
all_bars = [val1, val2]
all_labels = [bar.get_label() for bar in all_bars]
ax1.legend(all_bars, all_labels, loc='upper left', frameon=True)

#fig.title('3x3 Window - Resource metrics for each case')

plt.tight_layout()
plt.show()

