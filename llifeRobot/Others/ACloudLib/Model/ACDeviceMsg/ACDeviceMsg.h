//
//  ACDeviceMsg.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/25/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ACloudLibConst.h"

/** 设备通讯的安全性设置 */
typedef NS_ENUM(NSUInteger, ACDeviceSecurityMode) {
    ACDeviceSecurityModeNone, //不加密
    ACDeviceSecurityModeStatic, //静态加密, 即使用默认秘钥
    ACDeviceSecurityModeDynamic, //动态加密,使用云端分配的秘钥
};

@class ACObject;
@interface ACDeviceMsg : NSObject
/** 消息id */
@property (nonatomic, assign) NSInteger msgId;
/** 消息code */
@property (nonatomic, assign) NSInteger msgCode;
/** 消息内容 */
@property (nonatomic, strong) NSData *payload;
/** ACDeviceMsgOption */
@property (nonatomic, copy) NSArray *optArray;
/** 消息描述 */
@property (nonatomic, copy) NSString *describe;
/** 用来区分设备固件版本, 开发者不需要使用 */
@property (nonatomic, assign) NSInteger deviceVersion;
/** 与设备通讯的安全性级别, 默认是动态加密 */
@property (nonatomic, assign, readonly) ACDeviceSecurityMode securePolicy ACDeprecated("不再有效，App端无需关注局域网加密方式，由硬件决定。");
/**
 * 设置局域网通讯安全模式
 * @discussion 如果不设置, 默认为动态加密
 * @param mode 设备通讯的安全性设置选项
 */
- (void)setSecurityMode:(ACDeviceSecurityMode)mode ACDeprecated("不再有效，App端无需关注局域网加密方式，由硬件决定。");

#pragma mark - 初始化器
/**
 * 初始化
 * @param code 设备通讯的安全性设置选项
 * @param payloadObject 消息内容
 */
- (instancetype)initWithCode:(NSInteger)code ACObject:(ACObject *)payloadObject;
/**
 * 获取消息内容
 * @return ACObject
 */
- (ACObject *)getACObject;

/**
 * 初始化
 * @param code 设备通讯的安全性设置选项
 * @param binaryData 二进制数据
 */
- (instancetype)initWithCode:(NSInteger)code binaryData:(NSData *)binaryData;
/**
 * 获取消息内容（二进制）
 * @return NSData
 */
- (NSData *)getBinaryData;

#pragma mark - 解析器
+ (instancetype)unmarshalWithData:(NSData *)data;
+ (instancetype)unmarshalWithData:(NSData *)data
                           AESKey:(NSData *)AESKey;
+ (instancetype)unmarshalWithHttpBodyData:(NSData *)data
                                   AESKey:(NSData *)AESKey;
- (NSData *)marshal;
- (NSData *)marshalWithAESKey:(NSData *)AESKey;
- (NSData *)marshalHttpBodyWithAESKey:(NSData *)AESKey;

@end
