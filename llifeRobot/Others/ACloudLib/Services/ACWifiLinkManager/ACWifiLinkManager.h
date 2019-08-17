//
//  ACWifiLinkManager.h
//  AbleCloud
//
//  Created by zhourx5211 on 1/9/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 庆科 */
extern NSString *const ACLinkerNameEasyLink;
/** 汉枫 V7 */
extern NSString *const ACLinkerNameHF;
/** 汉枫 V8 */
extern NSString *const ACLinkerNameHFV8;
/** 联胜德 */
extern NSString *const ACLinkerNameOneshot;
/** RAK */
extern NSString *const ACLinkerNameRAK;
/** MTK */
extern NSString *const ACLinkerNameMTK;
/** 乐鑫 */
extern NSString *const ACLinkerNameESPTouch;
/** 瑞昱 */
extern NSString *const ACLinkerNameRealtek;
/** 新力维 */
extern NSString *const ACLinkerNameXLW;
/** TI */
extern NSString *const ACLinkerNameTI;
/** Marvell */
extern NSString *const ACLinkerNameMarvell;
/** 古北 */
extern NSString *const ACLinkerNameGuBei;
/** 安卓设备 */ 
extern NSString *const ACLinkerNameAndroid;
/** 高通 */
extern NSString *const ACLinkerNameLTLink;
/** 用户自定义 */
extern NSString *const ACLinkerNameCustom;
/** AP模式配网 */
extern NSString *const ACLinkerNameAPMode;

@class ACWifiInfo;
@interface ACWifiLinkManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * 初始化
 * @param linkerName            配网模块名称
 * @return ACWifiLinkManager    对象实例
 */
- (id)initWithLinkerName:(NSString *)linkerName;

/**
 * 获取当前 SSID
 * @return 当前 SSID
 */
+ (NSString *)getCurrentSSID;

/**
 * 设备配网
 * @param ssid             当前 Wifi ssid
 * @param password         当前 Wifi 密码
 * @param physicalDeviceId 设备物理 ID
 * @param timeout          超时时间
 * @param callback         请求结果回调
 */
- (void)sendWifiInfo:(NSString *)ssid
            password:(NSString *)password
    physicalDeviceId:(NSString *)physicalDeviceId
             timeout:(NSTimeInterval)timeout
            callback:(void (^)(NSString *deviceId, NSString *bindCode, NSError *error))callback;

/**
 * 设备配网
 * @param ssid        当前 Wifi ssid
 * @param password    当前 Wifi 密码
 * @param timeout     超时时间
 * @param callback    请求结果回调
 */
- (void)sendWifiInfo:(NSString *)ssid
            password:(NSString *)password
             timeout:(NSTimeInterval)timeout
            callback:(void (^)(NSArray *localDevices, NSError *error))callback;

/**
 * 停止 Wifi 连接
 */
- (void)stopWifiLink;

#pragma mark - AP模式配网接口

/**
 设置 AP 模式下设备的 ip 地址
 
 如果不调用该方法,默认为 "10.10.100.254"
 @param customApAddress 设备的 ip 地址
 */
- (void)customApAddress:(NSString *)customApAddress;

/**
 * AP模式下配网, 将需要设备连接的Wifi信息发送给设备
 * @param ssid        设备要连接的目标Wifi名
 * @param password    设备目标Wifi的密码
 * @param callback    设备返回值, 三个参数分别对应, 设备是否接收到WIFI, 设备连接云端返回信息, 错误
 */
- (void)APSendWifiInfo:(NSString *)ssid
              password:(NSString *)password
               timeout:(NSTimeInterval)timeout
              callback:(void(^)(BOOL response, NSArray *localDevices, NSError *error))callback;

/**
 * 搜索设备可用的Wifi信号
 * 注: 有些Wifi信息可能app搜的到, 但是设备搜不到, 所以需要先获取设备可用的wifi信息
 * 根据设备搜索到的wifi信息再进行AP模式下的配网
 * @param callback 设备搜索到可用的wifi信号列表
 */
- (void)searchAvailableWifiTimeout:(NSTimeInterval)timerout
                          callback:(void(^)(NSArray<ACWifiInfo *> *wifiInfo, NSError *error))callback;

@end
