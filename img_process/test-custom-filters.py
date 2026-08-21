#
# test custom filters compared to python
# check comparison metrics (mse, rmse etc)
# check with same & diff(flipped) images
#
import cv2
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageOps
import os
import sys
#
sys.path.append('C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process') #add path for py files
import my_functions
import custom_filters
#from custom_filters import sobel_3x3_filter
#############

# apply filters with python
def py_sobel_3x3(N, gray_img, py_path):

    #  Sobel(src_gray, grad_x, ddepth, x_order, y_order, ksize, scale, delta, BORDER_DEFAULT);
    # cv2.CV_16S -> 16-bit signed int
    # order of derivative 
    sobelx = cv2.Sobel(gray_img, cv2.CV_16S, 1, 0, ksize=N)
    sobely = cv2.Sobel(gray_img, cv2.CV_16S, 0, 1, ksize=N)

    # calc absolute vals
    #abs_sobelx = cv2.convertScaleAbs(sobelx) #clips at 255 auto seperately - in edge cases problem/difference
    #abs_sobely = cv2.convertScaleAbs(sobely)
    abs_sobelx = abs(sobelx)
    abs_sobely = abs(sobely)

    # calc magnitude G
    #correction for saturation after sum
    g = np.clip(abs_sobelx + abs_sobely, 0, 255).astype(np.uint8)
    cv2.imwrite(py_path, g)

    # keep img for calcs
    py_img_filter = cv2.imread(py_path, cv2.IMREAD_GRAYSCALE)

    return py_img_filter

#
def py_gauss_3x3(image, py_path):
    weights = (1/16) * np.array( [[1, 2, 1], [2, 4, 2], [1, 2, 1]], dtype=np.float32)

    # BORDER_CONSTANT with value=0 -> black border
    py_img_gauss = cv2.filter2D(image, -1, weights, borderType=cv2.BORDER_CONSTANT)

    cv2.imwrite(py_path, py_img_gauss)
    
    return py_img_gauss

########
###
# file paths
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'
gray_img_path = path + 'gray_img.png'
gray_img_flip_path = path + 'gray_img_flip.png'

py_img_sobel_path = path + 'py_img_sobel_3x3.png'
mi_img_sobel_path = path +'mi_img_sobel_3x3.png' #custom

py_img_gauss_path = path + 'py_img_gauss_3x3.png'
mi_img_gauss_path = path +'mi_img_gauss_3x3.png' #custom

########
###
# image init things
# read og image
img = cv2.imread(path +'test_img.png') 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imwrite(gray_img_path, gray_img)

##### row=height col=width

########
###
# Sobel 3x3
N = 3

#fix image size to fit window
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE) 
(row, col) = gray_img.shape[0:2] 
gray_img, col, row = my_functions.fix_im_size(N, gray_img, col, row)

# apply filter with python
py_sobel_img = py_sobel_3x3(N, gray_img, py_img_sobel_path)

# apply custom filter
mi_sobel_img = custom_filters.sobel_3x3_filter(gray_img, col, row)
cv2.imwrite(mi_img_sobel_path, mi_sobel_img)

# difference in how border is managed (mirrored and 0)
# cut to avoid differences
mi_sobel_img = mi_sobel_img[1:-1, 1:-1]
py_sobel_img = py_sobel_img[1:-1, 1:-1]

######
### calc difference in img
diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img = my_functions.compare_img_metrics(mi_sobel_img, py_sobel_img, N)

plt.imshow(ssim_img, cmap=plt.cm.gray, vmin=0, vmax=1)
plt.title(f'Sobel 3x3: structular similarity index - full image|| ssim val: {ssim_val})')
plt.colorbar(label='ssim')
plt.axis('off')
plt.show()

# plot difference - heatmap
plt.imshow(diff, cmap='hot')
plt.colorbar(label='Pixel Difference')
plt.title(f'Sobel 3x3: 2D Difference Map (Max Diff: {np.max(diff)})')
plt.show()

print("--------------------------")
print(f"Max abs diff : {max_diff}")
print(f"MSE: {mse}")
print(f"RMSE: {rmse}")
print(f"PSNR (dB): {psnr}")
print(f"SSIM: {ssim_val}")
print("--------------------------\n")

################################################
################################################
################################################

########
###
# gaussian blur 3x3
N = 3

#fix image size to fit window
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE) 
(row, col) = gray_img.shape[0:2] 
gray_img, col, row = my_functions.fix_im_size(N, gray_img, col, row)

# apply filter with python
py_gauss_img = py_gauss_3x3(gray_img, py_img_gauss_path)

# apply custom filter
mi_gauss_img = custom_filters.gaussian_blur_3x3(gray_img, col, row)
cv2.imwrite(mi_img_gauss_path, mi_gauss_img)

# difference in how border is managed (mirrored and 0)
# cut to avoid differences
mi_gauss_img = mi_gauss_img[1:-1, 1:-1]
py_gauss_img = py_gauss_img[1:-1, 1:-1]


######
### calc difference in img
diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img = my_functions.compare_img_metrics(mi_gauss_img, py_gauss_img, N)

plt.imshow(ssim_img, cmap=plt.cm.gray, vmin=0, vmax=1)
plt.title(f'Gauss Blur: structular similarity index - full image|| ssim val: {ssim_val})')
plt.colorbar(label='ssim')
plt.axis('off')
plt.show()

# plot difference - heatmap
plt.imshow(diff, cmap='hot')
plt.colorbar(label='Pixel Difference')
plt.title(f' Gauss Blur: 2D Difference Map (Max Diff: {np.max(diff)})')
plt.show()

print("--------------------------")
print(f"Max abs diff : {max_diff}")
print(f"MSE: {mse}")
print(f"RMSE: {rmse}")
print(f"PSNR (dB): {psnr}")
print(f"SSIM: {ssim_val}")
print("--------------------------\n")
