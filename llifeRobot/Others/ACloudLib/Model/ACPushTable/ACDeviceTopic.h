//
//  ACDeviceTopic.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/7.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopic.h"

@interface ACDeviceTopic : ACTopic

/**
 * 设备推送消息类型
 * 多种类型消息可以使用格式如: ACDeviceDataTypeProperty|ACDeviceDataTypeStatus
 */
typedef NS_OPTIONS(NSInteger, ACDeviceDataType) {
    ACDeviceDataTypeProperty = 1 << 0, //属性数据
    ACDeviceDataTypeOnlineStatus = 1 << 1, //状态数据
    ACDeviceDataTypeFaults = 1 << 2 //故障报警数据
};

/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** 数据类型 */
@property (nonatomic, assign) ACDeviceDataType type;
/** deviceId */
@property (nonatomic, assign) NSInteger deviceId;

/**
 * 初始化设备类型订阅对象实例
 * @param subDomain 子域
 * @param type 订阅数据类型
 * @param deviceId 设备逻辑id
 * @return 订阅对象实例
 */
- (instancetype)initWithSubDomain:(NSString *)subDomain
                         deviceId:(NSInteger)deviceId
                      messageType:(ACDeviceDataType)type;

@end
