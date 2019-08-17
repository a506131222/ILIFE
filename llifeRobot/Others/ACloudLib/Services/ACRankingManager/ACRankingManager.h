//
//  ACRankingManager.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/6/22.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ACRankingPeriod) {
    ACRankingPeriodDay = 1,     //天
    ACRankingPeriodWeek,        //星期
    ACRankingPeriodMonth,       //月
};

typedef NS_ENUM(NSUInteger, ACRankingOrder) {
    //顺序
    ACRankingOrderASC = 1,
    //逆序
    ACRankingOrderDESC,
};

@class ACRankingValue;
@class ACRankingCount;
@interface ACRankingManager : NSObject

/**
 * 增加或减少当前用户的分值(原有分值进行累加),如果存在多个排行周期,全部累加更新
 * 用于数据累积类排行榜,比如记步,游戏积分等,不能和覆盖类排行榜的set接口混用.
 *
 * @param name      排行榜名称
 * @param timestamp 时间点,如果为0,则表示当前时间(单位秒,UTC时间戳，相对于1970年的秒数)
 * @param score     当前用户增加/减少的分值
 * @param callback  错误回调
 */
+ (void)incScore:(double)score
         forName:(NSString *)name
   withTimestamp:(long)timestamp
        callback:(void(^)(NSError *error))callback;

/**
 * 设置更新当前用户分值(原有分值会被覆盖),如果存在多个排行周期,都会只保留最后一次分值
 * 用于数据覆盖类排行榜,比如空气质量,体重测量等,不能和累积类排行榜的inc接口混用.
 *
 * @param name      排行榜名称
 * @param timestamp 时间点,如果为0,则表示当前时间(单位秒,UTC时间戳，相对于1970年的秒数)
 * @param score     更新分值
 * @param callback  错误回调
 */
+ (void)setScore:(double)score
         forName:(NSString *)name
   withTimestamp:(long)timestamp
        callback:(void(^)(NSError *error))callback;

/**
 * 获取当前用户指定排行周期内(比如当天)的分值和排名
 *
 * @param name      排行榜名称
 * @param period    排行榜周期 (day, week, month)
 * @param timestamp 时间点，如果为0，则表示当前时间所在排行榜(UTC时间戳，相对于1970年的秒数)
 * @param order     排序方式: ASC(正序), DESC(逆序）
 * @param callback  当前用户某一时间点所在排行周期的分值和排名
 */
+ (void)rankingValueWithName:(NSString *)name
                      period:(ACRankingPeriod)period
                   timestamp:(long)timestamp
                       order:(ACRankingOrder)order
                    callback:(void(^)(ACRankingValue *rankingValue, NSError *error))callback;

/**
 * 批量获取当前用户连续多个分值和排名等历史数据(比如上周每天)
 * 如取当前用户最近5天的排行数据(value以正序方式排名, 表的名字为"ranking"),则使用:
 
     [ACRankingManager ranksWithName:@"ranking"
                              period:ACRankingPeriodDay
                           timestamp:0
                               count:5
                               order:ACRankingOrderASC
                            callback:^(NSArray<ACRankingValue *> *list, NSError *error) {
                                //list中包含当前用户最近五天的数据
                            }];

 * 从服务器拿到的数据是根据你输入的时间点 `向前`(即更早的时间)取值
 
 * 如取当前用户上一周(即上周一到上周日)每天的排行数据, 则需要把时间戳设置为上周日, 假设今天是星期三, 则设置的时间戳为:
     long time = [NSDate date].timeIntervalSince1970 - 3(周三) * 24 * 60 * 60;
 
 * 此刻的 time 表示的是上周日的时间点, 然后再根据这个时间点 `向前` 取7天的数据, 即表示从上周一到上周日的数据, 代码如下:
 
     long time = [NSDate date].timeIntervalSince1970 - 3 * 24 * 60 * 60;
     [ACRankingManager ranksWithName:@"ranking"
                              period:ACRankingPeriodDay
                           timestamp:time
                               count:7
                               order:ACRankingOrderASC
                            callback:^(NSArray<ACRankingValue *> *list, NSError *error) {
                                //list中包含当前用户上周七天的数据
                            }];

 * @param name      排行榜名称
 * @param period    排行榜周期, 详见`ACRankingPeriod`枚举
 * @param timestamp 时间点，如果为0，则表示当前时间所在排行榜(UTC时间戳，相对于1970年的秒数)
 * @param count     向前取连续count个period周期
 * @param order     排序方式: ASC(正序), DESC(逆序）
 * @param callback  当前用户在指定周期内的历史排行
 */
