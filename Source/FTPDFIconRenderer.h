// Based on work by:
// * Nigel Timothy Barber - https://github.com/mindbrix/UIImage-PDF
// * Jeffrey Sambells - http://jeffreysambells.com/2012/03/02/beating-the-20mb-size-limit-ipad-retina-displays
// * Ole Zorn - https://gist.github.com/1102091

#import "FTMaskRenderer.h"

// This object is supposed to be short-lived, because an open PDF document can
// consume quite some memory.
@interface FTPDFIconRenderer : FTMaskRenderer

@property (assign,   nonatomic) size_t sourcePageIndex;
@property (readonly, nonatomic) CGPDFPageRef sourcePage;
@property (assign,   nonatomic) CGSize targetSize;
@property (readonly, nonatomic) BOOL isMask;

+ (FTPDFIconRenderer *)iconRendererForPDFNamed:(NSString *)pdfName;
+ (FTPDFIconRenderer *)iconRendererForPDFNamed:(NSString *)pdfName
                                   targetColor:(UIColor *)targetColor;

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                     fitSize:(CGSize)maxSize;
+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                     fitSize:(CGSize)maxSize
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                 targetWidth:(CGFloat)targetWidth;
+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                 targetWidth:(CGFloat)targetWidth
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;

+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                targetHeight:(CGFloat)targetHeight;
+ (UIImage *)imageOfPDFNamed:(NSString *)pdfName
                targetHeight:(CGFloat)targetHeight
                 targetColor:(UIColor *)targetColor
              withIdentifier:(NSString *)identifier;

- (void)fitSize:(CGSize)maxSize;
- (void)fitWidth:(CGFloat)targetWidth;
- (void)fitHeight:(CGFloat)targetHeight;

@end
