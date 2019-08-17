//
//  ACServiceClient.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/11/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACMsg.h"
#import "ACloudLibConst.h"

@interface ACServiceClient : NSObject

/** host 地址 */
@property (readonly, nonatomic, copy) NSString *host;
/** service 名称 */
@property (readonly, nonatomic, copy) NSString *service;
/** UDS 服务版本号 */
@property (readonly, nonatomic, assign) NSInteger serviceVersion;

/**
 * 初始化

 * @param host             host 地址
 * @param service          服务名称
 * @param version          UDS 服务版本号
 * @return ACServiceClient 实例
 */
- (id)initWithHost:(NSString *)host service:(NSString *)service version:(NSInteger)version;

/**
 * 类方法初始化

 * @param host    host 地址
 * @param service 服务名称
 * @param version UDS 服务版本号
 * @return        ACServiceClient 实例
 */
+ (instancetype)serviceClientWithHost:(NSString *)host service:(NSString *)service version:(NSInteger)version;

/**
 * 往某一服务发送命令/消息

 * @param req 具体的消息内容
 * @param callback 服务端相应的消息
 */
- (void)sendToService:(ACMsg *)req callback:(void (^)(ACMsg *responseObject, NSError *error))callback;

/**
 * 判断 RefreshToken 的有效性
 */
- (BOOL)ac_isValidRefreshToken;

/**
 * 往某一服务发送命令/消息(匿名)
 * @param serviceName    服务名
 * @param version 服务版本
 * @param msg            具体的消息内容
 * @param callback       服务端相应的消息
 */
+ (void)sendToAnonymousService:(NSString *)serviceName
                       version:(NSInteger)version
                           msg:(ACMsg *)msg
                      callback:(void(^)(ACMsg * responseMsg,NSError *error))callback;

+ (void)setRefreshTokenInvalid:(void (^)(NSError *))callback;

#pragma mark - Deprecated
+ (void)sendToServiceWithoutSignWithSubDomain:(NSString *)subDomain
                                  ServiceName:(NSString *)serviceName
                               ServiceVersion:(NSInteger)serviceVersion
                                          Req:(ACMsg *)req
                                     Callback:(void(^)(ACMsg * responseMsg,NSError *error))callback ACDeprecated("请使用sendToAnonymousService:version:msg:callback:方法");

@end
