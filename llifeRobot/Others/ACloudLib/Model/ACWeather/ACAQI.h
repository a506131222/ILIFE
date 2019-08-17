//
//  ACAQI.h
//  AbleCloudLib
//
//  Created by __zimu on 16/3/31.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACAQI : NSObject

/**
 * 获取最新一次时间格式为"yyyy-MM-dd HH:mm:ss"
 * 获取最近几天时间格式为"yyyy-MM-dd"
 * 获取最近几小时时间格式为"yyyy-MM-dd HH"
 */
@property (nonatomic, copy) NSString *timestamp;
/** 空气质量 */
@property (nonatomic, assign) NSInteger AQI;
/** 最小值 */
@property (nonatomic, assign) NSInteger minAQI;
/** 最大值 */
@property (nonatomic, assign) NSInteger maxAQI;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)aqiWithDict:(NSDictionary *)dict;

@end
