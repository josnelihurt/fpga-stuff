from PIL import Image
from array import array
import numpy as np
import os

fileName = 'goku.bmp'

im = Image.open(fileName)
pix = im.load()
w, h = im.size

pixels = np.zeros(w*h, dtype=np.uint16)  # 0xff,  dtype=np.int8)
z=0
for j in range(h):
	for i in range(w):
		r,g,b=pix[i, j]
		pixels[z] = ((int(r / 255 * 31) << 11) | (int(g / 255 * 63) << 5) | (int(b / 255 * 31)))  # ((r&0x1f)<<11) | ((g&0x3f)<<5) | ((b&0x1f)<<0)
		#print(pixels[z])
		z = z+1
outputFileName = fileName + '.bin'
pixels.astype('int16').tofile(outputFileName)
cmd = 'objcopy --input-target=binary --output-target=ihex ' + \
	outputFileName + ' ' + fileName + '.hex'
os.system(cmd)
os.system('cat ' + fileName + '.hex')
