//
//  ACDeviceManager.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/16/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACMsg.h"
#import "ACDevice.h"

@class ACDevice, ACDeviceActive;
@interface ACDeviceManager : NSObject

/**
 * 激活蓝牙设备
 * @param subDomain    产品子域
 * @param deviceActive 设备信息
 * @param callback     完成回调
 */
+ (void)activateDeviceWithSubDomain:(NSString *)subDomain
                       DeviceActive:(ACDeviceActive *)deviceActive
                           Callback:(void(^)(ACMsg *responseMsg , NSError *error))callback;

/**
 * 获取设备激活信息
 * @param subDomain         产品子域
 * @param physicalDeviceId  物理id
 * @param callback          完成回调
 */
+ (void)getDeviceInfoWithSubDomain:(NSString *)subDomain
                  physicalDeviceId:(NSString *)physicalDeviceId
                          Callback:(void(^)(ACDevice *device , NSError *error))callback;


@end
