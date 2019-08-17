//
//  ACDevice.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/23/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACDevice : NSObject

/** 设备子域 */
@property (nonatomic, copy) NSString *subDomain;
/** 设备IP地址 */
@property (nonatomic, copy) NSString *ip;
/** 设备固件版本 */
@property (nonatomic, copy) NSString *deviceVersion;
/** 设备通信模组版本 */
@property (nonatomic, copy) NSString *moduleVersion;
/** 设备激活时间，格式yyyy-MM-dd HH:mm:ss */
@property (nonatomic, copy) NSString *activeTime;
/** 设备最后上线时间，格式yyyy-MM-dd HH:mm:ss */
@property (nonatomic, copy) NSString *lastOnlineTime;
/** 设备地理位置，国家 */
@property (nonatomic, copy) NSString *country;
/** 设备地理位置，省 */
@property (nonatomic, copy) NSString *province;
/** 设备地理位置，地区 */
@property (nonatomic, copy) NSString *city;
/** 街道 */
@property (nonatomic, copy) NSString *street;
/** mac地址 */
@property (nonatomic, copy) NSString *mac;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)deviceWithDict:(NSDictionary *)dict;

@end
