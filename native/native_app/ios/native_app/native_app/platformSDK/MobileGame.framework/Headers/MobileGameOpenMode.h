//
//  MobileGameOpenMode.h
//  MobileGame
//
//  Created by YunsongZeng on 2018/11/8.
//  Copyright © 2018 YunsongZeng. All rights reserved.
//

/**
 下单结构体，避免类型错误，所有字段都为字符串。
 */
@interface MobileGameOpenOderModel : NSObject
/**
 order_no string CP的订单号-请保证每次下单的订单号不一样
 */
@property (strong , nonatomic) NSString * orno;
/**
 平台游戏ID
 */
@property (strong , nonatomic) NSString *  geid;
/**
 平台用户id
 */
@property (strong , nonatomic) NSString * uid;
/**
 开发商游戏区服标识（ID）
 */
@property (strong , nonatomic) NSString * sid;
/**
 开发商游戏角色标识（ID）
 */
@property (strong , nonatomic) NSString * arid;
/**
 商品名称
 */
@property (strong , nonatomic) NSString * subject;
/**
 价格，单位人民币元（6.00）
 */
@property (strong , nonatomic)  NSString * money;
/**
 请求时间戳
 */
@property (strong , nonatomic) NSString * time;
@property (strong , nonatomic) NSString * product_id;
/**
 按照签名算法计算出来的签名，具体算法，请参考支付回调文档。
 */
@property (strong , nonatomic) NSString * sign;

@end


/**
 统计用户结构体，避免类型错误，所有字段都为字符串。
 */
@interface MobileGameOpenUserModel : NSObject

//serverId      当前玩家登录的区服ID
@property (strong , nonatomic) NSString * sid;
//serverName    当前玩家登录的区服名称
@property (strong , nonatomic) NSString * serverName;

@end
