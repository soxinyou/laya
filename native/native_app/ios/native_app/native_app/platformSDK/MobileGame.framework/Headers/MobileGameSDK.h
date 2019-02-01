//
//  CSMobileGameSDK.h
//  iOSSDKDemo
//
// on 2017/12/18.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileGameOpenMode.h"

/**
 登录返回block

 @param clientid 设备ID
 @param game_id 游戏ID
 @param pst 登录态token
 */
typedef void(^LoginBlock)(NSString *clientid,NSString *game_id,NSString *pst);

/**
 用户注销
 */
typedef void(^LogoutBlock)(void);
/**
 用户关闭的登录或注册界面
 */
typedef void(^DisMissBlock)(void);

@interface MobileGameSDK : NSObject
@property (nonatomic , strong) NSString *netcount;
/**
 *  @brief  激活SDK
 *  @param gameID       游戏ID
 */
+(void)initSDKWithGameID:(NSString *)gameID;


/**
 Debug模式，打印网络请求输出

 @param isdebug 默认NO；
 */
+(void)DebugMode:(BOOL)isdebug;
/**
 *  @brief  获取SDK实例
 */
+(MobileGameSDK *)SharedMobileGameSDK;
/**
 *  @brief  呼出登录注册页面，或者自动登录。
 *  @param baseviewController     视图控制器，如果为nil，将使用默认windows。
 */
-(void)MobileGameLoginViewController:(UIViewController *)baseviewController;

/**
 *  @brief  登录消息返回BLOCK。
 *
 */
@property (nonatomic , strong) LoginBlock loginBlock;

/**
 *  @brief  用户关闭了登录窗口。
 */
@property (nonatomic , strong) DisMissBlock disMissBlock;
/**
 *  @brief  用户关闭了登录窗口。
 */
@property (nonatomic , strong) LogoutBlock logoutBlock;

@property (nonatomic , strong) LogoutBlock uilogoutBlock;



/**
 发起支付
 @param MobileGameOpenOderModel sdkorder
 */
-(void)IAPWithMobileGameOpenOderModel:(MobileGameOpenOderModel *)openoderModel Block:(void(^)(int code ,NSString*msg))block;;



/**
进入游戏服回调-在进到游戏，选完游戏服后需要请求平台接口。主要作用统计游戏服进入数。 (选服后发送)
 @param userinfo MobileGameOpenUserModel对象
 */
-(void)MobileGameUserSelectedServer:(MobileGameOpenUserModel*)userinfo;

/**
 创建角色成功回调-在玩家进到游戏，成功创建角色后回调平台接口。主要作用统计游戏的创建数 (创角成功后发送)
 @param userinfo MobileGameOpenUserModel对象
 */
-(void)MobileGameUserCreateRole:(MobileGameOpenUserModel*)userinfo;

/**
 注销
 */
-(void)Logout;

-(void)LogoutNoAlert;

-(void)LoginFinish;
//-(NSString *)TestUid;
@end



