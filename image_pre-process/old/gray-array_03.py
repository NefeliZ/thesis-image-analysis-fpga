# 
# dont know - dont work
#
from PIL import Image
import cv2
import numpy as np

#file path
path = 'C:\\workspace\\fusiko\\ptuxiaki\\img_project\\'

#read image
img = cv2.imread(path +'test_img.png') 

#show image
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 

#show image
#cv2.imshow('gray', gray_img) 
#cv2.waitKey(0) 

#save new image
cv2.imwrite(path+'gray_img.bmp', gray_img)

#get image size
(row, col) = gray_img.shape[0:2] 

print(row)
print(col)

text_path = path + 'img_values3.txt'

with open(text_path, 'w') as text_file:
        # Iterate through each pixel in the image
        for x in range(0,row):
            for y in range(0,col):
                
                # Convert RGB to grayscale by averaging the values
                gray_value = gray_img[x, y]

                # Write the grayscale value to the text file
                text_file.write(f"{gray_value} ")
            
            text_file.write(f"\n")