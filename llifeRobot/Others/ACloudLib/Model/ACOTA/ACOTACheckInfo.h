//
//  ACOTACheckInfo.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/10/30.
//  Copyright © 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 升级类型 */
typedef enum {
    ACOTACheckInfoTypeSystem = 1, //系统升级
    ACOTACheckInfoTypeCustom = 2  //通信模组升级
} ACOTACheckInfoType;

@interface ACOTACheckInfo : NSObject
/** 设备物理id, 蓝牙设备使用 */
@property (nonatomic, copy, readonly) NSString *physicalDeviceId;
/** 设备逻辑id, 非蓝牙设备使用 */
@property (nonatomic, assign, readonly) NSInteger deviceId;
/** 设备原版本 */
@property (nonatomic, copy) NSString *version;
/** 设备渠道 */
@property (nonatomic, copy) NSString *channel;
/** 设备批次 */
@property (nonatomic, copy) NSString *batch;
@property (nonatomic, copy) NSString *regional;
/** 升级类型 */
@property (nonatomic, assign) ACOTACheckInfoType otaType;
/**
 * 蓝牙设备OTA使用
 * @param physicalDeviceId 设备物理id
 * @param version          设备ota当前版本
 * @return ACOTACheckInfo实例
 */
+ (instancetype)checkInfoWithPhysicalDeviceId:(NSString *)physicalDeviceId
                                      version:(NSString *)version;
/**
 * 非蓝牙设备(linux设备&wifi设备)OTA使用
 * @param deviceId 设备的逻辑id
 * @param type     升级类型
 * @return ACOTACheckInfo实例
 */
+ (instancetype)checkInfoWithDeviceId:(NSInteger)deviceId
                              otaType:(ACOTACheckInfoType)type;

@end
