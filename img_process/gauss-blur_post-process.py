#
# gaussian blur  3x3 window
# takes verilog output
# pixel vals affter filter - 1 pixel per line
# recreates image
# works for square img
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

#file path
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'

verilog_input_path = path + "verilog_out_gaussblur_3x3_ieee.txt"
verilog_img_recreate_path = path + 'verilog_rec_gaussblur_3x3_ieee.png'

og_img_path = path + 'test_img.png'
gray_img_path = path + 'gray_img.png'
py_img_filter_path = path + 'py_img_gauss_3x3.png'

# window size
N = 3

### Verilog
# extract size of img 
# suppose img is square
with open(verilog_input_path, 'r') as f:
    file_size = len(f.readlines())

Vrow = np.sqrt(file_size) #fix for not square
Vcol = np.sqrt(file_size)

print(f'file size: {file_size} => img dimensions: row {Vrow}, col {Vcol}')

# get pixels
ver_pixels = []
with open(verilog_input_path, 'r') as f:
    for line in f: # 1 line = 1 pixel
        line_val = line.strip()
        if line_val:
            ver_pixels.append(int(line_val))

#turn into array & reshape
# 1 line = 1 img line => N pixels
ver_arr = np.array(ver_pixels, dtype=np.uint8).reshape((int(Vrow), int(Vcol)))

#turn array to img & save
#imwrite returns bool
cv2.imwrite(verilog_img_recreate_path, ver_arr)


# keep img for calcs
verilog_img_recreate = cv2.imread(verilog_img_recreate_path, cv2.IMREAD_GRAYSCALE)
cv2.imshow('recrete from verilog code - gauss blur 1win 3x3', verilog_img_recreate) 
cv2.waitKey(0)


##########
### apply custom filter

#fix image size to fit window
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE) 
(row, col) = gray_img.shape[0:2] 
gray_img, col, row = my_functions.fix_im_size(N, gray_img, col, row)


# apply custom filter
py_img_filter = custom_filters.gaussian_blur_3x3(gray_img, col, row)
cv2.imwrite(py_img_filter_path, py_img_filter)

py_img_filter = cv2.imread(py_img_filter_path, cv2.IMREAD_GRAYSCALE)
cv2.imshow('py filter - gauss blur 1win 3x3', py_img_filter) 
cv2.waitKey(0)
# difference in how border is managed (mirrored and 0)
# cut to avoid differences
#py_img_filter = py_img_filter[1:-1, 1:-1]

####crop to same size
#check size & crop

(Prow, Pcol) = py_img_filter.shape[0:2]
Vrow = int(Vrow)
Vcol = int(Vcol)

#check
print('python image size: ', py_img_filter.shape[0:2])
print('verilog image size: ', verilog_img_recreate.shape[0:2])


if Prow > Vrow and Pcol> Vcol:
    py_img_filter_crop = py_img_filter[1:Vrow+1, 1:Vcol+1]
    verilog_img_recreate_crop = verilog_img_recreate
else:
    py_img_filter_crop = py_img_filter
    verilog_img_recreate_crop = verilog_img_recreate


####elif Prow > Vrow and not(Pcol> Vcol):
####    py_img_filter_crop = py_img_filter[0:Vrow, 0:-1]
####    verilog_img_recreate_crop = verilog_img_recreate[0:-1, 0:Pcol]
####elif not(Prow > Vrow) and Pcol > Vcol:
####    py_img_filter_crop = py_img_filter[0:-1, 0:Vcol]
####    verilog_img_recreate_crop = verilog_img_recreate[0:Prow, 0:-1]
####elif Prow < Vrow and Pcol < Vcol:
####    verilog_img_recreate_crop = verilog_img_recreate[0:Prow, 0:Pcol]
####    py_img_filter_crop = py_img_filter




##resize/crop to be similar
#if verilog_img_recreate.shape[0] == py_img_filter.shape[0] - 2:
#    py_img_filter_crop  = py_img_filter[1:-1, 1:-1] #remove extra padding at start
#    verilog_img_recreate_crop = verilog_img_recreate
#else:
#    py_img_filter_crop  = py_img_filter[1:-1, 1:-1]
#    verilog_img_recreate_crop = verilog_img_recreate[1:-1, 1:-1]

#check
print('python image size: ', py_img_filter_crop.shape[0:2])
print('verilog image size: ', verilog_img_recreate_crop.shape[0:2])


######
### calc difference of ver & py filter img
diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img = my_functions.compare_img_metrics(py_img_filter_crop, verilog_img_recreate_crop,N)



plt.imshow(ssim_img, cmap=plt.cm.gray, vmin=0, vmax=1)
plt.title(f'structular similarity index - full image|| ssim val: {ssim_val})')
plt.colorbar(label='ssim')
plt.axis('off')
plt.show()

# plot difference - heatmap
plt.imshow(diff, cmap='hot')
plt.colorbar(label='Pixel Difference')
plt.title(f'2D Difference Map (Max Diff: {np.max(diff)})')
plt.show()

print("--------------------------")
print(f"Max abs diff : {max_diff}")
print(f"MSE: {mse}")
print(f"RMSE: {rmse}")
print(f"PSNR (dB): {psnr}")
print(f"SSIM: {ssim_val}")
print("--------------------------\n")
