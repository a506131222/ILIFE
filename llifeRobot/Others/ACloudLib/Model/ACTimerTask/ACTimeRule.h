//
//  ACTimeRule.h
//  AbleCloudLib
//
//  Created by __zimu on 16/6/24.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACTimeRule : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*
 * @param timeZone    时区, 如果不设置, 默认是系统当前时区
 *
 * @param timeCycle   **字段均使用小写字母**
 *                    单次定时任务：once
 *                    循环定时任务：按分重复：min
 *                    按小时重复：hour
 *                    按天重复：day
 *                    按月重复：month
 *                    按年复复：year
 *                    星期循环任务：week[0，1，2，3，4，5，6] 如只在周一和周五重复，则表示为@"week[1，5]"
 * @param timePoint   任务时间点，时间格式统一为："yyyy-MM-dd HH:mm:ss", 如2016-07-08 16:39:03
 *                    timePoint的格式为统一标准格式, 但是实际使用的时候是向后解析, 即:
                      如果是week循环任务, 只需要关注`-08 16:39:03`;  `2016-07`    不起作用, 只为统一格式
                      如果是day 循环任务, 只需要关注    `16:39:03`;  `2016-07-08` 不起作用, 只为统一格式
                      其余的循环周期做同样处理
 */
- (instancetype)initWithTimeZone:(NSTimeZone *)timeZone timeCycle:(NSString *)timeCycle timePoint:(NSString *)timePoint;

+ (instancetype)timeRuleWithDict:(NSDictionary *)dict;

- (NSDictionary *)marshal;

@end
