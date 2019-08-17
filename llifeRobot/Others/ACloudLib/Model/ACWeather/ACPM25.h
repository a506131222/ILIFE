//
//  ACPM25.h
//  AbleCloudLib
//
//  Created by __zimu on 16/3/31.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPM25 : NSObject

/** 
 * 获取最新一次时间格式为"yyyy-MM-dd HH:mm:ss"
 * 获取最近几天时间格式为"yyyy-MM-dd"
 * 获取最近几小时时间格式为"yyyy-MM-dd HH"
 */
@property (nonatomic, copy) NSString *timestamp;
/** 平均值 */
@property (nonatomic, assign) NSInteger PM25;
/** 最小值 */
@property (nonatomic, assign) NSInteger minPM25;
/** 最大值 */
@property (nonatomic, assign) NSInteger maxPM25;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)pm25WithDict:(NSDictionary *)dict;

@end
