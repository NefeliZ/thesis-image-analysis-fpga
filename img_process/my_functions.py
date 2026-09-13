#
# various functions used in image manipulation
#
import numpy as np
import copy
from skimage.metrics import structural_similarity as ssim 
#
#############

# add padding around image to not lose pixel info in filter calcs
def add_padd(og_image, og_width, og_height, pad):

    # add padding (0) around image
    # np.pad((top, bottom), (left, right)) 

    # simple 3x3: 1 || cascaade3x3: 2 || simple5x5: 2 || cascade5x5: 4
    image = np.pad(og_image, ((pad, pad), (pad, pad)), mode='constant', constant_values=0)
    
    width = og_width + 2*pad
    height = og_height + 2*pad

    return image, width, height
#######

# metrics to compare image similarity
# MSE, RMSE, PSNR, SSIM
def compare_img_metrics(img1, img2):

    #convert to avoid overflow
    I1 = img1.astype(np.float32)
    I2 = img2.astype(np.float32)

    #max diff
    diff = np.abs(I1 - I2)
    max_diff = np.max(diff)

    #mean squared error && root MSE - MSE & RMSE
    mse = np.mean((I1 - I2) ** 2)
    rmse = np.sqrt(mse)

    # peak signal-to-noise ratio - PSNR
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
#######

