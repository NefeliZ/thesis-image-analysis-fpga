#
# takes RGB image and turns it to grayscale
# checks if NxN filter fits exactly in img
# if not it adds border so it fits => new img dimensions
# converts values to binary
# puts in .txt to use as input to verilog
#
from PIL import Image
import cv2
import numpy as np
from PIL import Image, ImageOps


#file path
path = './image_pre-process/'

text_path = path + 'images-vals/struct_vals.txt'

#read image
img = cv2.imread(path +'images-vals/test_img.png') 

#show image - original
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

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
    out_img = cv2.copyMakeBorder(gray_img,0,x,0,y,cv2.BORDER_CONSTANT, value= 0)

else:
    out_img = gray_img
    

#get image size
(row, col) = out_img.shape[0:2] 

print('new img dimensions')
print(row)
print(col)

#var to change lines
k = 0

#file stuff - iterate by desired struct
with open(text_path, 'w') as text_file:
        
        #iterate through each pixel in the image
        for k in range(0,row-3):
            for i in range(0,col):
                for m in range (k, N+k):
                   
                    #gray img value to array
                    gray_value = out_img[m][i]
                    
                    #gray rbg to hex value
                    hex_value = format(gray_value, '02X')
                    
                    #convert to binary
                    hex_int = int(hex_value, 16)
                    binary = bin(hex_int)

                    #binary value to text file
                    text_file.write(f"{binary} ")
            k = k+1
            #new line in txt file
            text_file.write(f"\n")



'''
#test array to check numbers
test = [[0]*col]*row

for i in range(0, row):
     
    for j in range(0, col):
     
        test[i][j] = j


#print(test)
    
'''