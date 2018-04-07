from PIL import Image
import sys

inImage, outBin = sys.argv[1:3]

img = Image.open(inImage)

packed = ''
for x in range(img.width):
    for y in range(img.height):
        r,g,b = img.getpixel((x, y))[:3]
        packed += ''.join([chr(r), chr(g), chr(b)])

with open(outBin, 'w') as out:
    out.write(packed)
