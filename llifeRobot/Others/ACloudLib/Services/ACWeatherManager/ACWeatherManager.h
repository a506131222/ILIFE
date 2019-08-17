//
//  ACWeatherManager.h
//  AbleCloudLib
//
//  Created by __zimu on 16/4/1.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAQI, ACWeather, ACPM25;
@interface ACWeatherManager : NSObject

#pragma mark - pm25

/**
 * 获取最新的pm25值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param callback    pm25模型
 */
+ (void)getLatestPM25WithArea:(NSString *)area
                     callback:(void(^)(ACPM25 *pm25, NSError *error))callback;

/**
 * 获取最近n天的pm25值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param days        0表示7天
 * @param callback    pm25模型数组
 */
+ (void)getLastDaysPM25WithArea:(NSString *)area
                           days:(NSInteger)days
                       callback:(void(^)(NSArray *pm25List, NSError *error))callback;

/**
 * 获取最近n小时的pm25值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param hours       0表示24小时
 * @param callback    pm25模型数组
 */
+ (void)getLastHoursPM25WithArea:(NSString *)area
                           hours:(NSInteger)hours
                        callback:(void(^)(NSArray *pm25List, NSError *error))callback;

#pragma mark - aqi

/**
 * 获取最新的aqi值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param callback    aqi模型
 */
+ (void)getLatestAqiWithArea:(NSString *)area
                    callback:(void(^)(ACAQI *aqi, NSError *error))callback;

/**
 * 获取最近n天的aqi值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param days        0表示7天
 * @param callback    aqi模型数组
 */
+ (void)getLastDaysAqiWithArea:(NSString *)area
                          days:(NSInteger)days
                      callback:(void(^)(NSArray *aqiList, NSError *error))callback;

/**
 * 获取最近n小时的aqi值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param hours       0表示24小时
 * @param callback    aqi模型数组
 */
+ (void)getLastHoursAqiWithArea:(NSString *)area
                          hours:(NSInteger)hours
                       callback:(void(^)(NSArray *aqiList, NSError *error))callback;

#pragma mark - weather

/**
 * 获取最新的Weather值
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param callback    weather 模型
 */
+ (void)getLatestWeatherWithArea:(NSString *)area
                        callback:(void(^)(ACWeather *weather, NSError *error))callback;

/**
 * 获取最近n天的weather
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param days        0表示7天
 * @param callback    weather 模型数组
 */
+ (void)getLastDaysWeatherWithArea:(NSString *)area
                              days:(NSInteger)days
                          callback:(void(^)(NSArray *weatherList, NSError *error))callback;

/**
 * 获取最近n小时的weather
 * @param area        支持到地级市, area填写中文如: "北京"
 * @param hours       0表示24小时
 * @param callback    weather 模型数组
 */
+ (void)getLastHoursWeatherWithArea:(NSString *)area
                              hours:(NSInteger)hours
                           callback:(void(^)(NSArray *weatherList, NSError *error))callback;

@end
