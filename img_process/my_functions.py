#
# various functions used in image manipulation
#
import numpy as np
import copy
from skimage.metrics import structural_similarity as ssim 
#
#############

#fix image size according to filter window size
# adds padding (black-0) so window fits exactly
def fix_im_size(windowSize, og_image, og_width, og_height):
    # fix size to fit NxN iteration
    if (og_width%windowSize != 0 or og_height%windowSize != 0):

        #check how many pixels to add 
        # (+ correct in case its 0 for one of the cases)
        x = (windowSize - (og_width % windowSize))%windowSize 
        y = (windowSize - (og_height % windowSize))%windowSize

        # fill extra with black (0)
        # np.pad((top, bottom), (left, right)) -> (row, col) -> (height, width) -> (y, x)
        image = np.pad(og_image, ((0, y), (0, x)), mode='constant', constant_values=0)


        width = og_width + x
        height = og_height + y

    else:
        image = og_image
        width = og_width
        height = og_height 

    return image, width, height


# metrics to compare image similarity
# MSE, RMSE, PSNR, SSIM
def compare_img_metrics(img1, img2, windowSize):

    #convert to avoid overflow
    I1 = img1.astype(np.float32)
    I2 = img2.astype(np.float32)

    #max diff
    diff = np.abs(I1 - I2)
    max_diff = np.max(diff)

    #mean squared error && root MSE - MSE & RMSE
    mse = np.mean((I1 - I2) ** 2)
    rmse = np.sqrt(mse)

    # peak signal-to-noise ration - PSNR
    # psnr = 20 * np.log10(max-possible-value) - np.log10(mse)
    if mse == 0: #if mse=0 -> log(mse)= infinite -> exactly same
        psnr = float('inf')
    else:
        psnr = 20 * np.log10(255.0) - 10* np.log10(mse)

    #structular similarity index - SSIM
    # structural_similarity(im1, im2, win_size, gredient, data_range ,full=bool)
    # full: return the full structural similarity image
    # returns: mssim : float - mean structural similarity index 
    # grad : ndarray -  gradient of the structural similarity between im1 and im2 (if gradient = true)
    # S : ndarray - full SSIM image (if full = true)
    ssim_val, ssim_img = ssim(img1, img2, full=True, data_range=255)

    #print("--------------------------")
    #print(f"Max abs diff : {max_diff}")
    #print(f"MSE: {mse}")
    #print(f"RMSE: {rmse}")
    #print(f"PSNR (dB): {psnr}")
    #print(f"SSIM: {ssim_val}")
    #print("--------------------------\n")

    return diff, max_diff, mse, rmse, psnr, ssim_val, ssim_img


