//
//  ACUserCommand.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/16.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACMsg;
@interface ACUserCommand : NSObject
/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** uds的serviceName */
@property (nonatomic, copy) NSString *service;
/** uds的methodName */
@property (nonatomic, copy) NSString *method;
/** 发送参数 */
@property (nonatomic, strong) ACMsg *params;

- (instancetype)init NS_UNAVAILABLE;
/**
 * 生成一条发送给UDS的定时任务指令
 * @param subDomain 产品子域
 * @param service   uds的serviceName
 * @param method    uds的methodName
 * @param params    发送参数
 * @return 任务指令实例
 */
- (instancetype)initWithSubDomain:(NSString *)subDomain
                          service:(NSString *)service
                           method:(NSString *)method
                           params:(ACMsg *)params;

+ (instancetype)userCommandWithDict:(NSDictionary *)dict;

- (NSDictionary *)marshal;
@end
