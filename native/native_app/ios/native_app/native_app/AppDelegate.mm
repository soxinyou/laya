#import "AppDelegate.h"
#import "ViewController.h"
#import "conchRuntime.h"
#import "MobileGame/MobileGame.h"
#import "SDKManager.h"
@implementation AppDelegate

static bool s_isSdkInit =false;
+(bool)isSdkInit{
    return s_isSdkInit;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
//    ViewController* pViewController  = [[ViewController alloc] init];
//    _window.rootViewController = pViewController;
//    [_window makeKeyAndVisible];
    
//    _launchView = [[LaunchView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [_window.rootViewController.view addSubview:_launchView.view];
    [self checkNet];
    return YES;
    
}

static bool s_isLoad =false;
-(void) initEngine{
    if(s_isLoad)
        return;
    s_isLoad=true;
    
   [SDKManager Init];
    
    //创建viewcontroller，初始化laya
    ViewController* pViewController  = [[ViewController alloc] init];
    self.window.rootViewController = pViewController;
    [self.window makeKeyAndVisible];
    
    _launchView = [[LaunchView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window.rootViewController.view addSubview:_launchView.view];
    //[self showLoginBg];
    //[NSThread sleepForTimeInterval:3];
}

-(void) showLoginBg{
    CGRect frame =CGRectMake(0, 0, 750,1334);
    
    UIImageView *img =[[UIImageView alloc] initWithFrame:frame];
    img.image=[UIImage imageNamed:@"login_bg"];
    img.contentMode=UIViewContentModeScaleAspectFit;
    [_window.rootViewController.view addSubview:img];
    
    
}

-(void) checkNet{
    if([SDKManager GetNetworkStatus]!=0)//有网络则开始初始化
    {
        [self initEngine];
    }
    else{
        [self alertNoNet];
    }
}

-(void) alertNoNet{
    //没有网则弹出对话框提示玩家
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"找不到网络，请设置网络后重进游戏" delegate:self  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // [SDKManager ExitApplication];
    
    NSLog(@"clickIndex:%d",buttonIndex);
    
    [self checkNet];
}


//设置及控制横竖屏（1.3新增）
//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
  //  NSLog(@"++++~~~~~~~~~~~~~~~~~~~~~UIInterfaceOrientationMask");
    //return [JsLaya AppUIInterfaceOrientationMask:UIInterfaceOrientationMaskAll];
   // return [JsLaya AppUIInterfaceOrientationMask:UIInterfaceOrientationMaskPortrait];
    //[JsLaya AppUIInterfaceOrientationMask:UIInterfaceOrientationMaskPortrait];
    //return UIInterfaceOrientationMaskPortrait;
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    m_kBackgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        if(m_kBackgroundTask != UIBackgroundTaskInvalid )
        {
            NSLog(@">>>>>backgroundTask end");
            [application endBackgroundTask:m_kBackgroundTask];
            m_kBackgroundTask = UIBackgroundTaskInvalid;
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
