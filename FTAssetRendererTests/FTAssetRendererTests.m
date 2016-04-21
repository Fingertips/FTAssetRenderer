#import "FTAssetRendererTests.h"

@implementation FTAssetRendererTests

- (void)setUp
{
    [super setUp];
    [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"restaurant-icon-mask" withExtension:@"pdf"];
    self.renderer = [[FTAssetRenderer alloc] initWithURL:URL];
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

- (void)testCacheWithEmptyURL
{
    FTAssetRenderer *renderer = [[FTAssetRenderer alloc] initWithURL:nil];
    XCTAssertThrows([renderer assertCanCacheWithIdentifier:@"normal"]);
}

@end
