//
//  ACDeviceTopicMessage.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/7.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopicMessage.h"

/**
 * 设备状态信息类型
 */
typedef NS_ENUM(NSInteger, ACDeviceOnlineStatus) {
    ACDeviceOnlineStatusOffline, //设备下线
    ACDeviceOnlineStatusOnline //设备上线
};

@class ACObject;

/**
 * 设备消息共有属性
 */
@interface ACDeviceTopicMessage : ACTopicMessage
/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** deviceId */
@property (nonatomic, assign) NSInteger deviceId;
@end

/**
 * 设备属性消息
 */
@interface ACDevicePropertyMessage : ACDeviceTopicMessage
/** 属性数据内容 */
@property (nonatomic, strong) ACObject *properties;
/** 属性变更时间 */
@property (nonatomic, assign) NSTimeInterval timestamp;
@end

/**
 * 设备上下线消息消息
 */
@interface ACDeviceOnlineStatusMessage : ACDeviceTopicMessage
/** 在线状态 */
@property (nonatomic, assign) ACDeviceOnlineStatus status;

@end

/**
 * 设备故障消息
 */
@interface ACDeviceFaultsMessage : ACDeviceTopicMessage
/** 
 * 故障状态 
 * @discussion 只有故障状态变更时才会收到对应故障属性的推送
 * @discussion 各个属性的value值为 0：代表故障消失 >0：代表故障发生
 * @discussion @"overall" 属性值为 0：代表整机故障恢复 >0：代表整机有故障
 */
@property (nonatomic, strong) ACObject *faults;

@end
