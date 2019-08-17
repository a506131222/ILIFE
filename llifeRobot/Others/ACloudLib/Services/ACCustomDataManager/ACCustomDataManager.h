//
//  ACCustomDataManager.h
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2016/12/20.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACObject;

@interface ACCustomDataManager : NSObject

/**
 * 订阅自定义类型推送消息
 * @param subDomain 子域
 * @param type 自定义消息类型 不可以‘zc-’开头
 * @param key 自定义订阅数据键值
 */
+ (void)subscribeCustomDataWithSubDomain:(NSString *)subDomain
                                    type:(NSString *)type
                                     key:(NSString *)key
                                callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅自定义类型推送消息
 * @param subDomain 子域
 * @param type 自定义消息类型 不可以‘zc-’开头
 * @param key 自定义订阅数据键值
 */
+ (void)unSubscribeCustomDataWithSubDomain:(NSString *)subDomain
                                      type:(NSString *)type
                                       key:(NSString *)key
                                  callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有自定义类型推送消息
 */
+ (void)unSubscribeAllCustomData;

/**
 * 设置自定义推送信息回调
 * @param messageHandler 用于回调消息
 */
+ (void)setCustomMessageHandler:(void(^)(NSString *subDomain,
                                         NSString *type,
                                         NSString *key,
                                         ACObject *payload))messageHandler;

@end
