# OLD NUMBERS - NOT IN USE
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
import numpy as np
##########

categories = ['Sobel 3x3', 'Sobel 5x5', 'Gauss 3x3', 'Gauss 5x5', 'Cascaded 3x3', 'Cascaded 5x5']

colors=['#BBF7D0', '#F2CFEE', '#DBEAFE', '#FDE68A', '#2563EB', '#F2AA84', '#F0BB54', '#E59EDD', '#00B050']

x = np.arange(len(categories))
width = 0.25  # Width of each bar

c1 = 3
c2 = 5
c3 = 4

######################## plot 7a
###### integer
LUT_int = [ 2340, 2316, 4721, 4677, 4544, 9028]
FF_int = [6092, 6093, 12233, 12173, 12173, 24482]
DSP_int = [0, 0, 0, 0, 0, 0]


fig, ax1 = plt.subplots(figsize=(12, 8))

val1 = ax1.bar(x - width, LUT_int, width, label='LUT Number', color=colors[c1])
val2 = ax1.bar(x, FF_int, width, label='FF Number', color=colors[c2])
val3 = ax1.bar(x + width, DSP_int, width, label='DSP Number', color=colors[c3])

# scale axis to numbers
ax1.set_ylim(0, max(max(LUT_int), max(FF_int)) * 1.15)

# labels and style
ax1.set_ylabel('LUT, FF, DSP Count', fontsize=11)

# show values on top of bar
ax1.bar_label(val1, padding=3, fmt='%g', fontsize=8)
ax1.bar_label(val2, padding=3, fmt='%g', fontsize=8)
ax1.bar_label(val3, padding=3, fmt='%g', fontsize=8)


# fix x tick thing
ax1.set_xticks(x)
ax1.set_xticklabels(categories, fontsize=11, rotation=15)

# combined legend
all_bars = [val1, val2, val3]
all_labels = [bar.get_label() for bar in all_bars]
ax1.legend(all_bars, all_labels, loc='upper right',fontsize=10, frameon=True)

# title
fig.suptitle('FPGA Resources for Integer Implementations', fontsize=15, fontweight='bold', y=0.98)

plt.tight_layout()
plt.show()

##########################
##########################
##########################


######################## plot 7b
###### IEEE
LUT_ieee = [ 10025, 7564, 23008, 32232, 21200, 59267]
FF_ieee = [6716, 6666, 30705, 14556, 13738, 64667]
DSP_ieee = [14, 18, 34, 66, 50, 118]


fig2, ax1 = plt.subplots(figsize=(10, 6))
ax2 = ax1.twinx()  # Secondary axis for the tiny value

# plot grouped
val1 = ax1.bar(x - width, LUT_ieee, width, label='LUT Number', color=colors[c1])
val2 = ax1.bar(x, FF_ieee, width, label='FF Number', color=colors[c2])
val3 = ax2.bar(x + width, DSP_ieee, width, label='DSP Number', color=colors[c3])

# scale in diff aaxes
ax1.set_ylim(0, max(max(LUT_ieee), max(FF_ieee)) * 1.05)
ax2.set_ylim(0, 1000  )  # scale DSP

# labels & style
ax1.set_ylabel('LUT, FF Count', fontsize=11)

ax2.set_ylabel('DSP Count', fontsize=11)#, color=colors[c3], )
ax2.tick_params(axis='y', labelcolor=colors[c3])

# show values on top of bar
ax1.bar_label(val1, padding=3, fmt='%g', fontsize=8)
ax1.bar_label(val2, padding=3, fmt='%g', fontsize=8)

ax2.bar_label(val3, padding=3, fmt='%g', fontsize=8)#, color=colors[c3])

# fix x tick thng
ax1.set_xticks(x)
ax1.set_xticklabels(categories, fontsize=11, rotation=15)

# combined legend
all_bars = [val1, val2, val3]
all_labels = [bar.get_label() for bar in all_bars]
ax1.legend(all_bars, all_labels, loc='upper right',fontsize=10, frameon=True)

# title
fig2.suptitle('FPGA Resources for IEEE Implementations', fontsize=15, fontweight='bold', y=0.98)


plt.tight_layout()
plt.show()
