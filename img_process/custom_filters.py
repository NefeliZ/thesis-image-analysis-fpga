#
# custom implementation of image filters
#
import numpy as np
import copy
#
#############


def sobel_3x3_filter(image, width, height): #image as array?

    windowSize = 3 # sobel filter with 3x3 window size

    #filter matrixes
    kx = np.array([[1, 0, -1], [2, 0, -2], [1, 0, -1]], dtype=np.int32)
    ky = np.array([[1, 2, 1],  [0, 0, 0],  [-1, -2, -1]], dtype=np.int32)

    #init filtered img as black(0)
    filtered_img = np.zeros((height-2, width-2), dtype=np.uint8) #unsigned 8bit int - 0to255 grayscale
    #filtered_img = copy.deepcopy(image)

    # !!! array[row_index][column_index] && row=height col=width
    for row in range(1, height-1): #run from 1 until end-1 to leave padd out|| same with verilog 
        for col in range(1, width-1): #run from 1 until end-1 to leave padd out|| same with verilog 

            #take the 3x3 window
            #signed 32bit int - correction for multiplying with neg(-)
            img_win = image[row-1:row+2, col-1:col+2].astype(np.int32) 
            #arr[row-1:row+2, col-1:col+2] => row-1 to row+1, col-1 to col+1 => 9 vals
            #if indexing like that outofbounds -> shows full array and no error

            #calculate gradients
            Gx = np.sum(img_win * kx)
            Gy = np.sum(img_win * ky)
            G = abs(Gx) + abs(Gy)

            #saturation of values - cutoff
            if G > 255: #max val
                G = 255
            elif G<0:
                G = 0

            #change center pixel in filtered img array
            filtered_img[row-1][col-1] = G #center is -1 from curr

        #crop padding out of final img
        #filtered_img = filtered_img[1:height-1 , 1:width-1]

    return filtered_img
######

def gaussian_blur_3x3(image, width, height): 

    windowSize = 3 # gaussian blur with 3x3 window size

    #pixel weights - depends on distance from center
    # they add up to 1 -> no change in brightness only blur
    weights = (1/16) * np.array( [[1, 2, 1], [2, 4, 2], [1, 2, 1]], dtype=np.float32)

    #init filtered img as black(0) -> 1st col and row will remain black
    filtered_img = np.zeros((height, width), dtype=np.uint8) #unsigned 8bit int - 0to255 grayscale
    #filtered_img = copy.deepcopy(image)

    # !!! array[row_index][column_index] && row=height col=width
    for row in range(0, height-2): #run until the end-2 so window fits
        for col in range(0, width-2): # run until the end-2 so window fits

            
            #take the 3x3 window
            img_win = image[row:row+3, col:col+3].astype(np.float32)

            #calculate center pixel value
            G = np.sum(weights*img_win)

            # round the float G -> will be cast to int array
            G = np.round(G)

            #saturation of values - cutoff
            if G > 255: #max val
                G = 255
            elif G<0:
                G = 0

            #change center pixel in filtered img array
            filtered_img[row+1][col+1] = np.uint8(G) # center = start+1 or end-1

    return filtered_img

#def blur_filter():