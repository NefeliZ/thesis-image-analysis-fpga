#
# takes RGB image and turns it to grayscale
# adds padding to img to not lose pixel info
# converts values to binary
# puts in .txt to use as input to verilog
# each line has 1 pixel bin val
# no winSize needed - works for all img shapes
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps
#
import sys
sys.path.append('C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process') #add path for py files
import my_functions
#############

### file path
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'

#######################################
#### file names
img_case = 'smeagol_'

win_size = '3x3'
#win_size = '5x5'

#pad_size = ''
pad_size = '_doublepad' #double padding for cascaded filters

text_path = path + img_case + 'bin_vals_' + win_size + pad_size + '.txt' 

og_img_path = path + img_case + 'test_img.png'
gray_img_path = path + img_case + 'gray_img.png'
padd_img_path = path + img_case + 'padd_img_' + win_size + pad_size + '.png'

#######################################
#### read image
img = cv2.imread(og_img_path) 

# show image
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#######################################
#### convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imwrite(gray_img_path, gray_img)

#### get image size
(row, col) = gray_img.shape[0:2] 
print(f'Original image dimensions: width/col= {col}, height/row= {row}')

#######################################
#### window size

if win_size == '3x3':
    N = 3
elif win_size == '5x5':
    N = 5

#### padding size
if pad_size == '_doublepad': #cascaded filters need double padding
    pad = int(((N-1)/2) * 2)
else:
    pad = int((N-1)/2)

#######################################
#### add padding - fix image size
out_img, width, height = my_functions.add_padd(gray_img, col, row, pad) #col=width, row=height
cv2.imwrite(padd_img_path, out_img)
print(f'new img dimensions: width/col= {width}, height/row= {height}')


#######################################
#### convert & write piels to file
with open(text_path, 'w') as text_file:
        #iterate through each pixel in the image
        for i in range(0, height):
            for j in range(0, width):
                pixel = out_img[i, j]

                #gray rbg to binary value
                pixel_binary = format(pixel, '08b') #steady 8bit width

                #binary value to text file
                text_file.write(f"{pixel_binary}\n")