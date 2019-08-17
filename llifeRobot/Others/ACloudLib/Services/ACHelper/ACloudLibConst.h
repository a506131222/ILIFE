//
//  ACloudLibConst.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/15.
//  Copyright © 2016年 OK. All rights reserved.
//

#ifndef ACloudLibConst_h
#define ACloudLibConst_h

// 过期
#define ACDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#import <UIKit/UIKit.h>
#import "ACloudLib.h"

//自定义打印
#define ACLog(format, ...) {\
if ([ACloudLib logEnable]) {\
NSLog(@"[Ablecloud]: %s():%d " format, __func__, __LINE__, ##__VA_ARGS__);\
}\
}\

/**
* 客户端错误码
*/
typedef NS_ENUM(NSInteger, ACClientError) {
    ACClientErrorNoMsgName = 1001,                //未设置ACMsg的name
    ACClientErrorInvalidResponsePayload,          //响应payload错误
    ACClientErrorNoMajorDomain,                   //未设置主域或主域id
    ACClientErrorWriteLocalFileFailed,            //操作本地文件失败
    ACClientErrorSendWifiInfoFailed = 1960,       //没有发现局域网内的设备,多为配网失败
    ACClientErrorDeviceMCUUnregistered = 1961,    //MCU未进行注册
    ACClientErrorDeviceConnectCloudFailed = 1962, //设备与云端建立长连接失败
    ACClientErrorDeviceHandshakeFailed = 1963,    //设备与云端三次握手过程失败
    ACClientErrorInvalidCRC = 1984,               //crc校验错误
    ACClientErrorWebsocketNotConnected = 1985,    //推送长连接未建立
    ACClientErrorWiFiNotConnected = 1986,         //手机WiFi未连接
    ACClientErrorNetworkUnreachable = 1987,       //手机无法连接外网
    ACClientErrorLocalDeviceUnreachable = 1988,   //局域网内无法搜索到设备
    ACClientErrorMessagePayloadInvalid = 1989,    //message payload解密出错
    ACClientErrorNoMatchedDevice = 1990,          //无法匹配设备
    ACClientErrorInvalidParam = 1991,             //参数错误
    ACClientErrorNoLogin = 1992,                  //请先调用登录接口
    ACClientErrorTimeout = 1993,                  //超时错误
    ACClientErrorRequestWrongFormat = 1997,       //未设置ACMsg的payloadFormat
    ACClientErrorRequestNetworkError = 1998       //网络错误
};

static inline NSError* ACErrorMake(NSInteger errorCode, NSString *error, NSString *desc) {
    return [NSError errorWithDomain:errorCode < 3000 ? @"ACClientError" : @"ACCloudError"
                               code:errorCode
                           userInfo:@{
                                      @"errorInfo" : error ? : @"",
                                      @"errorDescription" : desc ? : @""
                                      }];
}

#endif /* ACloudLibConst_h */
