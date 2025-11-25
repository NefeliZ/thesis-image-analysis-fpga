import aspose.words as aw

#new way - did not need it - just exists for arxeio

#file path
path = 'C:\\workspace\\fusiko\\ptuxiaki\\img_project\\'

#read image
doc = aw.Document()
builder = aw.DocumentBuilder(doc)

img = builder.insert_image(path+"test_img.png")

img.image_data.save("gray_img2.bmp")