//
//  ACDeviceTaskGroup.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/18.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACDeviceTask;
@interface ACDeviceTaskGroup : NSObject
/** 任务组id */
@property (nonatomic, copy) NSString *groupId;
/** 任务组名称 */
@property (nonatomic, copy) NSString *name;
/** 任务数组 */
@property (nonatomic, strong) NSArray<ACDeviceTask *> *tasks;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)groupWithDict:(NSDictionary *)dict;
@end
