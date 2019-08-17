//
//  ACDeviceClient.h
//  AbleCloudLib
//
//  Created by zhourx5211 on 3/14/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDeviceMsg.h"
#import "ACloudLibConst.h"

@interface ACDeviceClient : NSObject


/**
 * 向设备发送消息

 * @param subDomainId 子域Id
 * @param msg 消息
 * @param physicalDeviceId 设备物理id
 * @param timeout 超时时间
 * @param callback 发送消息回调
 */
- (void)sendToDevice:(NSInteger)subDomainId
                 msg:(ACDeviceMsg *)msg
    physicalDeviceId:(NSString *)physicalDeviceId
             timeout:(NSTimeInterval)timeout
            callback:(void (^)(ACDeviceMsg *responseMsg, NSError *error))callback;

#pragma mark - Deperated

/**
 * 向设备发送消息

 * @param subDomainId 子域Id
 * @param msg 消息
 * @param deviceId 设备逻辑id
 * @param timeout 超时时间
 * @param callback 发送消息回调
 */
- (void)sendToDevice:(NSInteger)subDomainId
                 msg:(ACDeviceMsg *)msg
            deviceId:(NSInteger)deviceId
             timeout:(NSTimeInterval)timeout
            callback:(void (^)(ACDeviceMsg *responseMsg, NSError *error))callback ACDeprecated("使用sendToDevice:msg:physicalDeviceId:timeout:callback");

@end
