#import "FTImageMaskRenderer.h"

@implementation FTImageMaskRenderer

@synthesize sourceImage = _sourceImage;

- (UIImage *)sourceImage;
{
  if (!_sourceImage) {
    _sourceImage = [[UIImage alloc] initWithContentsOfFile:self.URL.path];
  }
  return _sourceImage;
}

- (CGSize)targetSize;
{
  return self.sourceImage.size;
}

- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier;
{
  if (self.sourceImage == nil) {
    [NSException raise:@"FTPDFIconRendererCacheError"
                format:@"Can’t render an image without a source image."];
  }
  return [super imageWithCacheIdentifier:identifier];
}

- (void)drawImageInContext:(CGContextRef)context;
{
  UIImage *source = self.sourceImage;
  CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
  CGContextClipToMask(context, rect, [source CGImage]);
}

@end
