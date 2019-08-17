//
//  ACDevicePropertySearchOption.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/20.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  检索设备历史属性历史记录的排序方式
 */
typedef NS_ENUM(NSInteger, ACDataSearchOrder) {
    ACDataSearchOrderOrderDesc = 2, //降序检索 从新数据往旧数据查询
    ACDataSearchOrderOrderAsc = 1 //升序检索 从旧数据往新数据查询
};

@class ACObject;

/** 检索设备历史属性记录选项 */
@interface ACDevicePropertySearchOption : NSObject

/** 子域 */
@property (nonatomic, copy) NSString *subDomain;

/** 设备逻辑id */
@property (nonatomic, assign) NSInteger deviceId;

/**
 *  检索起始时间
 *  @discussion 需要检索的起始时间,没有则传入0。
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 *  检索终止时间。
 *  @discussion 当前最早的时间,没有则传入0。
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/**
 *  检索条数
 *  @discussion 最大限制1000条 默认20条
 */
@property (nonatomic, assign) NSUInteger limit;

/**
 *  检索设备属性数据的字段集合。如：@[@"propKey0", @"propKey1", @"propKey2"]
 *  @discussion 若不设置则为检索全部属性字段
 */
@property (nonatomic, copy) NSArray<NSString *> *selectProps;

/** 检索顺序 */
@property (nonatomic, assign) ACDataSearchOrder order;

/** 检索设备属性过滤条件。 */
@property (nonatomic, strong, readonly) ACObject *propFilter;

/**
 *  初始化查询条件：检索所有属性字段最新的20条数据
 *  @param subDomain 设备子域
 *  @param deviceId 设备逻辑 id
 */
- (instancetype)initWithSubDomain:(NSString *)subDomain
                         deviceId:(NSInteger)deviceId;

/**
 *  初始化查询条件：检索指定时间范围内指定 limit 数量的属性数据
 *  @param subDomain 设备子域
 *  @param deviceId 设备逻辑 id
 *  @param startTime 检索条件开始时间
 *  @param endTime 检索条件结束时间
 *  @param limit 检索数据结果数量
 */
- (instancetype)initWithSubDomain:(NSString *)subDomain
                         deviceId:(NSInteger)deviceId
                        startTime:(NSTimeInterval)startTime
                          endTime:(NSTimeInterval)endTime
                            limit:(NSInteger)limit;

/**
 *  设置检索条件 filterKey = value
 *  value可为：@"value"或@(11)或@(11.22)或@(YES)
 *  @param filterKey 检索的属性键
 *  @param value 检索的属性值
 */
- (instancetype)filter:(NSString *)filterKey equalTo:(id)value;

/**
 *  设置检索条件 filterKey < value
 *  value可为：@"value"或@(11)或@(11.22)或@(YES)
 *  @param filterKey 检索的属性键
 *  @param value 检索的属性值
 */
- (instancetype)filter:(NSString *)filterKey lessThan:(id)value;

/**
 *  设置检索条件 filterKey > value
 *  value可为：@"value"或@(11)或@(11.22)或@(YES)
 *  @param filterKey 检索的属性键
 *  @param value 检索的属性值
 */
- (instancetype)filter:(NSString *)filterKey greaterThan:(id)value;

/**
 *  设置检索条件 filterKey <= value
 *  value可为：@"value"或@(11)或@(11.22)或@(YES)
 *  @param filterKey 检索的属性键
 *  @param value 检索的属性值
 */
- (instancetype)filter:(NSString *)filterKey lessOrEqualTo:(id)value;

/**
 *  设置检索条件 filterKey >= value
 *  value可为：@"value"或@(11)或@(11.22)或@(YES)
 *  @param filterKey 检索的属性键
 *  @param value 检索的属性值
 */
- (instancetype)filter:(NSString *)filterKey greaterOrEqualTo:(id)value;

@end
