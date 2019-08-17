//
//  ACRankingValue.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/6/22.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACObject;
@interface ACRankingValue : NSObject

/** 某个时间段的起始时间戳 */
@property (nonatomic, assign, readonly) long timestamp;
/** userId */
@property (nonatomic, assign, readonly) NSInteger userId;
/** score */
@property (nonatomic, assign, readonly) double score;
/** 排名  -1:代表在这个时间段内不存在数据 */
@property (nonatomic, assign, readonly) long place;
/** 用户拓展属性 */
@property (nonatomic, strong) ACObject *profile;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)rankingValueWithDict:(NSDictionary *)dict;

@end
