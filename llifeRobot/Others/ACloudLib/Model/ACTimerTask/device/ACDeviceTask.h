//
//  ACDeviceTask.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/16.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACloudLibConst.h"

typedef NS_ENUM(NSUInteger, ACDeviceTaskStatus) {
    ACDeviceTaskStatusClose,
    ACDeviceTaskStatusOpen,
};

@class ACTimeRule;
@class ACDeviceCommand;
@interface ACDeviceTask : NSObject
/** 任务名称 */
@property (nonatomic, copy) NSString *name;
/** 任务描述 */
@property (nonatomic, copy) NSString *desc;
/** 任务标记(用于添加自定义的扩展字段) */
@property (nonatomic, copy) NSString *tag;
/** 定时规则 */
@property (nonatomic, strong) ACTimeRule *timeRule;
/** 命令 */
@property (nonatomic, strong) ACDeviceCommand *command;
/** 创建时间 */
@property (nonatomic, copy, readonly) NSString *createTime;
/** 修改时间 */
@property (nonatomic, copy, readonly) NSString *modifyTime;
/** 任务所属人 */
@property (nonatomic, copy, readonly) NSString *ownerId;
/** 任务所属人类型 */
@property (nonatomic, copy, readonly) NSString *ownerType;
/** 任务类型 */
@property (nonatomic, copy, readonly) NSString *type;
/** 任务id */
@property (nonatomic, copy, readonly) NSString *taskId;
/** 任务状态 */
@property (nonatomic, assign, readonly) ACDeviceTaskStatus status;

- (instancetype)init NS_UNAVAILABLE;

/**
 * 生成一条发送给uds的用户定时任务
 * @param name     定时任务名称
 * @param desc     任务简介
 * @param timeRule 任务的执行时间
 * @param command  发送给UDS的任务指令
 * @return 任务对象实例
 */
- (instancetype)initWithName:(NSString *)name
                        desc:(NSString *)desc
                    timeRule:(ACTimeRule *)timeRule
                     command:(ACDeviceCommand *)command ACDeprecated("接口已废弃, 请使用`initWithName:desc:tag:timeRule:command:`方法");

- (instancetype)initWithName:(NSString *)name
                        desc:(NSString *)desc
                         tag:(NSString *)tag
                    timeRule:(ACTimeRule *)timeRule
                     command:(ACDeviceCommand *)command;

+ (instancetype)taskWithDict:(NSDictionary *)dict;
@end
