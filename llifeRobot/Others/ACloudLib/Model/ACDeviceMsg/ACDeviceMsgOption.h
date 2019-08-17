//
//  ACDeviceMsgOption.h
//  NetworkingDemo
//
//  Created by zhourx5211 on 12/27/14.
//  Copyright (c) 2014 zhourx5211. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACDeviceMsgOption : NSObject

@property (nonatomic, assign) NSInteger optCode;
@property (nonatomic, assign) NSInteger optLen;
@property (nonatomic, strong) NSData *payload;

- (NSData *)marshal;
+ (instancetype)unmarshalWithHead:(NSData *)headData;

@end
