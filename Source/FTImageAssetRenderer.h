#import "FTAssetRenderer.h"

@interface FTImageAssetRenderer : FTAssetRenderer

@property (readonly, nonatomic) UIImage *sourceImage;

@end

@interface FTAssetRenderer (FTPDFAssetRenderer)

+ (FTImageAssetRenderer *)rendererForImageNamed:(NSString *)imageName withExtension:(NSString *)extName;

@end
