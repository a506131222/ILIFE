//
//  ACTimerTask.h
//  AbleCloudLib
//
//  Created by zhourx5211 on 7/17/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACTimerTask : NSObject

@property (assign, nonatomic) NSInteger taskId;
/** 任务的类型（onceTask） */
@property (strong, nonatomic) NSString *taskType;
/** 创建该用户的逻辑ID */
@property (assign, nonatomic) NSInteger userId;
/** 创建该用户的昵称 */
@property (strong, nonatomic) NSString *nickName;
/** 任务名称 */
@property (strong, nonatomic) NSString *name;
/** 任务描述 */
@property (strong, nonatomic) NSString *desp;
/** 任务时区 */
@property (strong, nonatomic) NSString *timeZone;
/** 任务时间点 */
@property (strong, nonatomic) NSString *timePoint;
/** 任务时间周期 */
@property (strong, nonatomic) NSString *timeCycle;
/** 创建任务时间 */
@property (strong, nonatomic) NSString *createTime;
/** 修改任务时间 */
@property (strong, nonatomic) NSString *modifyTime;
/** 任务执行状态 0停止 1执行 */
@property (assign, nonatomic) NSInteger status;

@end
