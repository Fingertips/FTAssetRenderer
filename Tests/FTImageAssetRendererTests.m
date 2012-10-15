#import "FTImageAssetRendererTests.h"

@implementation FTImageAssetRendererTests

- (void)setUp;
{
  [super setUp];
  [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:NULL];
  self.renderer = [FTAssetRenderer rendererForImageNamed:@"restaurant-icon-mask" withExtension:@"png"];
  self.renderer.targetColor = [UIColor redColor];
}

- (void)tearDown;
{
  [super tearDown];
  self.renderer = nil;
  [[NSFileManager defaultManager] removeItemAtPath:[FTAssetRenderer cacheDirectory]
                                             error:NULL];
}

- (void)testConvenienceMethodLoadsImageAppropriateForScreenScale;
{
  NSString *filename = [[self.renderer.URL lastPathComponent] stringByDeletingPathExtension];
  int scale = (int)[[UIScreen mainScreen] scale];
  if (scale > 1) {
    STAssertTrue([filename hasSuffix:@"@2x"], nil);
  } else {
    STAssertFalse([filename hasSuffix:@"@2x"], nil);
  }
}

- (void)testReturnsImageOfExpectedSizeAndScale;
{
  UIImage *result = [self.renderer imageWithCacheIdentifier:@"test"];
  STAssertEquals(self.renderer.sourceImage.size, result.size, nil);
}

- (void)testCreatesExpectedSizeImageAtCachePath;
{
  NSString *path = [self.renderer cachePathWithIdentifier:@"test"];
  [self.renderer imageWithCacheIdentifier:@"test"];
  sleep(1.5); // lame, should check if file exists with timeout
  UIImage *result = [UIImage imageWithContentsOfFile:path];
  CGFloat scale = [[UIScreen mainScreen] scale];
  CGSize sourceSize = self.renderer.sourceImage.size;
  STAssertEquals(CGSizeMake(sourceSize.width * scale, sourceSize.height * scale), result.size, nil);
}

@end
