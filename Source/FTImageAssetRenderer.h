#import "FTAssetRenderer.h"


NS_ASSUME_NONNULL_BEGIN

@interface FTImageAssetRenderer : FTAssetRenderer

@property (nonatomic, readonly, nullable) UIImage *sourceImage;

@end

@interface FTAssetRenderer (FTPDFAssetRenderer)

+ (FTImageAssetRenderer *)rendererForImageNamed:(NSString *)imageName withExtension:(NSString *)extName;

@end

NS_ASSUME_NONNULL_END
