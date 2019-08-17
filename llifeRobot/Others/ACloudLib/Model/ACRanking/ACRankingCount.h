//
//  ACRankingCount.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/6/22.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACRankingCount : NSObject
/** 某个时间段的起始时间戳 */
@property (nonatomic, assign, readonly) long timestamp;
/** 数量 */
@property (nonatomic, assign, readonly) long count;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)rankingCountWithDict:(NSDictionary *)dict;

@end
