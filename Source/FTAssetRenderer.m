#import "FTAssetRenderer.h"
#import "TargetConditionals.h"

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

@interface FTAssetRenderer ()

- (NSString *)cachePathWithIdentifier:(NSString *)identifier;
- (UIImage *)cachedImageAtPath:(NSString *)cachePath;

@end

@implementation FTAssetRenderer

- (id)initWithURL:(NSURL *)URL;
{
  if ((self = [super init])) {
    _URL = URL;
    _cache = YES;
  }
  return self;
}

// Should be overriden by subclass.
- (CGSize)targetSize;
{
  return CGSizeZero;
}

#pragma mark - drawing

- (UIImage *)image;
{
  return [self imageWithCacheIdentifier:nil];
}

- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier;
{
  if (self.cache) [self canCacheWithIdentifier:identifier];

  UIImage *image = nil;
  NSString *cachePath = nil;

  if (self.cache) {
    cachePath = [self cachePathWithIdentifier:identifier];
    image = [self cachedImageAtPath:cachePath];
    if (image) return image;
  }

  // Setup context for target size and with main screen scale factor.
  CGSize targetSize = self.targetSize;
  UIGraphicsBeginImageContextWithOptions(targetSize, false, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  // Flip context, making bottom-left the origin.
  CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, targetSize.height));

  [self drawImageInContext:context];
  [self drawTargetColorInContext:context];

  image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  if (self.cache) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
      [UIImagePNGRepresentation(image) writeToFile:cachePath atomically:NO];
    });
  }

  return image;
}

- (void)drawImageInContext:(CGContextRef)context;
{
  [NSException raise:@"AbstractClassError"
              format:@"This class is supposed to be subclassed."];
}

- (void)drawTargetColorInContext:(CGContextRef)context;
{
  CGContextSetFillColorWithColor(context, self.targetColor.CGColor);
  CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
  CGSize targetSize = self.targetSize;
  CGContextFillRect(context, CGRectMake(0, 0, targetSize.width, targetSize.height));
}

#pragma mark - caching

+ (NSString *)cacheDirectory;
{
  static NSString *cacheDirectory;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"__FTAssetRenderer_Cache__"];
    [[NSFileManager new] createDirectoryAtPath:cacheDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
  });
  return cacheDirectory;
}

- (void)canCacheWithIdentifier:(NSString *)identifier;
{
  if (identifier == nil) {
    [NSException raise:@"FTAssetRendererError"
                format:@"A masked result can’t be cached without a cache identifier."];
  } else if (self.targetColor == nil) {
    [NSException raise:@"FTAssetRendererError"
                format:@"Can’t produce an image from a mask without a target color."];
  }
}

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

- (NSString *)cacheRawFilenameWithIdentifier:(NSString *)identifier;
{
  NSDictionary *attributes = [[NSFileManager new] attributesOfItemAtPath:self.URL.path
                                                                   error:NULL];
  NSString *filename = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
                                                  [self.URL lastPathComponent],
                                                  attributes[NSFileSize],
                                                  attributes[NSFileModificationDate],
                                                  NSStringFromCGSize(self.targetSize),
                                                  identifier ?: @""];
  return filename;
}

- (NSString *)cachePathWithIdentifier:(NSString *)identifier;
{
  NSString *cachePath = [self cacheRawFilenameWithIdentifier:identifier];
#if TARGET_IPHONE_SIMULATOR
  // On the simulator, the cache dir is shared between retina and non-retina
  // devices, so include the device's main screen scale factor to ensure the
  // right dimensions are used per device.
  cachePath = [NSString stringWithFormat:@"%@-%f", cachePath, [[UIScreen mainScreen] scale]];
#endif
  cachePath = FTPDFMD5String(cachePath);
  cachePath = [[[self class] cacheDirectory] stringByAppendingPathComponent:cachePath];
  cachePath = [cachePath stringByAppendingPathExtension:@"png"];
  return cachePath;
}

@end
