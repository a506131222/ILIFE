//
//  ACPushTable.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/10/12.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//
#import "ACObject.h"
#import <Foundation/Foundation.h>

/** 数据集操作类型 */
typedef NS_OPTIONS(NSUInteger, ACPushTableOpType) {
    OPTYPE_CREATE   = 1 << 0,
    OPTYPE_REPLACE  = 1 << 1,
    OPTYPE_UPDATE   = 1 << 2,
    OPTYPE_DELETE   = 1 << 3,
};

@interface ACPushTable : NSObject<NSCoding>

/** 订阅的表名 */
@property (nonatomic, copy) NSString *className;

/** 监听主键，此处对应添加数据集时的监控主键(监控主键必须是数据集主键的子集) */
@property (nonatomic, strong) ACObject *primaryKey;

/** 监听类型，如以下为只要发生创建、删除、替换、更新数据集的时候即会推送数据 */
@property (nonatomic, assign) ACPushTableOpType opType;

- (BOOL)isEqual:(ACPushTable *)table;

@end
