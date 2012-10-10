#import "FTPDFIconRendererTests.h"

// TODO
// * add portrait and landscape fixtures

@interface FTPDFIconRenderer (Private)
- (NSString *)cachePathWithIdentifier:(NSString *)identifier;
@end

@implementation FTPDFIconRendererTests

- (void)setUp;
{
  [super setUp];
  [[NSFileManager defaultManager] createDirectoryAtPath:[FTPDFIconRenderer cacheDirectory]
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:NULL];
  self.renderer = [FTPDFIconRenderer iconRendererForPDFNamed:@"restaurant-icon-mask"];
}

- (void)tearDown;
{
  [super tearDown];
  self.renderer = nil;
  [[NSFileManager defaultManager] removeItemAtPath:[FTPDFIconRenderer cacheDirectory]
                                             error:NULL];
}

#pragma - mark sizing

- (void)testByDefaultUsesMediaBoxSizeAsTarget;
{
  STAssertEquals(CGSizeMake(88, 88), self.renderer.targetSize, nil);
}

- (void)testFitsPDFWithinGivenSizeFillingShortestEdge;
{
  [self.renderer fitSize:CGSizeMake(100, 200)];
  STAssertEquals(CGSizeMake(100, 100), self.renderer.targetSize, nil);
  [self.renderer fitSize:CGSizeMake(300, 200)];
  STAssertEquals(CGSizeMake(200, 200), self.renderer.targetSize, nil);
}

- (void)testFitsPDFWithinGivenTargetWidth;
{
  [self.renderer fitWidth:100];
  STAssertEquals(CGSizeMake(100, 100), self.renderer.targetSize, nil);
}

- (void)testFitsPDFWithinGivenTargetHeight;
{
  [self.renderer fitHeight:100];
  STAssertEquals(CGSizeMake(100, 100), self.renderer.targetSize, nil);
}

#pragma mark - caching

- (void)testCachesInSpecificCacheDirectory;
{
  NSString *expected = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
  expected = [expected stringByAppendingPathComponent:@"__FTPDFIconRenderer_CACHE__"];
  STAssertEqualObjects(expected, [FTPDFIconRenderer cacheDirectory], nil);
}

- (void)testChangesCachePathBasedOnTargetSize;
{
  NSString *path = [self.renderer cachePathWithIdentifier:nil];
  STAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:nil], nil);

  self.renderer.targetSize = CGSizeMake(123, 456);
  NSString *newPath = [self.renderer cachePathWithIdentifier:nil];
  STAssertFalse([path isEqualToString:newPath], nil);
  STAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:nil], nil);
}

- (void)testChangesCachePathBasedOnSourcePageIndex;
{
  NSString *path = [self.renderer cachePathWithIdentifier:nil];
  STAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:nil], nil);

  self.renderer.sourcePageIndex = 2;
  NSString *newPath = [self.renderer cachePathWithIdentifier:nil];
  STAssertFalse([path isEqualToString:newPath], nil);
  STAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:nil], nil);
}

- (void)testChangesCachePathBasedOnIdentifier;
{
  NSString *path = [self.renderer cachePathWithIdentifier:@"normal"];
  STAssertEqualObjects(path, [self.renderer cachePathWithIdentifier:@"normal"], nil);

  NSString *newPath = [self.renderer cachePathWithIdentifier:@"highlighted"];
  STAssertFalse([path isEqualToString:newPath], nil);
  STAssertEqualObjects(newPath, [self.renderer cachePathWithIdentifier:@"highlighted"], nil);
}

- (void)testRaisesWhenUsedAsMaskAndCachingWithoutCacheIdentifier;
{
  self.renderer.targetColor = [UIColor redColor];

  self.renderer.cache = NO;
  STAssertNoThrow([self.renderer imageWithCacheIdentifier:nil], nil);

  self.renderer.cache = YES;
  STAssertThrowsSpecificNamed([self.renderer imageWithCacheIdentifier:nil], NSException, @"FTPDFIconRendererCacheError", nil);
}

#pragma mark - drawing

- (void)testReturnsImageOfExpectedSizeAndScale;
{
  self.renderer.targetSize = CGSizeMake(100, 50);
  STAssertEquals(CGSizeMake(100, 50), [self.renderer image].size, nil);
}

- (void)testCreatesExpectedSizeImageAtCachePath;
{
  self.renderer.targetSize = CGSizeMake(100, 50);
  NSString *path = [self.renderer cachePathWithIdentifier:nil];
  [self.renderer image];
  sleep(1); // lame, should check if file exists with timeout
  UIImage *image = [UIImage imageWithContentsOfFile:path];
  CGFloat scale = [[UIScreen mainScreen] scale];
  STAssertEquals(CGSizeMake(100 * scale, 50 * scale), image.size, nil);
}

@end
