//
//  SDKManager.m
//  cqjy_ios
//
//  Created by liupengpeng on 2018/9/29.
//  Copyright © 2018年 jiguang. All rights reserved.
//
#import "AppDelegate.h"
#import "SDKManager.h"
#import <MobileGame/MobileGame.h>
#import "conchRuntime.h"
#import "KeyChainMgr.h"
#import <AdSupport/AdSupport.h>
#include <sys/param.h>
#include <sys/mount.h>
#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>// md5加密
#import <sys/utsname.h>
#import "JSBridge.h"
@implementation SDKManager

static NSMutableArray *s_cacheList = NULL;
static NSString * cacheBool=@"0";
static NSString * logoutBool=@"0";
//缓冲外部调用接口列表
+(NSMutableArray*) getCacheList
{
    if(s_cacheList == NULL)
    {
        s_cacheList=[[NSMutableArray alloc] init];
    }
    return s_cacheList;
}

//处理缓存调用的接口列表
+ (void) OnCacheList{
    for (NSString * str in [self getCacheList])
    {
        [self OnCall:str];
        NSLog(@"++++OnCacheList");
    }
    [[self getCacheList] removeAllObjects];
}

//游戏ID
+(NSString *) GameID{
	return @"532";
}

+(NSString *) AppID{
	return @"37zyios";
}

static MobileGameSDK * insSdk=NULL;

+ (void) Init{
    if(insSdk==NULL){
        //设置游戏ID
        [MobileGameSDK  initSDKWithGameID:[self GameID]];
        //初始化 sdk
        insSdk=[MobileGameSDK SharedMobileGameSDK];
        NSLog( @"++++++++++++enter sdk Init gameId:%@",[self GameID]);
    }
}



//调用sdk接口
+(void) OnCall:(NSString *)json{
  NSLog( @"++++++++++++js call native：%@", json);
  if(insSdk){
	[self OnCommandExe:json];
    if([cacheBool isEqualToString:@"1"]){
        cacheBool =@"0";
        [self OnCacheList];
    }
  }else{
    cacheBool =@"1";
	[[self getCacheList] addObject:json];
    NSLog( @"OnCall没有初始化完，先存着：%@", json);
  }
}

//调用laya，laya那边要先调用SdkMgr.Listen才能被调用到
+(void) Call:(NSString*)cmd cxt:(NSDictionary*)cxt{
    if(cxt == nil)
        cxt = [[NSDictionary alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:cmd forKey:@"cmd"];
    [dict setObject:cxt forKey:@"cxt"];
    
    NSError *error = nil;
    // NSJSONWritingOptions 是"NSJSONWritingPrettyPrinted"的话有换位符\n；是"0"的话没有换位符\n。
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"原生调用回as：%@",json);
    
    [[conchRuntime GetIOSConchRuntime] callbackToJSWithClass:self.class methodName:@"OnCall:" ret:json];
}

