//
//  ACQueryDeviceStateManager.h
//  AbleCloud
//
//  Created by fariel huang on 2016/12/1.
//  Copyright © 2016年 AbleCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACLocalDevice;

@interface ACQueryDeviceStateManager : NSObject

/**
 * 查询局域网发现的设备的配网状态
 * @param subDomainId 子域id
 * @param timeout 查询timeout时间
 * @param callback 回调查询结果
 */
- (void)queryLocalDeviceStateWithSubDomainId:(NSInteger)subDomainId
                                     timeout:(NSTimeInterval)timeout
                                    callback:(void (^)(BOOL isQueryFinished,
                                                       NSArray<ACLocalDevice *> *devices,
                                                       NSError *error))callback;

/**
 * 查询局域网指定物理id设备的配网状态
 * @param subDomainId 子域id
 * @param physicalDeviceId 指定物理id
 * @param timeout 查询timeout时间
 * @param callback 回调查询结果
 */
- (void)queryLocalDeviceStateWithSubDomainId:(NSInteger)subDomainId
                            physicalDeviceId:(NSString *)physicalDeviceId
                                     timeout:(NSTimeInterval)timeout
                                    callback:(void (^)(BOOL isQueryFinished,
                                                       NSArray<ACLocalDevice *> *devices,
                                                       NSError *error))callback;

/**
 * 结束所有查询
 */
- (void)stop;

/**
 * 获取局域网发现的设备的WiFi连接质量
 * @param devices 需要查询设备连接WiFi强度的设备列表
 * @param timeout 超时时间
 * @param callback 回调查询结果
 */
- (void)fetchConnectedWifiRssiWithLocalDevice:(NSArray <ACLocalDevice *>*)devices
                                      timeout:(NSTimeInterval)timeout
                                     callback:(void (^)(NSArray <ACLocalDevice *> *devices,
                                                        NSError *error))callback;
/**
 * 停止获取设备与WiFi连接的信号强度
 */
- (void)stopFetchWifiRssi;

@end
