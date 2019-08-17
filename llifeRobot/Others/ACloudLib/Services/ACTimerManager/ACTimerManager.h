//
//  ACTimerManager.h
//  AbleCloudLib
//
//  Created by zhourx5211 on 7/17/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACTimerTask.h"
#import "ACDeviceMsg.h"
#import "ACloudLibConst.h"

//任务组的类型
typedef NS_ENUM(NSUInteger, ACTaskGroupType) {
    //设备任务组
    ACTaskGroupTypeDevice = 1,
    //用户任务组
    ACTaskGroupTypeUser,
};

@class ACGroupTask;
@class ACGroup;
@interface ACTimerManager : NSObject

@property (strong, nonatomic) NSTimeZone *timeZone;

- (id)initWithTimeZone:(NSTimeZone *)timeZone;

/**
 * 创建定时任务
 *
 * @param deviceId    设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param timePoint   任务时间点，时间格式为："yyyy-MM-dd HH:mm:ss",比如2015-08-08 16:39:03
 * @param timeCycle   单次定时任务：once
 *                    循环定时任务：按分重复：min
 *                    按小时重复：hour
 *                    按天重复：day
 *                    按月重复：month
 *                    按年复复：year
 *                    星期循环任务：week[0,1,2,3,4,5,6]如周一，周五重复，则表示为week[1,5]
 * @param deviceMsg         具体的消息内容
 * @param ontype      0:云端定时 1:设备定时
 * @param callback    返回结果的监听回调
 */
- (void)addTaskWithDeviceId:(NSInteger)deviceId
                       name:(NSString *)name
                  timePoint:(NSString *)timePoint
                  timeCycle:(NSString *)timeCycle
                  deviceMsg:(ACDeviceMsg *)deviceMsg
                     OnType:(NSInteger)ontype
                   callback:(void (^)(NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`addTask:`方法");

/**
 * 修改定时任务
 *
 * @param deviceId    设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param taskId      任务id
 * @param timePoint   任务时间点，时间格式为："yyyy-MM-dd HH:mm:ss",比如2015-08-08 16:39:03
 * @param timeCycle   单次定时任务：once
 *                    循环定时任务：按分重复：min
 *                    按小时重复：hour
 *                    按天重复：day
 *                    按月重复：month
 *                    按年复复：year
 *                    星期循环任务：week[0,1,2,3,4,5,6]如周一，周五重复，则表示为week[1,5]
 * @param deviceMsg         具体的消息内容
 * @param callback    返回结果的监听回调
 */
- (void)modifyTaskWithDeviceId:(NSInteger)deviceId
                        taskId:(NSInteger)taskId
                          name:(NSString *)name
                     timePoint:(NSString *)timePoint
                     timeCycle:(NSString *)timeCycle
                     deviceMsg:(ACDeviceMsg *)deviceMsg
                      callback:(void (^)(NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`modifyTask:`方法");

/**
 * 开启定时任务
 *
 * @param deviceId 设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param taskId   任务id
 * @param callback 返回结果的监听回调
 */
- (void)openTaskWithDeviceId:(NSInteger)deviceId
                      taskId:(NSInteger)taskId
                    callback:(void (^)(NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`openTask:`方法");

/**
 * 关闭定时任务
 *
 * @param deviceId 设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param taskId   任务id
 * @param callback 返回结果的监听回调
 */
- (void)closeTaskWithDeviceId:(NSInteger)deviceId
                       taskId:(NSInteger)taskId
                     callback:(void (^)(NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`closeTask:`方法");

/**
 * 删除定时任务
 *
 * @param deviceId 设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param taskId   任务id
 * @param callback 返回结果的监听回调
 */
- (void)deleteTaskWithDeviceId:(NSInteger)deviceId
                        taskId:(NSInteger)taskId
                      callback:(void (^)(NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`deleteTask:`方法");

/**
 * 获取定时任务列表
 *
 * @param deviceId 设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param callback 返回结果的监听回调
 */
- (void)listTasksWithDeviceId:(NSInteger)deviceId
                     callback:(void (^)(NSArray *timerTaskArray, NSError *error))callback ACDeprecated("接口已废弃, 请使用`ACDeviceTimerManager`中的`listTask:`方法");
@end
