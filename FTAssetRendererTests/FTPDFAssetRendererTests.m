#import "FTPDFAssetRendererTests.h"

// TODO
// * add portrait and landscape fixtures

@implementation FTPDFAssetRendererTests

- (void)setUp
{
    [super setUp];
    [[NSFileManager defaultManager] createDirectoryAtPath:[FTAssetRenderer cacheDirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    self.renderer = [FTAssetRenderer rendererForPDFNamed:@"restaurant-icon-mask"];
}

- (void)tearDown
{
    [super tearDown];
    self.renderer = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[FTAssetRenderer cacheDirectory]
                                               error:NULL];
}

#pragma - mark sizing

- (void)testByDefaultUsesMediaBoxSizeAsTarget
{
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(88, 88), self.renderer.targetSize));
}

- (void)testFitsPDFWithinGivenSizeFillingShortestEdge
{
    [self.renderer fitSize:CGSizeMake(100, 200)];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(100, 100), self.renderer.targetSize));
    [self.renderer fitSize:CGSizeMake(300, 200)];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(200, 200), self.renderer.targetSize));
}

- (void)testFitsPDFWithinGivenTargetWidth
{
    [self.renderer fitWidth:100];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(100, 100), self.renderer.targetSize));
}

- (void)testFitsPDFWithinGivenTargetHeight
{
    [self.renderer fitHeight:100];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(100, 100), self.renderer.targetSize));
}

#pragma mark - caching

- (void)testChangesCachePathBasedOnTargetSize
{
    NSString *path = [self.renderer cachePathWithIdentifier:nil];
    XCTAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:nil]);

    self.renderer.targetSize = CGSizeMake(123, 456);
    NSString *newPath = [self.renderer cachePathWithIdentifier:nil];
    XCTAssertFalse([path isEqualToString:newPath]);
    XCTAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:nil]);
}

- (void)testChangesCachePathBasedOnSourcePageIndex
{
    NSString *path = [self.renderer cachePathWithIdentifier:nil];
    XCTAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:nil]);

    self.renderer.sourcePageIndex = 2;
    NSString *newPath = [self.renderer cachePathWithIdentifier:nil];
    XCTAssertFalse([path isEqualToString:newPath]);
    XCTAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:nil]);
}

- (void)testRaisesWhenUsedAsMaskAndCachingWithoutCacheIdentifier
{
    self.renderer.targetColor = [UIColor redColor];

    self.renderer.cache = NO;
    XCTAssertNoThrow([self.renderer imageWithCacheIdentifier:nil]);

    self.renderer.cache = YES;
    XCTAssertThrowsSpecificNamed([self.renderer imageWithCacheIdentifier:nil], NSException, @"FTAssetRendererError");
}

#pragma mark - drawing

- (void)testReturnsImageOfExpectedSizeAndScale
{
    self.renderer.targetSize = CGSizeMake(100, 50);
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(100, 50), [self.renderer image].size));
}

- (void)testCreatesExpectedSizeImageAtCachePath
{
    self.renderer.targetSize = CGSizeMake(100, 50);
    NSString *path = [self.renderer cachePathWithIdentifier:nil];
    [self.renderer image];
    sleep(1.5); // lame, should check if file exists with timeout
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGFloat scale = [[UIScreen mainScreen] scale];
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(100 * scale, 50 * scale), image.size));
}

@end
