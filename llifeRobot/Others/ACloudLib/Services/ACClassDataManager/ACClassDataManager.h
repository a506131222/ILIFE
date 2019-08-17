//
//  ACClassDataManager.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/19.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACClassTopic.h"

@class ACObject;

@interface ACClassDataManager : NSObject

/**
 * 订阅数据集类型推送消息 注：默认对所有类型的数据集操作进行推送
 * @param className 订阅的数据集名称
 * @param primaryKey 订阅的数据集主键
 */
+ (void)subscribeClass:(NSString *)className
            primaryKey:(ACObject *)primaryKey
              callback:(void(^)(NSError *error))callback;

/**
 * 订阅数据集类型推送消息
 * @param className 订阅的数据集名称
 * @param primaryKey 订阅的数据集主键
 * @param operationType 订阅的数据集操作类型 可多选如：ACClassDataOperationTypeCreate|ACClassDataOperationTypeReplace
 */
+ (void)subscribeClass:(NSString *)className
            primaryKey:(ACObject *)primaryKey
         operationType:(ACClassDataOperationType)operationType
              callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅数据集类型推送消息 注：默认取消有类型的数据集操作推送
 * @param className 订阅的数据集名称
 * @param primaryKey 订阅的数据集主键
 */
+ (void)unSubscribeClass:(NSString *)className
              primaryKey:(ACObject *)primaryKey
                callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅数据集类型推送消息
 * @param className 订阅的数据集名称
 * @param primaryKey 订阅的数据集主键
 * @param operationType 订阅的数据集操作类型 可多选如：ACClassDataOperationTypeCreate|ACClassDataOperationTypeReplace
 */
+ (void)unSubscribeClass:(NSString *)className
              primaryKey:(ACObject *)primaryKey
           operationType:(ACClassDataOperationType)operationType
                callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有数据集类型推送消息
 */
+ (void)unSubscribeAllClassData;

/**
 * 设置数据集推送信息回调
 * @param handler 用于回调消息
 */
+ (void)setClassMessageHandler:(void (^)(NSString *className,
                                         ACClassDataOperationType opType,
                                         ACObject *payload))handler;

@end
