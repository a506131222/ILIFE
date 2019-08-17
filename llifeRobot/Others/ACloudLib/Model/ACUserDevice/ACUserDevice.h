//
//  ACUserDevice.h
//  AbleCloudLib
//
//  Created by OK on 15/3/24.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 设备在线状态 */
typedef NS_ENUM(NSInteger,ACDeviceStatus) {
    ACDeviceStatusOffline,          //不在线
    ACDeviceStatusNetworkOnline,    //云端在线
    ACDeviceStatusLocalOnline,      //局域网在线
    ACDeviceStatusBothOnline        //云端和局域网同时在线
};

@class ACObject;

@interface ACUserDevice : NSObject<NSCoding>
/** 设备逻辑ID */
@property (nonatomic, assign) NSInteger deviceId;
/** 设备管理员ID */
@property (nonatomic, assign) NSInteger ownerId;
/** 设备名称 */
@property (nonatomic, copy) NSString *deviceName;
/** 子域ID */
@property (nonatomic, assign) NSInteger subDomainId;
/** 子域名称 */
@property (nonatomic, copy) NSString *subDomain;
/** 局域网访问key */
@property (nonatomic, strong) NSData *AESkey;
/** 设备物理ID */
@property (nonatomic, copy) NSString *physicalDeviceId;
/** 设备状态 */
@property (nonatomic, assign) ACDeviceStatus status;
/** 设备属性的最新值 */
@property (nonatomic, strong) ACObject *properties;
/** 设备当前处于报警故障态的属性 */
@property (nonatomic, strong) ACObject *faults;
/** 拓展信息 */
@property (nonatomic, strong) ACObject *profile;
/** 设备绑定时间 */
@property (nonatomic, copy) NSString *bindTime;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)userDeviceWithDict:(NSDictionary *)dict;

/** 判断是否存在AESKey */
- (BOOL)isValidAccessKey;


@end
