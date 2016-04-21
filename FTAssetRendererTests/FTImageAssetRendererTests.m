#import "FTImageAssetRendererTests.h"

@implementation FTImageAssetRendererTests

- (void)setUp
{
    [super setUp];
    [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    self.renderer = [FTAssetRenderer rendererForImageNamed:@"restaurant-icon-mask" withExtension:@"png"];
    self.renderer.targetColor = [UIColor redColor];
}

- (void)tearDown
{
    [super tearDown];
    self.renderer = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[FTAssetRenderer cacheDirectory]
                                               error:NULL];
}

- (void)testConvenienceMethodLoadsImageAppropriateForScreenScale
{
    NSString *filename = [[self.renderer.URL lastPathComponent] stringByDeletingPathExtension];
    int scale = (int)[[UIScreen mainScreen] scale];
    if (scale > 1) {
        XCTAssertTrue([filename hasSuffix:@"@2x"]);
    } else {
        XCTAssertFalse([filename hasSuffix:@"@2x"]);
    }
}

- (void)testReturnsImageOfExpectedSizeAndScale
{
    UIImage *result = [self.renderer imageWithCacheIdentifier:@"test"];
    XCTAssertTrue(CGSizeEqualToSize(self.renderer.sourceImage.size, result.size));
}

- (void)testCreatesExpectedSizeImageAtCachePath
{
    NSString *path = [self.renderer cachePathWithIdentifier:@"test"];
    [self.renderer imageWithCacheIdentifier:@"test"];
    sleep(2); // lame, should check if file exists with timeout
    UIImage *result = [UIImage imageWithContentsOfFile:path];
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize sourceSize = self.renderer.sourceImage.size;
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(sourceSize.width * scale, sourceSize.height * scale), result.size));
}

@end
