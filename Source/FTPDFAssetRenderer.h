#import "FTAssetRenderer.h"

// This object is supposed to be short-lived, because an open PDF document can
// consume quite some memory.
@interface FTPDFAssetRenderer : FTAssetRenderer

@property (assign,   nonatomic) size_t sourcePageIndex;
@property (readonly, nonatomic) CGPDFPageRef sourcePage;
@property (assign,   nonatomic) CGSize targetSize;
@property (readonly, nonatomic) BOOL isMask;

- (void)fitSize:(CGSize)maxSize;
- (void)fitWidth:(CGFloat)targetWidth;
- (void)fitHeight:(CGFloat)targetHeight;

@end

@interface FTAssetRenderer (FTPDFAssetRenderer)

+ (FTPDFAssetRenderer *)rendererForPDFNamed:(NSString *)pdfName;

@end
