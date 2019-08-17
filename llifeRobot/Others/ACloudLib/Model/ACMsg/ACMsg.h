//
//  ACMsg.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/10/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import "ACObject.h"
#import "ACContext.h"

@interface ACMsg : ACObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) ACContext *context;
@property (nonatomic, strong) NSString *payloadFormat;
@property (nonatomic, assign) NSUInteger payloadSize;
@property (nonatomic, strong) NSData *payload;
@property (nonatomic, strong, readonly) NSData *streamPayload;

/**
 * 生成带签名信息的ACMsg实例
 */
+ (instancetype)msgWithName:(NSString *)name;
+ (instancetype)msgWithName:(NSString *)name
                  subDomain:(NSString *)subDomain;

/**
 * 设置二进制负载
 * 通过put/add方式设置的负载要么框架将其序列化为json，
 * 要么解析后作为url的参数传输。
 * 通过该函数可以设置额外的负载数据。
 * @param payload   负载内容
 * @param format    负载格式
 */
- (void)setPayload:(NSData *)payload format:(NSString *)format;

/**
 * 设置流式负载，主要用于较大的数据传输，如上传文件等。
 * @param streamPayload   负载内容
 * @param size      负载大小
 */
- (void)setStreamPayload:(NSData *)streamPayload size:(NSInteger)size;

- (BOOL)isErr;
- (NSInteger)getErrCode;
- (NSString *)getErrMsg;
- (NSString *)getErrDesc;

extern NSString *const ACMsgObjectPayload;
extern NSString *const ACMsgJsonPayload;
extern NSString *const ACMsgStreamPayload;
extern NSString *const ACMsgMsgNameHeader;
extern NSString *const ACMsgAckMSG;
extern NSString *const ACMsgErrMSG;

@end
