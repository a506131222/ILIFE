//
//  ACLocalRequestQueue.h
//  ACInternalTest
//
//  Created by CJS__ on 2018/2/6.
//  Copyright © 2018年 CJS__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACLocalRequest;

@interface ACLocalRequestQueue : NSObject

+ (instancetype)localDeviceMsgQueue;

- (NSInteger)getMsgId;

- (void)addRequest:(ACLocalRequest *)request;

- (void)removeRequest:(ACLocalRequest *)request;

- (ACLocalRequest *)getRequestById:(NSInteger)msgId;

@end
