#import "FTPDFIconRenderer.h"

// From: https://gist.github.com/1209911
#import <CommonCrypto/CommonDigest.h>
static NSString *
FTPDFMD5String(NSString *input) {
  const char *cStr = [input UTF8String];
  unsigned char result[16];
  CC_MD5(cStr, strlen(cStr), result);
  return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                    result[0],  result[1],  result[2],  result[3],
                                    result[4],  result[5],  result[6],  result[7],
                                    result[8],  result[9],  result[10], result[11],
                                    result[12], result[13], result[14], result[15]];
}

@interface FTPDFIconRenderer () {
  CGPDFDocumentRef _document;
}
- (NSString *)cachePathWithIdentifier:(NSString *)identifier;
- (UIImage *)cachedImageAtPath:(NSString *)cachePath;
@end

@implementation FTPDFIconRenderer

+ (NSString *)cacheDirectory;
{
  static NSString *cacheDirectory;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"__FTPDFIconRenderer_CACHE__"];
    [[NSFileManager new] createDirectoryAtPath:cacheDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
  });
  return cacheDirectory;
}

#pragma mark - shortcut methods with mask color

+ (FTPDFIconRenderer *)iconRendererForPDFNamed:(NSString *)pdfName
                                   targetColor:(UIColor *)targetColor;
{
  NSURL *URL = [[NSBundle mainBundle] URLForResource:pdfName withExtension:@"pdf"];
  if (URL) {
    FTPDFIconRenderer *renderer = [[self alloc] initWithPDF:URL];
    renderer.targetColor = targetColor;
    return renderer;
  }
  return nil;
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                  targetSize:(CGSize)targetSize
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;
{
  FTPDFIconRenderer *renderer = [self iconRendererForPDFNamed:pdfName
                                                  targetColor:targetColor];
  if (renderer) {
    renderer.targetSize = targetSize;
    return [renderer imageWithCacheIdentifier:identifier];
  }
  return nil;
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                 targetWidth:(CGFloat)targetWidth
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;
{
  FTPDFIconRenderer *renderer = [self iconRendererForPDFNamed:pdfName
                                                  targetColor:targetColor];
  if (renderer) {
    [renderer fitWidth:targetWidth];
    return [renderer imageWithCacheIdentifier:identifier];
  }
  return nil;
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                targetHeight:(CGFloat)targetHeight
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;
{
  FTPDFIconRenderer *renderer = [self iconRendererForPDFNamed:pdfName
                                                  targetColor:targetColor];
  if (renderer) {
    [renderer fitHeight:targetHeight];
    return [renderer imageWithCacheIdentifier:identifier];
  }
  return nil;
}

#pragma mark - shortcut methods without mask color

+ (FTPDFIconRenderer *)iconRendererForPDFNamed:(NSString *)pdfName;
{
  return [self iconRendererForPDFNamed:pdfName targetColor:nil];
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                  targetSize:(CGSize)targetSize;
{
  return [self imageOfPDFNamed:pdfName
                    targetSize:targetSize
                   targetColor:nil
                withIdentifier:nil];
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                 targetWidth:(CGFloat)targetWidth;
{
  return [self imageOfPDFNamed:pdfName
                   targetWidth:targetWidth
                   targetColor:nil
                withIdentifier:nil];
}

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                targetHeight:(CGFloat)targetHeight;
{
  return [self imageOfPDFNamed:pdfName
                  targetHeight:targetHeight
                   targetColor:nil
                withIdentifier:nil];
}

#pragma mark - init / dealloc

- (void)dealloc;
{
  CGPDFDocumentRelease(_document);
}

// Don't open the PDF yet, as the user may want the actual work to be done on a
// background thread.
//
// TODO: Check if opening the PDF actualy does any work.
- (id)initWithPDF:(NSURL *)URL;
{
  if ((self = [super init])) {
    _cache = YES;
    _document = NULL;
    _sourcePageIndex = 1;
    _targetSize = CGSizeZero;
    _URL = URL;
  }
  return self;
}

#pragma mark - general accessors

- (CGPDFDocumentRef)document;
{
  if (_document == NULL) {
    _document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.URL);
  }
  return _document;
}

- (CGPDFPageRef)sourcePage;
{
  return CGPDFDocumentGetPage(self.document, self.sourcePageIndex);
}

- (CGRect)mediaRectOfSourcePage;
{
  return CGPDFPageGetBoxRect(self.sourcePage, kCGPDFCropBox);
}

- (BOOL)isMask;
{
  return self.targetColor != nil;
}

#pragma mark - target size accessors

// Returns the full size of the source page, unless one is specified.
- (CGSize)targetSize;
{
  if (CGSizeEqualToSize(_targetSize, CGSizeZero)) {
    return self.mediaRectOfSourcePage.size;
  }
  return _targetSize;
}

- (void)fitSize:(CGSize)size;
{
  CGRect mediaRect = self.mediaRectOfSourcePage;
  CGFloat scaleFactor = MAX(mediaRect.size.width / size.width, mediaRect.size.height / size.height);
  self.targetSize = CGSizeMake(ceilf(mediaRect.size.width / scaleFactor), ceilf(mediaRect.size.height / scaleFactor));
}

- (void)fitWidth:(CGFloat)targetWidth;
{
  CGRect mediaRect = self.mediaRectOfSourcePage;
  CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
  self.targetSize = CGSizeMake(targetWidth, ceilf(targetWidth / aspectRatio));
}

- (void)fitHeight:(CGFloat)targetHeight;
{
  CGRect mediaRect = self.mediaRectOfSourcePage;
  CGFloat aspectRatio = mediaRect.size.width / mediaRect.size.height;
  self.targetSize = CGSizeMake(ceilf(targetHeight * aspectRatio), targetHeight);
}

#pragma mark - drawing

- (UIImage *)image;
{
  return [self imageWithCacheIdentifier:nil];
}

- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier;
{
  if (self.cache && self.isMask && identifier == nil) {
    [NSException raise:@"FTPDFIconRendererCacheError"
                format:@"A PDF used as mask can’t be cached without a cache identifier."];
  }

  UIImage *image = nil;
  NSString *cachePath = nil;

  if (self.cache) {
    cachePath = [self cachePathWithIdentifier:identifier];
    image = [self cachedImageAtPath:cachePath];
    if (image) return image;
  }

  CGSize targetSize = self.targetSize;

  UIGraphicsBeginImageContextWithOptions(targetSize, false, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();

  // Flip context, making bottom-left the origin.
  CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, targetSize.height));

  // Draw page scaled to the target size.
  CGContextSaveGState(context);
  CGPDFPageRef page = self.sourcePage;
  CGRect mediaRect = self.mediaRectOfSourcePage;
  CGContextScaleCTM(context, targetSize.width / mediaRect.size.width, targetSize.height / mediaRect.size.height);
  CGContextTranslateCTM(context, -mediaRect.origin.x, -mediaRect.origin.y);
  CGContextDrawPDFPage(context, page);
  CGContextRestoreGState(context);

  // Use the target color to fill the image drawn from the PDF page.
  if (self.isMask) {
    CGContextSetFillColorWithColor(context, self.targetColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, CGRectMake(0, 0, targetSize.width, targetSize.height));
  }

  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  if (self.cache) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
      [UIImagePNGRepresentation(image) writeToFile:cachePath atomically:NO];
    });
  }

  return image;
}

