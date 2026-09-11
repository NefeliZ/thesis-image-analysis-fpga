#
# sobel filter 3x3 window
# takes verilog output
# pixel vals affter sobel filter - 1 pixel per line
# recreates image
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps
import os
import matplotlib.pyplot as plt
import sys
#
sys.path.append('C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process') #add path for py files
import my_functions
import custom_filters
#############

### file paths
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'

case_name = 'smeagol_'

verilog_input_path = path + case_name + "verilog_out_gaussblur3x3_ieee.txt"
#verilog_input_path = path + case_name +  "verilog_out_gaussblur3x3_int_shift.txt"

verilog_img_recreate_path = path + case_name+ 'verilog_rec_gaussblur3x3_ieee.png'
#verilog_img_recreate_path = path + case_name + 'verilog_rec_gaussblur3x3_int_shift.png'

og_img_path = path + case_name +'test_img.png'
gray_img_path = path + case_name +'gray_img.png'
py_img_filter_path = path + case_name +'py_img_gaussblur3x3.png'


# window size
N = 3

### add padding - fix img size
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE) 
(row, col) = gray_img.shape[0:2] 
padd_img, width, height = my_functions.add_padd(gray_img, col, row) #col=width, row=height


##########
### apply custom filter
py_img_filter = custom_filters.gaussian_blur_3x3(padd_img, width, height)
cv2.imwrite(py_img_filter_path, py_img_filter)
cv2.imshow('apply filter only with python - Gaussian Blur 1win 3x3', py_img_filter)
cv2.waitKey(0)

# keep img for calcs
py_img_filter = cv2.imread(py_img_filter_path, cv2.IMREAD_GRAYSCALE)

########## 
### Verilog

# get pixels
ver_pixels = []
with open(verilog_input_path, 'r') as f:
    for line in f: # 1 line = 1 pixel
        line_val = line.strip()
        if line_val:
            ver_pixels.append(int(line_val))

#turn array to img & save
# verilog size will be the same as python size => padd img-2
ver_arr = np.array(ver_pixels, dtype=np.uint8).reshape((int(height-2), int(width-2)))
cv2.imwrite(verilog_img_recreate_path, ver_arr)

# keep img for calcs
verilog_img_recreate = cv2.imread(verilog_img_recreate_path, cv2.IMREAD_GRAYSCALE)
cv2.imshow('recrete from verilog code - Gaussian Blur 1win 3x3', verilog_img_recreate) 
cv2.waitKey(0)


######
### calc difference of ver & py filter img
diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img = my_functions.compare_img_metrics(py_img_filter, verilog_img_recreate)

#????????????
#ssim_img = (ssim_img * 255).astype("uint8")

plt.imshow(ssim_img, cmap=plt.cm.gray, vmin=0, vmax=1)
plt.title(f'SSIM Quality Map|| SSIM index: {ssim_val})')
plt.colorbar(label='ssim')
plt.axis('off')
plt.show()

# plot difference - heatmap
plt.imshow(diff, cmap='hot')
plt.colorbar(label='Pixel Difference')
plt.title(f'Absolute Difference Heatmap (Max diff: {np.max(diff)})')
plt.show()

print("--------------------------")
print(f"Max abs diff : {max_diff}")
print(f"MSE: {mse}")
print(f"RMSE: {rmse}")
print(f"PSNR (dB): {psnr}")
print(f"SSIM: {ssim_val}")
print("--------------------------\n")
