## Library differences

GD, Image::Magick and Imager use different technics when reducing the size of an image. Because of this the reduced image will not be exactly the same, and thus not have the same hash. That means that the hashes are not portable between the different backend libraries.

## Example

We start out with the Alyson_Hannigan_200512.jpg image
![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/Alyson_Hannigan_200512.jpg)

It gets reduced to 8x8 pixels:

| GD        | Image::Magick           | Imager |
| ------------- |-------------| -----|
| ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/gd_150.png) | ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/ImageMagick_150.png) | ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/Imager_150.png) |

The 8x8 pixel image get converted to gray scale:

| GD        | Image::Magick           | Imager |
| ------------- |-------------| -----|
| ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/gd_150_greyscale.png) | ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/ImageMagick_150_greyscale.png) | ![](https://github.com/runarbu/PerlImageHash/raw/master/eg/images/compared/Alyson_Hannigan_jpg/Imager_150_greyscale.png) |

As you can see, the different images differ slightly, and will thereby produce different hashes.

**Tip:** You can use the eg/print-reduced-image.pl script to print out the 8x8 pixel images shown here.
