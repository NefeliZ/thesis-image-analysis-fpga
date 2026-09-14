#
# takes verilog output - recreates image
# applies filter with python
# compares images
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps
import os
import matplotlib.pyplot as plt
#
import sys
sys.path.append('C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process') #add path for py files
import my_functions
import custom_filters
#############

### file path
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'

#######################################
#### file names for cases
img_case = 'smeagol_'

#win_size = '3x3'
win_size = '5x5'

f_case = 'int_shift'
#f_case = 'ieee'

filter = 'sobel'
#filter = 'gaussblur'
#filter = 'cascade'

#######################################
verilog_input_path = path + img_case + "verilog_out_" + filter + win_size + "_" + f_case + ".txt"
verilog_img_recreate_path = path + img_case + "verilog_rec_" + filter + win_size + "_" + f_case + ".png"

og_img_path = path + img_case + 'test_img.png'
gray_img_path = path + img_case + 'gray_img.png'
py_img_filter_path = path + img_case +"py_img_" + filter + win_size + ".png"

#######################################
#### window size

if win_size == '3x3':
    N = 3
elif win_size == '5x5':
    N = 5

#### padding size
if filter == 'cascade': #cascaded filters need double padding
    pad = int(((N-1)/2) * 2)
else:
    pad = int((N-1)/2)

#######################################
#### add padding - fix image size
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE) 
(row, col) = gray_img.shape[0:2] 
padd_img, width, height = my_functions.add_padd(gray_img, col, row, pad) #col=width, row=height


#######################################
#### apply custom filter

if filter == 'sobel':
    py_img_filter = custom_filters.sobel_filter(padd_img, width, height, N)

elif filter == 'gaussblur':
    py_img_filter = custom_filters.gaussian_blur(padd_img, width, height, N)

elif filter == 'cascade':
    py_img_filter = custom_filters.cascade(padd_img, width, height, N)

cv2.imwrite(py_img_filter_path, py_img_filter)
cv2.imshow('Python Filter - ' + filter + ' ' + win_size, py_img_filter)
cv2.waitKey(0)

# keep img for calcs
py_img_filter = cv2.imread(py_img_filter_path, cv2.IMREAD_GRAYSCALE)


#######################################
#### Verilog image reconstruction

# get pixels
ver_pixels = []
with open(verilog_input_path, 'r') as f:
    for line in f: # 1 line = 1 pixel
        line_val = line.strip()
        if line_val:
            ver_pixels.append(int(line_val))

#turn array to img & save
# verilog size will be the same as python size 
ver_arr = np.array(ver_pixels, dtype=np.uint8).reshape((int(height-(2*pad)), int(width-(2*pad))))
cv2.imwrite(verilog_img_recreate_path, ver_arr)

# keep img for calcs
verilog_img_recreate = cv2.imread(verilog_img_recreate_path, cv2.IMREAD_GRAYSCALE)
cv2.imshow('Verilog Filter - ' + filter + ' ' + win_size, verilog_img_recreate) 
cv2.waitKey(0)


#######################################
#### compare images
diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img = my_functions.compare_img_metrics(py_img_filter, verilog_img_recreate)

plt.imshow(ssim_img, cmap=plt.cm.gray, vmin=0, vmax=1)
plt.title(f'SSIM Quality Map || SSIM index: {ssim_val})')
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
