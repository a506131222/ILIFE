//
//  ACOTAManager.h
//  AbleCloudLib
//
//  Created by zhourx5211 on 7/15/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACOTAFileMeta.h"
#import "ACOTAUpgradeInfo.h"
#import "ACOTACheckInfo.h"

@interface ACOTAManager : NSObject

/**
 * 检查OTA版本
 * 不管有无新版本，都会回调ACOTAUpgradeInfo，根据update判断有无OTA更新
 
 * @param subDomain 子域
 * @param checkInfo 检查信息, 如果是蓝牙设备,使用physicalDeviceId, 如果是非蓝牙设备, 使用deviceId
 * @param callback  检查信息的回调
 */
+ (void)checkUpdateWithSubDomain:(NSString *)subDomain
                    OTACheckInfo:(ACOTACheckInfo *)checkInfo
                        callback:(void (^)(ACOTAUpgradeInfo *checkInfo, NSError *error))callback;

/**
 * 确认升级
 * 非蓝牙设备需要在获得OTA版本以后通知云端确认升级, 蓝牙设备不需要调用该接口
 
 * @param subDomain  子域
 * @param deviceId   设备逻辑id
 * @param newVersion 设备目标版本
 * @param callback   回调函数
 */
+ (void)confirmUpdateWithSubDomain:(NSString *)subDomain
                          deviceId:(NSInteger)deviceId
                        newVersion:(NSString *)newVersion
                           otaType:(ACOTACheckInfoType)otaType
                          callback:(void (^)(NSError *error))callback;

/**
 * 蓝牙设备OTA文件下载成功后,建议开发者调用此接口通知云端下载文件成功(蓝牙设备调用接口)
 * 此接口只用于AbleCloud控制台OTA日志追踪
 
 * @param subDomain        子域名，如djj（豆浆机）
 * @param physicalDeviceId 设备物理ID
 * @param currentVersion   设备当前版本号
 * @param targetVersion    下载的版本号
 * @param callback         返回结果的监听回调
 */
+ (void)otaMediaDoneWithSubDomain:(NSString *)subDomain
                 PhysicalDeviceId:(NSString *)physicalDeviceId
                   currentVersion:(NSString *)currentVersion
                    targetVersion:(NSString *)targetVersion
                          otaType:(NSInteger)otaType
                         callback:(void(^)(NSError *error))callback;

@end
