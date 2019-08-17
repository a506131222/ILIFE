//
//  ACDeviceMsgHead.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/27/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACDeviceMsgHead : NSObject

@property (nonatomic, assign) NSInteger msgVersion;
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, assign) NSInteger msgCode;
@property (nonatomic, assign) NSInteger optNum;
@property (nonatomic, assign) NSInteger payloadLen;
@property (nonatomic, strong) NSData *totalMsgCrc;

- (NSData *)marshal;
+ (instancetype)unmarshal:(NSData *)data;

@end
