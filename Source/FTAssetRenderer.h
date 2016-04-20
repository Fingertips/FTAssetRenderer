#import <UIKit/UIKit.h>

@class FTPDFAssetRenderer;


NS_ASSUME_NONNULL_BEGIN

@interface FTAssetRenderer : NSObject

@property (nonatomic, readonly, nullable) NSURL *URL;
@property (nonatomic, strong, nullable) UIColor *targetColor;
@property (nonatomic, assign) BOOL cache;
@property (nonatomic, readonly) CGSize targetSize;

+ (NSString *)cacheDirectory;

- (instancetype)initWithURL:(NSURL * _Nullable)URL;

// When caching is enabled and the image is used as a mask then an identifier
// *has* to be specified.
//
// For example, when generating button icons, you could use an identifier like
// `normal` or `highlighted`, depending on the state.
- (UIImage *)image;
- (UIImage *)imageWithCacheIdentifier:(nullable NSString *)identifier;

@end


@interface FTAssetRenderer (FTPrivate)

- (void)drawImageInContext:(CGContextRef)context;
- (void)drawTargetColorInContext:(CGContextRef)context;

- (NSString *)cachePathWithIdentifier:(NSString * _Nullable)identifier;
- (void)canCacheWithIdentifier:(NSString * _Nullable)identifier;
- (NSString *)cacheRawFilenameWithIdentifier:(NSString * _Nullable)identifier;

@end


NS_ASSUME_NONNULL_END
