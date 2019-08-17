//
//  ACLocalRequest.h
//  ACInternalTest
//
//  Created by CJS__ on 2018/2/6.
//  Copyright © 2018年 CJS__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACDeviceMsg;

typedef void(^ACLocalRequestBlock)(ACDeviceMsg *responseMsg, NSError *error);

@interface ACLocalRequest : NSObject

@property (nonatomic, strong) ACLocalRequestBlock requestBlock;

@property (nonatomic, assign) NSUInteger msgId;

@property (nonatomic, strong) NSDate *timeoutDate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMsgId:(NSInteger)msgId
              requestCallback:(ACLocalRequestBlock)callback
                  timeoutDate:(NSDate *)timeoutDate;

@end
