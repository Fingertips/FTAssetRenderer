#import "FTAssetRendererTests.h"

@implementation FTAssetRendererTests

- (void)setUp
{
    [super setUp];
    [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    self.renderer = [[FTAssetRenderer alloc] initWithURL:nil];
}

- (void)tearDown
{
    [super tearDown];
    self.renderer = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[FTAssetRenderer cacheDirectory]
                                               error:NULL];
}

#pragma mark - caching

- (void)testCachesInSpecificCacheDirectory
{
    NSString *expected = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    expected = [expected stringByAppendingPathComponent:@"__FTAssetRenderer_Cache__"];
    XCTAssertEqualObjects(expected, [FTAssetRenderer cacheDirectory]);
}

- (void)testChangesCachePathBasedOnIdentifier
{
    NSString *path = [self.renderer cachePathWithIdentifier:@"normal"];
    XCTAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:@"normal"]);

    NSString *newPath = [self.renderer cachePathWithIdentifier:@"highlighted"];
    XCTAssertFalse([path isEqualToString:newPath]);
    XCTAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:@"highlighted"]);
}

@end
