#
# takes RGB image and turns it to grayscale
# checks if NxN filter fits exactly in img
# if not it adds border so it fits => new img dimensions
# converts values to binary
# puts in .txt to use as input to verilog
# each line has N^2 pixel vals -> window size
# works for square img
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps
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

print('init img dimensions')
print(row)
print(col)

#N = size of mask matrix for each filer
N = 3

# fix size to fit NxN iteration
if (col%N != 0 or row%N != 0):

    #check if should add pixels
    x = N - col%N
    y = N - row%N

    #expand image - add border   
    # cv2.copyMakeBorder( img, top, bottom, left, right, bordertype, value) 
    # x-> col => right || y-> row => bottom
    out_img = cv2.copyMakeBorder(gray_img, 0, y, 0, x, cv2.BORDER_CONSTANT, value=0)

else:
    out_img = gray_img
    

#get image size
(row, col) = out_img.shape[0:2] 

print('new img dimensions')
print(row)
print(col)


#file stuff - iterate by desired struct
with open(text_path, 'w') as text_file:
        
        #iterate through each pixel in the image
        for k in range(0,row-N):
            for i in range(0,col-N):
                window = out_img[k:k+N, i:i+N]

                #gray rbg to binary value
                for j in range(0, len(window.flatten())):
                    win_binary = format(window.flatten()[j], '08b') #steady 8bit width
                    
                    #binary value to text file
                    text_file.write(f"{win_binary} ")

                #new line in txt file
                text_file.write(f"\n")
