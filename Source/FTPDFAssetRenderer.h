#import "FTAssetRenderer.h"


NS_ASSUME_NONNULL_BEGIN

// This object is supposed to be short-lived, because an open PDF document can consume quite some memory.
@interface FTPDFAssetRenderer : FTAssetRenderer

@property (nonatomic, assign) size_t sourcePageIndex;
@property (nonatomic, readonly) CGPDFPageRef sourcePage;
@property (nonatomic, assign) CGSize targetSize;
@property (nonatomic, readonly) BOOL isMask;

- (instancetype)initWithURL:(NSURL * _Nullable)URL NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

- (void)fitSize:(CGSize)maxSize;
- (void)fitWidth:(CGFloat)targetWidth;
- (void)fitHeight:(CGFloat)targetHeight;

@end

@interface FTAssetRenderer (FTPDFAssetRenderer)

+ (FTPDFAssetRenderer *)rendererForPDFNamed:(NSString *)pdfName;

@end

NS_ASSUME_NONNULL_END
