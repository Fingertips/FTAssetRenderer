#import "AppDelegate.h"
#import "FTPDFAssetRenderer.h"

@implementation AppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions
{
    CGRect frame = [[UIScreen mainScreen] bounds];

    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor lightGrayColor];
    self.window.rootViewController = [UIViewController new];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(CGRectGetMidX(frame) - 50, 40, 100, 40);
    [self.window addSubview:button];

    FTPDFAssetRenderer *renderer = [FTPDFAssetRenderer rendererForPDFNamed:@"restaurant-icon-mask"];
    [renderer fitSize:button.bounds.size];

    renderer.targetColor = [UIColor blueColor];
    [button setImage:[renderer imageWithCacheIdentifier:@"normal"] forState:UIControlStateNormal];
    renderer.targetColor = [UIColor whiteColor];
    [button setImage:[renderer imageWithCacheIdentifier:@"highlighted"] forState:UIControlStateHighlighted];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
