//
//  ACClassTopic.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/9.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopic.h"

/**
 * 数据集操作类型订阅
 */
typedef NS_OPTIONS(NSUInteger, ACClassDataOperationType) {
    ACClassDataOperationTypeCreate   = 1 , //数据集新增数据
    ACClassDataOperationTypeReplace  = 1 << 1, //数据集替换数据
    ACClassDataOperationTypeUpdate   = 1 << 2, //数据集更新数据
    ACClassDataOperationTypeDelete   = 1 << 3 //数据集删除数据
};

@class ACObject;

@interface ACClassTopic : ACTopic

/** 订阅的表名 */
@property (nonatomic, copy) NSString *className;
/** 监听主键，此处对应添加数据集时的监控主键(监控主键必须是数据集主键的子集) */
@property (nonatomic, strong) ACObject *primaryKey;
/** 监听类型，如以下为只要发生创建、删除、替换、更新数据集的时候即会推送数据 */
@property (nonatomic, assign) ACClassDataOperationType opType;

/**
 * 初始化自定义类型订阅对象实例
 * @param className 订阅的表名
 * @param primaryKey 监听主键
 * @param opType 监听数据操作类型
 * @return 订阅对象实例
 */
- (instancetype)initWithClassName:(NSString *)className
                       primaryKey:(ACObject *)primaryKey
                           opType:(ACClassDataOperationType)opType;

@end
