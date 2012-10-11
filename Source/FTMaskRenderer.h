#import <UIKit/UIKit.h>

@interface FTMaskRenderer : NSObject

@property (readonly, nonatomic) NSURL *URL;
@property (assign,   nonatomic) UIColor *targetColor;
@property (assign,   nonatomic) BOOL cache;

+ (NSString *)cacheDirectory;

- (id)initWithURL:(NSURL *)URL;

- (CGSize)targetSize;

// When caching is enabled and the image is used as a mask then an identifier
// *has* to be specified.
//
// For example, when generating button icons, you could use an identifier like
// `normal` or `highlighted`, depending on the state.
- (UIImage *)image;
- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier;

// PRIVATE

- (void)drawImageInContext:(CGContextRef)context;
- (void)drawTargetColorInContext:(CGContextRef)context;
- (void)canCacheWithIdentifier:(NSString *)identifier;
- (NSString *)cacheRawFilenameWithIdentifier:(NSString *)identifier;

@end
