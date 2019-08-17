//
//  ACDeviceActive.h
//  AbleCloudLib
//
//  Created by 乞萌 on 16/1/9.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACDeviceActive : NSObject
/** 设备的物理Id */
@property (nonatomic,copy) NSString *physicalDeviceId;
/** 设备的当前版本 */
@property (nonatomic,copy) NSString *deviceVersion;
/** 设备/手机MAC地址 */
@property (nonatomic,copy) NSString *mac;
/** 设备通信模组版本，对于蓝牙设备和安卓设备，非必填 */
@property (nonatomic,copy) NSString *moduleVersion;
/** 设备地理位置信息，纬度，如果有设备定位需求 */
@property (nonatomic, assign) double latitude;
/** 设备地理位置信息，经度，如果有设备定位需求 */
@property (nonatomic, assign) double longitude;

@end
