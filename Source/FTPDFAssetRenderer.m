#import "FTPDFAssetRenderer.h"

// From: https://gist.github.com/1209911
#import <CommonCrypto/CommonDigest.h>
static NSString * FTPDFMD5String(NSData *input) {
    unsigned char result[16];
    CC_MD5(input.bytes, (CC_LONG)input.length, result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]];
}


@implementation FTAssetRenderer (FTPDFAssetRenderer)

+ (FTPDFAssetRenderer *)rendererForPDFNamed:(NSString *)pdfName
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:pdfName withExtension:@"pdf"];
    if (URL != nil) {
        FTPDFAssetRenderer *renderer = [[FTPDFAssetRenderer alloc] initWithURL:URL];
        return renderer;
    }

    return nil;
}

@end


@interface FTPDFAssetRenderer () {
    CGPDFDocumentRef _document;
    NSString *_cachePathIdentifier;
}

@property (nonatomic, readonly, nullable) NSData *data;

@end

@implementation FTPDFAssetRenderer

@synthesize targetSize = _targetSize;

#pragma mark - Lifecycle

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if (self == nil) {
        return nil;
    }

    [self _commonPDFAssetRendererInit];

    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super initWithURL:nil];
    if (self == nil) {
        return nil;
    }

    [self _commonPDFAssetRendererInit];
    _data = data;
    
    return self;
}

- (void)_commonPDFAssetRendererInit
{
    // Don't open the PDF yet, as the user may want the actual work to be done on a background thread.
    _document = NULL;
    _sourcePageIndex = 1;
    _targetSize = CGSizeZero;
}

- (void)dealloc
{
    CGPDFDocumentRelease(_document);
}

#pragma mark - FTAssetRenderer

// A PDF does not necessarily have to be used as a mask.
- (void)assertCanCacheWithIdentifier:(NSString *)identifier
{
    if (self.URL == nil && self.cachePathIdentifier == nil) {
        [NSException raise:@"FTAssetRendererError"
                    format:@"An image can't be cached without a valid cache path identifier."];
    }

    if (self.isMask) {
        [super assertCanCacheWithIdentifier:identifier];
    }
}

- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier
{
    if (self.sourcePage == NULL) {
        [NSException raise:@"FTAssetRendererError"
                    format:@"Can’t render an image without a source page."];
    }

    return [super imageWithCacheIdentifier:identifier];
}

- (void)drawImageInContext:(CGContextRef)context
{
    // Draw page scaled to the target size.
    CGContextSaveGState(context);
    CGRect mediaRect = self.mediaRectOfSourcePage;
    CGSize targetSize = self.targetSize;
    CGContextScaleCTM(context, targetSize.width / mediaRect.size.width,
                      targetSize.height / mediaRect.size.height);
    CGContextTranslateCTM(context, -mediaRect.origin.x, -mediaRect.origin.y);
    CGContextDrawPDFPage(context, self.sourcePage);
    CGContextRestoreGState(context);
}

- (void)drawTargetColorInContext:(CGContextRef)context
{
    if (self.isMask) {
        [super drawTargetColorInContext:context];
    }
}

- (NSString *)cacheRawFilenameWithIdentifier:(NSString *)identifier
{
    NSString *filename = [super cacheRawFilenameWithIdentifier:identifier];
    if (self.URL == nil) {
        filename = [filename stringByAppendingFormat:@"-%@", self.cachePathIdentifier];
    }

    return [NSString stringWithFormat:@"%@-%zd", filename, self.sourcePageIndex];
}

#pragma mark - FTPDFAssetRenderer

- (CGPDFDocumentRef)document
{
    if (_document == NULL) {
        NSAssert(self.URL != nil || self.data != nil, @"PDF Asset Renderer needs either a valid URL or NSData object");
        if (self.URL != nil) {
            _document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.URL);
        } else if (self.data != nil) {
            CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)self.data);
            _document = CGPDFDocumentCreateWithProvider(provider);
            CGDataProviderRelease(provider);
        }
    }

    return _document;
}

- (CGPDFPageRef)sourcePage
{
    return CGPDFDocumentGetPage(self.document, self.sourcePageIndex);
}

- (CGSize)sourceSize
{
    return self.mediaRectOfSourcePage.size;
}

- (CGRect)mediaRectOfSourcePage
{
    return CGPDFPageGetBoxRect(self.sourcePage, kCGPDFCropBox);
}

- (BOOL)isMask
{
    return self.targetColor != nil;
}

// Returns the full size of the source page, unless one is specified.
- (CGSize)targetSize
{
    if (CGSizeEqualToSize(_targetSize, CGSizeZero)) {
        _targetSize = self.sourceSize;
    }

    return _targetSize;
}

- (void)fitSize:(CGSize)maxSize
{
    CGSize sourceSize = self.sourceSize;
    CGFloat scaleFactor = MAX(sourceSize.width / maxSize.width, sourceSize.height / maxSize.height);
    self.targetSize = CGSizeMake((CGFloat)ceil(sourceSize.width / scaleFactor), (CGFloat)ceil(sourceSize.height / scaleFactor));
}

- (void)fitWidth:(CGFloat)targetWidth
{
    CGSize sourceSize = self.sourceSize;
    CGFloat aspectRatio = sourceSize.width / sourceSize.height;
    self.targetSize = CGSizeMake(targetWidth, (CGFloat)ceil(targetWidth / aspectRatio));
}

- (void)fitHeight:(CGFloat)targetHeight
{
    CGSize sourceSize = self.sourceSize;
    CGFloat aspectRatio = sourceSize.width / sourceSize.height;
    self.targetSize = CGSizeMake((CGFloat)ceil(targetHeight * aspectRatio), targetHeight);
}

#pragma mark - Private

- (NSString *)cachePathIdentifier
{
    if (_cachePathIdentifier == nil && self.data != nil) {
        _cachePathIdentifier = FTPDFMD5String(self.data);
    }

    return _cachePathIdentifier;
}

@end
