from PIL import Image
import cv2
import numpy as np

#file path
path = 'C:\\workspace\\fusiko\\ptuxiaki\\img project\\'

#read image
img = cv2.imread(path +'test_img.jpg') 

#show image
#cv2.imshow('Original', img) 
#cv2.waitKey(0) 

#convert to grayscale
gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) 

#show image
#cv2.imshow('gray', gray_img) 
#cv2.waitKey(0) 

#save new image
cv2.imwrite(path+'gray_img.jpg', gray_img)

#get image size
(row, col) = gray_img.shape[0:2] 

#str array to gather img data
pixels = [['' for c in range(0,col)] for r in range(0,row)] #str to be able to log in txt

#data from photo to array
for i in range(0,row): 
    for j in range(0,col):
        
        pixels[i][j] = str(gray_img[i][j])


#txt file writing
with open(path + 'img_values.txt', 'w') as file:
    for thing in pixels:
        file.write(f"{thing}\n")