+(void) OnCommandExe:(NSString *)json{
	NSLog( @"原生被as调用：%@", json);

    NSError *error = nil;
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error)
    {
        NSLog( @"json转字典失败%@", error);
        return;
    }
    NSString * cmd =[dic objectForKey:@"cmd"];
    NSDictionary *obj =[dic objectForKey:@"cxt"];
    if([cmd isEqualToString:@"login"]){
		[self OnLogin:obj];
	}
	else if([cmd isEqualToString:@"pay"]){
		[self OnPay:obj];
	}	
	else if([cmd isEqualToString:@"logout"]){
		[self OnLogout];
	}
	else if([cmd isEqualToString:@"selected_server"]){
        [self OnSelectedServer:obj];
	}
	else if([cmd isEqualToString:@"create_role"]){
        [self OnCreateRole:obj];
	}
	else if([cmd isEqualToString:@"enter_game"]){
        [self OnEnterGame:obj];
	}
    else if([cmd isEqualToString:@"connect"]){
        [self OnConnectCheck];
    }
    else{
		 NSLog( @"as的调用没有处理，cmd：%@",cmd);
	}  
}
+(void) OnConnectCheck{
    NSMutableDictionary *cxt = [[NSMutableDictionary alloc] init];
    if(insSdk){
       [cxt setObject:@"1" forKey:@"result"];
    }else{
       [cxt setObject:@"0" forKey:@"result"];
    }
    [cxt setObject:[SDKManager getBundleID] forKey:@"bundle_id"];
    [cxt setObject:[SDKManager getBundleVersion] forKey:@"bundle_version"];
    [cxt setObject:[SDKManager getPhoneModel] forKey:@"phone_model"];
    [cxt setObject:[SDKManager getDisplayName] forKey:@"display_name"];
    
    [SDKManager Call:@"connect" cxt:cxt];
}
+(void) OnLogin:(NSDictionary *)obj{
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.launchView forceHide];
    
    if([logoutBool isEqualToString:@"1"]){
        return;
    }
	[[MobileGameSDK SharedMobileGameSDK] MobileGameLoginViewController:[ViewController GetIOSViewController]];
    [MobileGameSDK SharedMobileGameSDK].loginBlock = ^(NSString *clientid,NSString *game_id,NSString *pst) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MobileGameSDK SharedMobileGameSDK] LoginFinish];
        });
        [self setToken:pst];
		[self setClientID:clientid];
        
		//没有token，可能就是注册失败了，这个时候对话框还在，什么都不做
		if(pst==nil){
			return;
		}
        logoutBool=@"0";
		NSMutableDictionary *cxt = [[NSMutableDictionary alloc] init];
		[cxt setObject:pst forKey:@"token"];
		[cxt setObject:clientid forKey:@"clientid"];
		[cxt setObject:game_id forKey:@"gameid"];
		[cxt setObject:[self AppID] forKey:@"appid"];
		[cxt setObject:[self IMEI] forKey:@"imei"];
        
		//这里要区分一下，可能是切换账号，也可能是登陆
		if(![SDKManager isChangingAccount])
			[SDKManager Call:@"login" cxt:cxt];
		else
		{
			[SDKManager Call:@"changeAccount" cxt:cxt];
			[SDKManager finishChangeAccount];
		}
    };
//    [MobileGameSDK SharedMobileGameSDK].disMissSuccessBlock = ^{
//         NSLog(@"用户关闭的登录或注册界面");
//    };
    
    [MobileGameSDK SharedMobileGameSDK].logoutBlock = ^{
        NSLog(@"用户注销");
        logoutBool=@"1";
       // exit(0);
        NSMutableDictionary *cxt = [[NSMutableDictionary alloc] init];
        [cxt setObject:@"用户注销" forKey:@"msg"];
        [SDKManager Call:@"switch_account" cxt:cxt];
    };
}

+(void)OnLogout{
    [[MobileGameSDK SharedMobileGameSDK] Logout];
}

+(void) OnPay:(NSDictionary*) obj{
    
   
    MobileGameOpenOderModel* rderinfo = [[MobileGameOpenOderModel alloc]init];
    rderinfo.orno = [obj objectForKey:@"order_no"];
    rderinfo.geid = [obj objectForKey:@"game_id"];
    rderinfo.uid = [obj objectForKey:@"uid"];
    rderinfo.sid = [obj objectForKey:@"sid"];
    rderinfo.arid = [obj objectForKey:@"actor_id"];
    rderinfo.subject =[obj objectForKey:@"subject"];
    rderinfo.money =[obj objectForKey:@"money"];
    rderinfo.time = [obj objectForKey:@"time"];
    rderinfo.sign = [obj objectForKey:@"sign"];
    NSLog(@"run OnPay,rderinfo.sign=%@",rderinfo.sign);
    
    rderinfo.product_id=[obj objectForKey:@"iosProductId"];

    [[MobileGameSDK SharedMobileGameSDK] IAPWithMobileGameOpenOderModel:rderinfo Block:^(int code, NSString *msg)
     {
         NSMutableDictionary *cxt = [[NSMutableDictionary alloc] init];
         
         NSString *codestr =[NSString stringWithFormat:@"%d",code];
		[cxt setObject:codestr forKey:@"code"];
		[cxt setObject:msg forKey:@"msg"];
		[SDKManager Call:@"pay" cxt:cxt];
     }];
}

