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
import custom_filters
#############

#file path
path = 'C:/workspace/fysiko_apth/ptuxiaki/general-code/img_process/files/'

text_path = path + 'bin_vals_3x3.txt'
#text_path = path + 'bin_vals_5x5.txt'

gray_img_path = path + 'gray_img.png'

#read image
img = cv2.imread(path +'test_img.png') 

#show image - original
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imwrite(gray_img_path, gray_img)

#get image size
(row, col) = gray_img.shape[0:2] 
print(f'init img dimensions: width/col= {col}, height/row= {row}')

# change image size - add padding
out_img, width, height = my_functions.add_padd(gray_img, col, row) #col=width, row=height
print(f'new img dimensions: width/col= {width}, height/row= {height}')


#file stuff - iterate by desired struct
with open(text_path, 'w') as text_file:
        #iterate through each pixel in the image
        for i in range(0, height):
            for j in range(0, width):
                pixel = out_img[i, j]

                #gray rbg to binary value
                pixel_binary = format(pixel, '08b') #steady 8bit width
                    
                #binary value to text file
                text_file.write(f"{pixel_binary}\n")