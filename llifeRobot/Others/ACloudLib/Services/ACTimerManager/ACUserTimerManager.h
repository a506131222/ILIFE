//
//  ACUserTimerManager.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/15.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACUserTask;
@class ACUserTaskGroup;
@interface ACUserTimerManager : NSObject

/**
 * 添加用户定时任务
 * @param task     定时任务对象
 * @param callback 定时任务对象
 */
- (void)addTask:(ACUserTask *)task
       callback:(void(^)(ACUserTask *task, NSError *error))callback;

/**
 * 修改用户定时任务,
 * 注: 修改是`覆盖修改`, 即以最后一次上传的数据为准, 以前的数据会被覆盖掉
 * @param task     定时任务对象
 * @param callback 定时任务对象
 */
- (void)modifyTask:(ACUserTask *)task
          callback:(void(^)(ACUserTask *task, NSError *error))callback;

/**
 * 开启用户定时任务
 * @param taskId   任务id
 * @param callback 开启结果
 */
- (void)openTask:(NSInteger)taskId
        callback:(void(^)(NSError *error))callback;

/**
 * 关闭用户定时任务
 * @param taskId   任务id
 * @param callback 关闭结果
 */
- (void)closeTask:(NSInteger)taskId
         callback:(void(^)(NSError *error))callback;

/**
 * 删除用户定时任务
 * @param taskId   任务id
 * @param callback 删除结果
 */
- (void)deleteTask:(NSInteger)taskId
          callback:(void(^)(NSError *error))callback;

/**
 * 获取用户定时任务列表
 * @param callback 定时任务列表
 */
- (void)listTask:(void(^)(NSArray<ACUserTask *> *tasks, NSError *error))callback;


#pragma mark - 任务组

/**
 * 添加用户定时任务组
 * @param tasks     用户定时任务数组
 * @param groupName 任务组名称
 * @param callback  任务组回调对象
 */

- (void)addTasks:(NSArray<ACUserTask *> *)tasks
         toGroup:(NSString *)groupName
        callback:(void(^)(ACUserTaskGroup *taskGroup, NSError *error))callback;

/**
 * 修改用户定时任务组
 * 注: 修改是`覆盖修改`, 即以最后一次上传的数据为准, 以前的数据会被覆盖掉
 * @param taskGroup 用户定时任务组
 * @param callback  任务组回调s
 */
- (void)modifyTaskGroup:(ACUserTaskGroup *)taskGroup
               callback:(void(^)(ACUserTaskGroup *taskGroup, NSError *error))callback;

/**
 * 开启用户定时任务组
 * @param taskGroupId 任务组id
 * @param callback    开启结果回调
 */
- (void)openTaskGroup:(NSString *)taskGroupId
             callback:(void(^)(NSError *error))callback;

/**
 * 关闭用户定时任务组
 * @param taskGroupId 任务组id
 * @param callback    关闭结果回调
 */
- (void)closeTaskGroup:(NSString *)taskGroupId
              callback:(void(^)(NSError *error))callback;

/**
 * 删除用户定时任务组
 * @param taskGroupId 任务组id
 * @param callback    删除结果回调
 */
- (void)deleteTaskGroup:(NSString *)taskGroupId
               callback:(void(^)(NSError *error))callback;

/**
 * 获取用户定时任务组列表
 * @param callback 用户定时任务组列表
 */
- (void)listTaskGroup:(void(^)(NSArray<ACUserTaskGroup *> *taskGroup, NSError *error))callback;

@end