+ (void)ranksWithName:(NSString *)name
               period:(ACRankingPeriod)period
            timestamp:(long)timestamp
                count:(long)count
                order:(ACRankingOrder)order
             callback:(void(^)(NSArray<ACRankingValue *> *list, NSError *error))callback;
/**
 * 获取指定某个排行周期内(比如当天)的所有参与排行的用户总数
 
 * 如查询当天的用户总数
 
     [ACRankingManager totalCountWithName:@"ranking"
                                     period:ACRankingPeriodDay
                                  timestamp:0
                                      order:ACRankingOrderASC
                                   callback:^(ACRankingValue *rankingCount, NSError *error) {
                                      //...
                                   }];

 
 * @param name      排行榜名称
 * @param period    排行榜周期(day, week, month)
 * @param timestamp 时间点，如果为0，则表示当前时间所在排行榜(UTC时间戳，相对于1970年的秒数)
 * @param callback  所有参与排行的用户总数
 */
+ (void)totalCountWithName:(NSString *)name
                    period:(ACRankingPeriod)period
                 timestamp:(long)timestamp
                  callback:(void(^)(ACRankingCount *rankingCount, NSError *error))callback;

/**
 * 获取指定排行周期内(比如当天)所有用户的score分值和rank排名等数据
 *
 * @param name      排行榜名称
 * @param period    排行榜周期 (day, week, month)
 * @param timestamp 时间点，如果为0，则表示当前时间所在排行榜(UTC时间戳，相对于1970年的秒数)
 * @param startRank 排名的起始名次 (闭区间,包含startRank)
 * @param endRank   排名的结束名次 (闭区间,包含endRank)
 * @param order     排序方式: ASC(正序), DESC(逆序）
 * @param callback  某一时间点所在排行周期，某个排名范围内的数据
 */
+ (void)scanWithName:(NSString *)name
              period:(ACRankingPeriod)period
           timestamp:(long)timestamp
           startRank:(long)startRank
             endRank:(long)endRank
               order:(ACRankingOrder)order
            callback:(void(^)(NSArray<ACRankingValue *> *list, NSError *error))callback;

/**
 * 获取指定某个排行周期(比如当天)符合分值范围内所有用户的总数
 
 * 如查询当天value在100-200的用户总数
 
     [ACRankingManager rangeCountWithName:@"ranking"
                                   period:ACRankingPeriodDay
                                timestamp:0
                               startScore:100
                                 endScore:200
                                 callback:^(ACRankingCount *count, NSError *error) {
                                     //...
                                 }];

 * @param name       排行榜名称
 * @param period     排行榜周期 (day, week, month)
 * @param timestamp  时间点，如果为0，则表示当前时间所在排行榜(单位秒,UTC时间戳,相对于1970年的秒数)
 * @param startScore 分值起始值 (闭区间,包含startScore)
 * @param endScore   分值结束值 (闭区间,包含endScore)
 * @param callback   所有符合分值范围用户总数
 */
+ (void)rangeCountWithName:(NSString *)name
                    period:(ACRankingPeriod)period
                 timestamp:(long)timestamp
                startScore:(double)startScore
                  endScore:(double)endScore
                  callback:(void(^)(ACRankingCount *count, NSError *error))callback;

@end
