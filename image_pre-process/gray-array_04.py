#
# takes RGB image and turns it to grayscale
# converts values to HEX
# puts in .txt and .hex value to use as input to verilog
# (no binary used here)
#
from PIL import Image
import cv2
import numpy as np

#file path
path = './image_pre-process/'

#read image
img = cv2.imread(path +'images-vals/test_img.png') 

#show image - original
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 

#show image - grayscale
#cv2.imshow('gray', gray_img) 
#cv2.waitKey(0) 

#save new image
cv2.imwrite(path+'images-vals/gray_img.bmp', gray_img)

#get image size
(row, col) = gray_img.shape#[0:2] 

#print(row)
#print(col)

text_path_txt = path + 'images-vals/img_values.txt'
text_path_hex = path + 'images-vals/img_values.hex'


#file stuff
with open(text_path_txt, 'w') as text_file:
    with open(text_path_hex, 'w') as hex_file:
        
        #iterate through each pixel in the image
        for x in range(0,row):
            for y in range(0,col):
                
                #img value to array
                gray_value = gray_img[x, y]

                #gray rbg to hex value
                hex_value = format(gray_value, '02X')

                #hex to number
                hex_int = int(hex_value, 16)
                
                #hex num to binary
                #binary_val = bin(hex_int)

                #hex value to text file
                text_file.write(f"{hex_value} ")
                hex_file.write(f"{hex_value} ") #put to .hex file too
                
            #new line in txt file
            text_file.write(f"\n")
            hex_file.write(f"\n") # .hex file too