//
//  ACCustomTopic.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/7.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopic.h"

@interface ACCustomTopic : ACTopic

/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** 自定义topic类型 注：不可以 “zc-” 开头 */
@property (nonatomic, copy) NSString *type;
/** key */
@property (nonatomic, copy) NSString *key;

/**
 * 初始化自定义类型订阅对象实例
 * @param subDomain 子域
 * @param key 订阅数据key
 * @return 订阅对象实例
 */
- (instancetype)initWithSubDomain:(NSString *)subDomain
                             type:(NSString *)type
                              key:(NSString *)key;

@end
