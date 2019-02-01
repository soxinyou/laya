#import "JSBridge.h"
#import "AppDelegate.h"
@implementation JSBridge

+(void)hideSplash
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView hide];
}
+(void)setTips:(NSArray*)tips
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.launchView.tips = tips;
}
+(void)setFontColor:(NSString*)color
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView setFontColor:color];
}
+(void)bgColor:(NSString*)color
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView setBackgroundColor:color];
}
+(void)loading:(NSNumber*)percent
{
    NSLog(@"====================path:");
    NSString *path =[[NSBundle mainBundle]pathForResource:@"login_bg" ofType:@"jpg"];
    NSLog(@"====================path=%@",path);
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView setPercent:percent.integerValue];
}



+(void)showTextInfo:(NSNumber*)show
{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView showTextInfo:show.intValue > 0];
}

+(void) exitApplication {
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow * window =appDelegate.window;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha=0;
        window.frame=CGRectMake(0,window.bounds.size.width,0,0);
    }completion:^(BOOL finished){
        exit(0);
    }];
}
@end

