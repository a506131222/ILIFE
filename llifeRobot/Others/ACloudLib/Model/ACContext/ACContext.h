//
//  ACContext.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/11/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ACContext : NSObject

/** 操作系统 */
@property (nonatomic, copy) NSString *os;
/** 系统版本 */
@property (nonatomic, copy) NSString *version;
/** SDK的版本信息 */
@property (nonatomic, copy) NSString *sdkVersion;
/** 服务所属主域名 */
@property (nonatomic, copy) NSString *majorDomain;
/** 服务器所属主域ID */
@property (nonatomic, unsafe_unretained) NSInteger majorDomainId;
/** 服务所属子域名 */
@property (nonatomic, copy) NSString *subDomain;
/** 用户id */
@property (nonatomic, strong) NSNumber *userId;
/** 起始时间 */
@property (nonatomic, copy) NSString *traceStartTime;
/** 用于签名的随机字符串 */
@property (nonatomic, copy) NSString *nonce;
/** 为防止签名被截获，设置签名的有效超时时间 */
@property (nonatomic, copy) NSString *timeout;
/** 请求发起的时间戳，单位秒 */
@property (nonatomic, copy) NSString *timestamp;
/** 请求的签名 */
@property (nonatomic, copy) NSString *signature;
/** 请求的模式 为1 则为匿名访问 */
@property (nonatomic, copy) NSString *accessMode;

/**
 * 生成context主要用于包含重要的上下文信息
 * @param subDomain   服务所属子域名
 */
+ (ACContext *)generateContextWithSubDomain:(NSString *)subDomain;

/**
 * 生成context主要用于包含重要的上下文信息
 * @param subDomain   服务所属子域名
 * @param sign        是否需要签名
 */
+ (ACContext *)generateContextWithSubDomain:(NSString *)subDomain sign:(BOOL)sign;

@end
