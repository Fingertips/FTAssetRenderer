#import "FTAssetRendererTests.h"

@implementation FTAssetRendererTests

- (void)setUp;
{
  [super setUp];
  [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:NULL];
  self.renderer = [[FTAssetRenderer alloc] initWithURL:nil];
}

- (void)tearDown;
{
  [super tearDown];
  self.renderer = nil;
  [[NSFileManager defaultManager] removeItemAtPath:[FTAssetRenderer cacheDirectory]
                                             error:NULL];
}

#pragma mark - caching

- (void)testCachesInSpecificCacheDirectory;
{
  NSString *expected = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
  expected = [expected stringByAppendingPathComponent:@"__FTAssetRenderer_Cache__"];
  STAssertEqualObjects(expected, [FTAssetRenderer cacheDirectory], nil);
}

- (void)testChangesCachePathBasedOnIdentifier;
{
  NSString *path = [self.renderer cachePathWithIdentifier:@"normal"];
  STAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:@"normal"], nil);

  NSString *newPath = [self.renderer cachePathWithIdentifier:@"highlighted"];
  STAssertFalse([path isEqualToString:newPath], nil);
  STAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:@"highlighted"], nil);
}

//- (void)testRaisesWhenUsedAsMaskAndCachingWithoutCacheIdentifier;
//{
  //self.renderer.targetColor = [UIColor redColor];

  //self.renderer.cache = NO;
  //STAssertNoThrow([self.renderer imageWithCacheIdentifier:nil], nil);

  //self.renderer.cache = YES;
  //STAssertThrowsSpecificNamed([self.renderer imageWithCacheIdentifier:nil], NSException, @"FTAssetRendererError", nil);
//}

@end
