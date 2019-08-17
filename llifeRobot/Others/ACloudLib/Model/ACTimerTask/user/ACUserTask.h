//
//  ACUserTask.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/16.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 任务当前状态 */
typedef NS_ENUM(NSUInteger, ACUserTaskStatus) {
    ACUserTaskStatusClose, //已关闭
    ACUserTaskStatusOpen //已开启
};

@class ACUserCommand;
@class ACTimeRule;
@interface ACUserTask : NSObject
/** 任务名称 */
@property (nonatomic, copy) NSString *name;
/** 任务描述 */
@property (nonatomic, copy) NSString *desc;
/** 执行时间规则 */
@property (nonatomic, strong) ACTimeRule *timeRule;
/** 命令 */
@property (nonatomic, strong) ACUserCommand *command;
/** 任务创建时间 */
@property (nonatomic, copy, readonly) NSString *createTime;
/** 任务修改时间 */
@property (nonatomic, copy, readonly) NSString *modifyTime;
/** 任务所属人id */
@property (nonatomic, copy, readonly) NSString *ownerId;
/** 任务所属人类型 */
@property (nonatomic, copy, readonly) NSString *ownerType;
/** 任务类型 */
@property (nonatomic, copy, readonly) NSString *type;
/** 任务id */
@property (nonatomic, assign, readonly) NSInteger taskId;
/** 任务当前状态 */
@property (nonatomic, assign, readonly) ACUserTaskStatus status;

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
                     command:(ACUserCommand *)command;

+ (instancetype)taskWithDict:(NSDictionary *)dict;



- (NSData *)marshal;
- (NSDictionary *)toJSON;

@end
