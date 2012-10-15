# FTAssetRenderer

Create image assets, at runtime, in _any_ color when used as mask and/or at _any_ resolution when it’s a PDF.


### Install

If you’re using [CocoaPods](https://github.com/CocoaPods/CocoaPods), add the following to your Podfile:

```ruby
pod 'FTAssetRenderer'
```

Otherwise, simply add the files from the `Source` dir to your project.


### Usage

If you have a bitmap image that’s used as a mask to generate images in different colors, then you can use it like so:

```objc
FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"my-icon" withExtension:@"png"];
renderer.targetColor = [UIColor redColor];
UIImage *result = [renderer imageWithCacheIdentifier:@"red"];
```

If, on the other hand, you have a vector based PDF image, you should generally indicate the size at which it should be rendered as well:

```objc
FTPDFAssetRenderer *renderer = [FTAssetRenderer rendererForPDFNamed:@"my-scalable-icon"];
renderer.targetColor = [UIColor blueColor];
renderer.targetSize = CGSizeMake(123, 456);
UIImage *result = [renderer imageWithCacheIdentifier:@"without-preserving-aspect-ratio"];
```

In the above example, an explicit width and height is given for the result image, which might lead to the image not preserving its original aspect ratio. To ensure the ratio is preserved, a few convience methods are available:

* `-[FTPDFAssetRenderer fitWidth:]` will make the result image as wide as the given width, while the height is based on it.
* `-[FTPDFAssetRenderer fitHeight:]` will make the result image as high as the given height, while the width is based on it.
* `-[FTPDFAssetRenderer fitSize:]` will make the image as large as possible, inside the bounding size, but without cropping any part of the image, thus only fully covering one of the two sides.

By default, the resulting image is cached on disk. For each different target color, a different cache identifier should be used. For instance, for controls you might use identifiers such as `normal`, `highlighted`, and `selected`.


### Acknowledgements

Based on work by:
* [Oliver Drobnik](https://github.com/Cocoanetics) - http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought
* [Nigel Timothy Barber](https://github.com/mindbrix) - https://github.com/mindbrix/UIImage-PDF
* [Jeffrey Sambells](https://github.com/iamamused) - http://jeffreysambells.com/2012/03/02/beating-the-20mb-size-limit-ipad-retina-displays
* [Ole Zorn](https://github.com/omz) - https://gist.github.com/1102091

Thanks to [Peter Steinberger](https://github.com/steipete) (of [PSPDFKit](http://pspdfkit.com) fame) for his invaluable advice during the creation of this library.
