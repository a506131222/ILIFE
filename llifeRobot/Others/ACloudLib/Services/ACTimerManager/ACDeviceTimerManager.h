//
//  ACDeviceTimerManager.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/15.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACDeviceTask;
@class ACDeviceTaskGroup;
@interface ACDeviceTimerManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
/**
 * 生成Manager实例

 * @param deviceId 要添加任务的设备逻辑id
 * @return manager 实例
 */
- (instancetype)initWithDeviceId:(NSInteger)deviceId;

/**
 * 添加设备定时任务

 * @param task     设备任务对象
 * @param callback 设备任务对象
 */
- (void)addTask:(ACDeviceTask *)task
       callback:(void(^)(ACDeviceTask *task, NSError *error))callback;

/**
 * 修改设备定时任务
 * 注: 修改是`覆盖修改`, 即以最后一次上传的数据为准, 以前的数据会被覆盖掉
 
 * @param task     设备任务对象
 * @param callback 设备任务对象
 */
- (void)modifyTask:(ACDeviceTask *)task
          callback:(void(^)(ACDeviceTask *task, NSError *error))callback;

/**
 * 开启设备定时任务

 * @param taskId   任务id
 * @param callback 开启结果
 */
- (void)openTask:(NSString *)taskId
        callback:(void(^)(NSError *error))callback;

/**
 * 关闭设备定时任务

 * @param taskId   任务id
 * @param callback 关闭结果
 */
- (void)closeTask:(NSString *)taskId
         callback:(void(^)(NSError *error))callback;

/**
 * 删除设备定时任务

 * @param taskId  任务id
 * @param callbac 删除结果
 */
- (void)deleteTask:(NSString *)taskId
          callback:(void(^)(NSError *error))callbac;

/**
 * 获取设备定时任务列表

 * @param callback 定时任务列表
 */
- (void)listTask:(void(^)(NSArray<ACDeviceTask *> *tasks, NSError *error))callback;

#pragma mark - 任务组

/**
 * 添加设备定时任务组

 * @param tasks     设备定时任务数组
 * @param groupName 任务组名称
 * @param callback  任务组回调对象
 */
- (void)addtasks:(NSArray<ACDeviceTask *> *)tasks
         toGroup:(NSString *)groupName
        callback:(void(^)(ACDeviceTaskGroup *taskGroup, NSError *error))callback;

/**
 * 修改设备定时任务组
 * 注: 修改是`覆盖修改`, 即以最后一次上传的数据为准, 以前的数据会被覆盖掉
 
 * @param task     设备定时任务组
 * @param callback 任务组回调
 */
- (void)modifyTaskGroup:(ACDeviceTaskGroup *)task
          callback:(void(^)(ACDeviceTaskGroup *taskGroup, NSError *error))callback;

/**
 * 开始设备定时任务组

 * @param taskGroupId 任务组id
 * @param callback    开启结果回调
 */
- (void)openTaskGroup:(NSString *)taskGroupId
        callback:(void(^)(NSError *error))callback;

/**
 * 关闭设备定时任务组

 * @param taskGroupId 任务组id
 * @param callback    关闭结果回调
 */
- (void)closeTaskGroup:(NSString *)taskGroupId
         callback:(void(^)(NSError *error))callback;

/**
 * 删除设备定时任务组

 * @param taskGroupId 任务组id
 * @param callback    删除结果回调
 */
- (void)deleteTaskGroup:(NSString *)taskGroupId
          callback:(void(^)(NSError *error))callback;

/**
 * 获取设备定时任务组列表

 * @param callback 设备定时任务组列表
 */
- (void)listTaskGroup:(void(^)(NSArray<ACDeviceTaskGroup *> *taskGroup, NSError *error))callback;


@end

