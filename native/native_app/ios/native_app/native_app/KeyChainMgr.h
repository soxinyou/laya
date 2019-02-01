//
//  KeyChainMgr.h
//  testzip
//
//  Created by 林洪伟 on 2017/7/31.
//  Copyright © 2017年 testzip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainMgr : NSObject
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;
@end
