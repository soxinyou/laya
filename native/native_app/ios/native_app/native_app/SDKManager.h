//
//  SDKManager.h
//  native_app
//
//  Created by liupengpeng on 2018/10/12.
//  Copyright © 2018年 native_app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
@interface SDKManager : UIResponder <UIAlertViewDelegate>
+(void) Init;
+(void) OnCacheList;

+(void) OnCall:(NSString*)json;
+(void) Call:(NSString*)cmd cxt:(NSDictionary*)cxt;

+(void) OnShowAlert:(NSString*)json;

+(void) OnExit:(NSString*)json;

+(void) ExitApplication;

+(NetworkStatus2) GetNetworkStatus;

+(void) setToken:(NSString*)token;
+(NSString*)getToken;

+(void) setClientID:(NSString*)cid;
+(NSString*)getClientID;

+(bool) isChangingAccount;
+(void) finishChangeAccount;
@end