#pragma mark - caching

- (UIImage *)cachedImageAtPath:(NSString *)cachePath;
{
  UIImage *image = nil;

  NSData *data = [NSData dataWithContentsOfFile:cachePath];
  if (data) {
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreateWithPNGDataProvider(provider, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    image = [UIImage imageWithCGImage:imageRef
                                scale:[[UIScreen mainScreen] scale]
                          orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
  }

  return image;
}

- (NSString *)cachePathWithIdentifier:(NSString *)identifier;
{
  NSDictionary *attributes = [[NSFileManager new] attributesOfItemAtPath:self.URL.path
                                                                   error:NULL];
  // TODO
  // * Check if this is really reliable, as we have no guarantee the targetSize
  //   values are integers.
  // * The method in UIImage+PDF multiplied the size by the scaleFactor, but I
  //   see no need for the facor at all, because this is cached on a retina
  //   device or not, so it will always be the same.
  NSString *cachePath = [NSString stringWithFormat:@"%@-%@-%@-%@-%zd-%@",
                                                   [self.URL lastPathComponent],
                                                   attributes[NSFileSize],
                                                   attributes[NSFileModificationDate],
                                                   NSStringFromCGSize(self.targetSize),
                                                   self.sourcePageIndex,
                                                   identifier ?: @""];
  cachePath = FTPDFMD5String(cachePath);
  cachePath = [[[self class] cacheDirectory] stringByAppendingPathComponent:cachePath];
  cachePath = [cachePath stringByAppendingPathExtension:@"png"];
  return cachePath;
}

@end
