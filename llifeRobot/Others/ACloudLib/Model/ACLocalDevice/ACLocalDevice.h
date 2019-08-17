//
//  ACLocalDevice.h
//  AbleCloud
//
//  Created by zhourx5211 on 1/18/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDeviceMsg.h"

/** 局域网通信方式 */
typedef NS_ENUM(NSInteger, ACLocalDeviceLANMode) {
    ACLocalDeviceLANModeTCP, //局域网通过TCP通信
    ACLocalDeviceLANModeUDP, //局域网通过UDP通信
    ACLocalDeviceLANModeHTTP //局域网通过HTTP通信
};

@interface ACLocalDevice : NSObject<NSCoding>

/** 局域网设备的物理id，非逻辑id */
@property (nonatomic, copy) NSString *deviceId;
/** 子域id */
@property (nonatomic, assign) NSInteger subDomainId;
/** 主域id */
@property (nonatomic, assign) NSInteger majorDomainId;
/** 设备ip */
@property (nonatomic, copy) NSString *ip;
/** 设备版本 */
@property (nonatomic, assign) NSInteger deviceVersion;
/** 局域网通信方式 注：由硬件端决定，自动发现无需设置 */
@property (nonatomic, assign) ACLocalDeviceLANMode lanMode;
/** 与设备通讯的安全性级别, 默认是动态加密 注：由硬件端决定，自动发现无需设置 */
@property (nonatomic, assign) ACDeviceSecurityMode securePolicy;
/** 连接质量 */
@property (nonatomic, assign) NSInteger linkQuality;
/** 是否处于配网状态 */
@property (nonatomic, assign) BOOL netConfig;
/** 获取静态加密秘钥 */
- (NSString *)getStaticAESKey;

@end
