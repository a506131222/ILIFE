//
//  ACDeviceDataManager.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/19.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDeviceTopicMessage.h"
#import "ACLocalDevice.h"

@class ACObject;
@class ACDevicePropertySearchOption;

@interface ACDeviceDataManager : NSObject

#pragma mark - 设备属性订阅
/**
 * 订阅设备属性推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)subscribePropDataWithSubDomain:(NSString *)subDomain
                              deviceId:(NSInteger)deviceId
                              callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅设备属性推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)unSubscribePropDataWithSubDomain:(NSString *)subDomain
                                deviceId:(NSInteger)deviceId
                                callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有设备属性推送消息
 */
+ (void)unSubscribeAllDevicePropData;

/**
 * 设置设备类型信息接收回调
 * @param handler 用于回调消息
 */
+ (void)setPropertyMessageHandler:(void(^)(NSString *subDomain,
                                           NSInteger deviceId,
                                           ACObject *properties))handler;
#pragma mark - 设备上下线状态订阅
/**
 * 订阅设备上下线状态推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)subscribeOnlineStatusWithSubDomain:(NSString *)subDomain
                                  deviceId:(NSInteger)deviceId
                                  callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅设备上下线状态推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)unSubscribeOnlineStatusWithSubDomain:(NSString *)subDomain
                                    deviceId:(NSInteger)deviceId
                                    callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有设备上下线状态推送消息
 */
+ (void)unSubscribeAllDeviceOnlineStatus;

/**
 * 设置设备上下线状态回调
 * @param handler 用于回调消息
 */
+ (void)setOnlineStatusHandler:(void(^)(NSString *subDomain,
                                        NSInteger deviceId,
                                        ACDeviceOnlineStatus status))handler;

#pragma mark - 设备上故障报警属性订阅
/**
 * 订阅设备故障报警状态推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)subscribeFaultsWithSubDomain:(NSString *)subDomain
                            deviceId:(NSInteger)deviceId
                            callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅设备故障报警推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)unSubscribeFaultsWithSubDomain:(NSString *)subDomain
                              deviceId:(NSInteger)deviceId
                              callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有设备故障报警推送消息
 */
+ (void)unSubscribeAllDeviceFaults;

/**
 * 设置设备故障状态回调
 * @param handler 用于回调消息
 */
+ (void)setFaultsMessageHandler:(void(^)(NSString *subDomain,
                                         NSInteger deviceId,
                                         ACObject *faults))handler;

#pragma mark - 设备各项数据拉取接口
/**
 * 拉取设备历史属性记录
 * @param option 查询条件
 * @param callback 查询结果回调
 */
+ (void)fetchHistoryPropDataWithOption:(ACDevicePropertySearchOption *)option
                              callback:(void(^)(NSArray<ACDevicePropertyMessage *> *records,
                                                NSError *error))callback;

/**
 * 拉取设备当前所有属性值
 * @param subDomain 设备子域
 * @param deviceId 设备逻辑id
 * @param callback 返回查询结果
 */
+ (void)fetchCurrentPropDataWithSubDomain:(NSString *)subDomain
                                 deviceId:(NSInteger)deviceId
                                 callback:(void(^)(ACDevicePropertyMessage *result, NSError *error))callback;

/**
 * 拉取设备当前所有故障属性值
 * @param subDomain 设备子域
 * @param deviceId 设备逻辑id
 * @param callback 返回查询结果
 */
+ (void)fetchCurrentFaultsWithSubDomain:(NSString *)subDomain
                               deviceId:(NSInteger)deviceId
                               callback:(void(^)(ACDeviceFaultsMessage *result, NSError *error))callback;

#pragma mark - 设置设备状态相关接口
/**
 * 加速MCU上报数据的频率
 * @param deviceId  逻辑id
 * @param subDomain 子域
 * @param interval  查询间隔可设置为(0, 60]秒
 */
+ (void)enableDeviceFastReport:(NSInteger)deviceId
                     subDomain:(NSString *)subDomain
                      interval:(NSInteger)interval
                      callback:(void(^)(NSError *error))callback ;

/**
 * 取消加速指定设备MCU上报数据的频率
 * @discussion      3分钟后才会停止快速上报
 * @param deviceId  逻辑id
 * @param subDomain 子域
 */
+ (void)disableDeviceFastReport:(NSInteger)deviceId
                      subDomain:(NSString *)subDomain;

/**
 取消加速所有设备MCU上报数据的频率
 */
+ (void)disableAllDeviceFastReport;


@end
