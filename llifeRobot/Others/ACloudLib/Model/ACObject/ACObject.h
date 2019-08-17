//
//  ACObject.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/10/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACObject : NSObject

/**
 * 获取一个参数值
 * @param name	参数名
 * @return		参数值
 */
- (id)get:(NSString *)name;
- (NSArray *)getArray:(NSString *)name;
- (BOOL)getBool:(NSString *)name;
- (long)getLong:(NSString *)name;
- (long long)getLongLong:(NSString *)name;
- (NSInteger)getInteger:(NSString *)name;
- (float)getFloat:(NSString *)name;
- (double)getDouble:(NSString *)name;
- (NSString *)getString:(NSString *)name;
- (ACObject *)getACObject:(NSString *)name;

/**
 * 设置一个参数
 * @param name	参数名
 * @param value	参数值
 */
- (void)put:(NSString *)name value:(id)value;
- (void)putArray:(NSString *)name value:(id)value;
- (void)putBool:(NSString *)name value:(BOOL)value;
- (void)putLong:(NSString *)name value:(long)value;
- (void)putLongLong:(NSString *)name value:(long long)value;
- (void)putInteger:(NSString *)name value:(NSInteger)value;
- (void)putFloat:(NSString *)name value:(float)value;
- (void)putDouble:(NSString *)name value:(double)value;
- (void)putString:(NSString *)name value:(NSString *)value;
- (void)putACObject:(NSString *)name value:(ACObject *)value;

/**
 * 添加一个参数，该参数添加到一个List中
 * @param name	参数所在List的名字
 * @param value	参数值
 */
- (void)add:(NSString *)name value:(id)value;
- (void)addBool:(NSString *)name value:(BOOL)value;
- (void)addLong:(NSString *)name value:(long)value;
- (void)addLongLong:(NSString *)name value:(long long)value;
- (void)addInteger:(NSString *)name value:(NSInteger)value;
- (void)addFloat:(NSString *)name value:(float)value;
- (void)addDouble:(NSString *)name value:(double)value;
- (void)addString:(NSString *)name value:(NSString *)value;
- (void)addACObject:(NSString *)name value:(ACObject *)value;
/**
 * 删除一个参数，该参数从List中移除
 */
- (void)removeString:(NSString *)key;


- (BOOL)contains:(NSString *)name;
- (NSArray *)getKeys;

- (BOOL)hasObjectData;
- (NSDictionary *)getObjectData;
- (void)setObjectData:(NSDictionary *)data;

- (NSData *)marshal;

+ (NSData *)marshal:(ACObject *)object;
+ (instancetype)unmarshal:(NSData *)data;

@end