+(void) OnSelectedServer:(NSDictionary*) obj{
    MobileGameOpenUserModel *userinfo = [[MobileGameOpenUserModel alloc]init];
    userinfo.sid =[obj objectForKey:@"serverid"];
    userinfo.serverName =[obj objectForKey:@"servername"];
    [[MobileGameSDK SharedMobileGameSDK] MobileGameUserSelectedServer:userinfo];
}

+(void) OnCreateRole:(NSDictionary*) obj{
    MobileGameOpenUserModel *userinfo = [[MobileGameOpenUserModel alloc]init];
    userinfo.sid =[obj objectForKey:@"serverid"];
    userinfo.serverName =[obj objectForKey:@"servername"];
    [[MobileGameSDK SharedMobileGameSDK] MobileGameUserCreateRole:userinfo];
}

+(void) OnEnterGame:(NSDictionary*) obj{
    //
//    [[MobileGameSDK SharedMobileGameSDK] TjWhenUserEnterGameWithServer:[obj objectForKey:@"serverid"] ServerName:[obj objectForKey:@"servername"]];
}

+(NSString*) IMEI
{
    NSString * const KEY_IN_KEYCHAIN = @"com.jiguang.h5.cqjy";
    //先获取keychain里面的UUID字段，看是否存在
    NSString *uuid = (NSString *)[KeyChainMgr load:KEY_IN_KEYCHAIN];
    
    //如果不存在则为首次获取UUID，所以获取保存。
    if (!uuid || uuid.length == 0) {
        CFUUIDRef puuid = CFUUIDCreate( nil );
        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
        uuid = [NSString stringWithFormat:@"%@", uuidString];
        [KeyChainMgr save:KEY_IN_KEYCHAIN data:uuid];
        CFRelease(puuid);
        CFRelease(uuidString);
    }
    
    return uuid;
}

+(void) OnShowAlert:(NSString*)json{
    NSData* jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (error)
    {
        NSLog( @"json转字典失败%@", error);
        return;
    }
    
    //没有网则弹出对话框提示玩家
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dic objectForKey:@"title"] message:[dic objectForKey:@"cxt"] delegate: self  cancelButtonTitle:[dic objectForKey:@"btn1"] otherButtonTitles:[dic objectForKey:@"btn2"], nil];
    [alertView show];
    
}

+(void) OnExit:(NSString*)json{
    //exit(0);
    [self ExitApplication];
}

+(void) ExitApplication {
     AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow * window =appDelegate.window;
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha=0;
        window.frame=CGRectMake(0,window.bounds.size.width,0,0);
    }completion:^(BOOL finished){
        exit(0);
    }];
}

//获取网络状态
static Reachability2 *s_internetReachability=nil;
+(NetworkStatus2) GetNetworkStatus
{
    if(s_internetReachability == nil)
        s_internetReachability = [Reachability2 reachabilityForInternetConnection];
    
    return  [s_internetReachability currentReachabilityStatus];
}

//获取bundle version 版本号
+(NSString*) getBundleVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

//获取BundleID
+(NSString*) getBundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

//获取app的名字
+(NSString*) getDisplayName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
   // NSMutableString * mutableAppName = [NSMutableString stringWithString:appName];
    return appName;
}

+(NSString *) getPhoneModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    return  [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
}

static NSString* s_token =nil;
+(void) setToken:(NSString*)token{
    s_token = token;
}
+(NSString*)getToken{
    return s_token;
}

static NSString* s_cid =nil;
+(void) setClientID:(NSString*)cid{
    s_cid = cid;
}
+(NSString*)getClientID{
    return s_cid;
}

static bool s_isChangingAccount =false;
+(bool) isChangingAccount{
    return s_isChangingAccount;
}
+(bool) setChangingAccount{
    return s_isChangingAccount;
}

+(void) finishChangeAccount{
    s_isChangingAccount=false;
}
@end
