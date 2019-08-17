//
//  ACDeviceMsgSecHead.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/27/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ACDeviceMsgSecTypeNone = 0,
    ACDeviceMsgSecTypeRSA,
    ACDeviceMsgSecTypeAES,
} ACDeviceMsgSecType;

@interface ACDeviceMsgSecHead : NSObject

@property (nonatomic, assign) NSInteger totalMsg;
@property (nonatomic, assign) ACDeviceMsgSecType secType;
@property (nonatomic, strong) NSData *resver;

- (NSData *)marshal;
+ (instancetype)unmarshal:(NSData *)data;

@end
