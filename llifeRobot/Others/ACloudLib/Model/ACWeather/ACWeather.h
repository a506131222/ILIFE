//
//  ACWeather.h
//  AbleCloudLib
//
//  Created by __zimu on 16/3/31.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACWeather : NSObject

/** 
 * 获取最新一次时间格式为"yyyy-MM-dd HH:mm:ss"
 * 获取最近几天时间格式为"yyyy-MM-dd"
 * 获取最近几小时时间格式为"yyyy-MM-dd HH"
 */
@property (nonatomic, copy) NSString *timestamp;
/** 温度 */
@property (nonatomic, copy) NSString *temperature;
/** 最低温度 */
@property (nonatomic, copy) NSString *minTemperature;
/** 最高温度 */
@property (nonatomic, copy) NSString *maxTemperature;
/** 湿度 */
@property (nonatomic, assign) NSInteger humidity;
/** 最低湿度 */
@property (nonatomic, assign) NSInteger minHumidity;
/** 最高湿度 */
@property (nonatomic, assign) NSInteger maxHumidity;
/** pm25 */
@property (nonatomic, assign) NSInteger pm25;
/** condTxt (晴,雨) */
@property (nonatomic, copy) NSString *condTxt;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)weatherWithDict:(NSDictionary *)dict;

@end
