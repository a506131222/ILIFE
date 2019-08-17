//
//  ACPushManager.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/10/12.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACPushTable.h"
#import "ACPushReceive.h"
#import "AFNetworking.h"

/**
 * 推送连接状态
 */
typedef NS_ENUM(NSInteger, ACPushConnectionStatus) {
    ACPushConnectionStatusConnected = 1, //推送连接已建立
    ACPushConnectionStatusDisConnected, //推送连接已断开
};

@interface ACPushManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * 获取对象单例
 * @return 对象单例
 */
+ (instancetype)sharedManager;

/**
 * 建立与服务器的连接
 * @param callback 连接回调
 */
- (void)connectWithCallback:(void(^)(NSError * error))callback;

/**
 * 订阅实时数据

 * @param table    数据表
 * @param callback 订阅回调
 */
- (void)watchWithTable:(ACPushTable *)table Callback:(void(^)(NSError * error))callback;

/**
 * 接收已经订阅的实时数据
 * @param callback 实时数据
 */
- (void)onReceiveWithCallback:(void(^)(ACPushReceive * pushReceive ,NSError * error))callback;

/**
 * 取消已经订阅的实时数据

 * @param table    数据表
 * @param callback 取消订阅回调
 */
- (void)unWatchWithPushTable:(ACPushTable *)table Callback:(void(^)(NSError * error))callback;

/**
 * 取消订阅当前所有已订阅的表
 */
- (void)unWatchAll;

/**
 * 断开与服务器的连接
 */
- (void)disconnect;

/**
 * 监听连接状态变更
 * @param callback 状态改变回调
 */
- (void)monitorStatusChangeBlock:(void(^)(ACPushConnectionStatus status))callback;

@end
