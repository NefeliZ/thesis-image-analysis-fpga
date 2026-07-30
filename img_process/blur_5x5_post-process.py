# 
# box blur - 5x5 window
# takes verilog output
# pixel vals affter sobel filter - 1 pixel per line
# recreates image
# works for square img
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps
import os
import matplotlib.pyplot as plt
#############

#file path
path = './img_process/files/'

verilog_input_path = path + "verilog_out_blur_5x5.txt"
verilog_img_recreate_path = path + 'verilog_rec_blur_5x5.png'
og_img_path = path + 'test_img.png'
gray_img_path = path + 'gray_img.png'
py_img_filter_path = path + 'py_img_blur_5x5.png'

# window size
N = 5

# extract size of img 
# suppose img is square
with open(verilog_input_path, 'r') as f:
    file_size = len(f.readlines())

Vrow = np.sqrt(file_size)
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
#cv2.imshow('recrete from verilog code - sobel 1win 3x3', verilog_img_recreate) 
#cv2.waitKey(0)

# keep img for calcs
verilog_img_recreate = cv2.imread(verilog_img_recreate_path, cv2.IMREAD_GRAYSCALE)

#(Vrow, Vcol) = verilog_img_recreate.shape[0:2]

## apply filter with python
#load gray og image
gray_img = cv2.imread(gray_img_path, cv2.IMREAD_GRAYSCALE)
#gray_img = cv2.imread(og_img_path, cv2.COLOR_BGR2GRAY)

#check size & crop
(Prow, Pcol) = gray_img.shape[0:2]
Vrow = int(Vrow)
Vcol = int(Vcol)

if Prow > Vrow and Pcol> Vcol:
    gray_crop = gray_img[0:Vrow, 0:Vcol]
elif Prow > Vrow and not(Pcol> Vcol): 
    gray_crop = gray_img[0:Vrow, 0:Pcol]
elif not(Prow > Vrow) and Pcol > Vcol: 
    gray_crop = gray_img[0:Prow, 0:Vcol]

(Crow, Ccol) = gray_crop.shape[0:2]

# cv2.boxFilter(img, ddepth, (width, height), normalize=False)
blured_img = cv2.boxFilter(gray_crop, -1, (N, N), normalize=True)
cv2.imwrite(py_img_filter_path, blured_img)

# keep img for calcs
py_img_filter = cv2.imread(py_img_filter_path, cv2.IMREAD_GRAYSCALE)

# calc difference of ver & py filter img
diff = cv2.absdiff(verilog_img_recreate, py_img_filter)
max_diff = np.max(diff)

diff2 = verilog_img_recreate - py_img_filter
#plot difference 
#plt.figure(figsize=(6, 6))

plt.imshow(diff, cmap='hot')
plt.colorbar(label='Pixel Difference')
plt.title(f'2D Difference Map (Max Diff: {np.max(diff)})')
plt.show()
