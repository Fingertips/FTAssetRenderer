#import "FTPDFAssetRenderer.h"

@implementation FTAssetRenderer (FTPDFAssetRenderer)

+ (FTPDFAssetRenderer *)rendererForPDFNamed:(NSString *)pdfName;
{
  NSURL *URL = [[NSBundle mainBundle] URLForResource:pdfName withExtension:@"pdf"];
  if (URL) {
    FTPDFAssetRenderer *renderer = [[FTPDFAssetRenderer alloc] initWithURL:URL];
    return renderer;
  }
  return nil;
}

@end


@interface FTPDFAssetRenderer () {
  CGPDFDocumentRef _document;
}
@end

@implementation FTPDFAssetRenderer

#pragma mark - init / dealloc

- (void)dealloc;
{
  CGPDFDocumentRelease(_document);
}

// Don't open the PDF yet, as the user may want the actual work to be done on a
// background thread.
- (id)initWithURL:(NSURL *)URL;
{
  if ((self = [super initWithURL:URL])) {
    _document = NULL;
    _sourcePageIndex = 1;
    _targetSize = CGSizeZero;
  }
  return self;
}

- (CGPDFDocumentRef)document;
{
  if (_document == NULL) {
    _document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.URL);
  }
  return _document;
}

- (CGPDFPageRef)sourcePage;
{
  return CGPDFDocumentGetPage(self.document, self.sourcePageIndex);
}

- (CGSize)sourceSize;
{
  return self.mediaRectOfSourcePage.size;
}

- (CGRect)mediaRectOfSourcePage;
{
  return CGPDFPageGetBoxRect(self.sourcePage, kCGPDFCropBox);
}

- (BOOL)isMask;
{
  return self.targetColor != nil;
}

#pragma mark - target size accessors

// Returns the full size of the source page, unless one is specified.
- (CGSize)targetSize;
{
  if (CGSizeEqualToSize(_targetSize, CGSizeZero)) {
    _targetSize = self.sourceSize;
  }
  return _targetSize;
}

- (void)fitSize:(CGSize)maxSize;
{
  CGSize sourceSize = self.sourceSize;
  CGFloat scaleFactor = MAX(sourceSize.width / maxSize.width, sourceSize.height / maxSize.height);
  self.targetSize = CGSizeMake(ceilf(sourceSize.width / scaleFactor), ceilf(sourceSize.height / scaleFactor));
}

- (void)fitWidth:(CGFloat)targetWidth;
{
  CGSize sourceSize = self.sourceSize;
  CGFloat aspectRatio = sourceSize.width / sourceSize.height;
  self.targetSize = CGSizeMake(targetWidth, ceilf(targetWidth / aspectRatio));
}

- (void)fitHeight:(CGFloat)targetHeight;
{
  CGSize sourceSize = self.sourceSize;
  CGFloat aspectRatio = sourceSize.width / sourceSize.height;
  self.targetSize = CGSizeMake(ceilf(targetHeight * aspectRatio), targetHeight);
}

#pragma mark - drawing

// A PDF does not necessarily have to be used as a mask.
- (void)canCacheWithIdentifier:(NSString *)identifier;
{
  if (self.isMask) [super canCacheWithIdentifier:identifier];
}

- (UIImage *)imageWithCacheIdentifier:(NSString *)identifier;
{
  if (self.sourcePage == NULL) {
    [NSException raise:@"FTAssetRendererError"
                format:@"Can’t render an image without a source page."];
  }
  return [super imageWithCacheIdentifier:identifier];
}

- (void)drawImageInContext:(CGContextRef)context;
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

- (void)drawTargetColorInContext:(CGContextRef)context;
{
  if (self.isMask) [super drawTargetColorInContext:context];
}

- (NSString *)cacheRawFilenameWithIdentifier:(NSString *)identifier;
{
  NSString *filename = [super cacheRawFilenameWithIdentifier:identifier];
  return [NSString stringWithFormat:@"%@-%zd", filename, self.sourcePageIndex];
}

@end
