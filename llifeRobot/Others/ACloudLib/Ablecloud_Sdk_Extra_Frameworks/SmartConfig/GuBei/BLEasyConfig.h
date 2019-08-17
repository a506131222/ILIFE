//
//  BLEasyConfig.h
//  BLEasyConfig
//
//  Created by yzm157 on 15/12/11.
//  Copyright © 2015年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEasyConfig : NSObject

- (void)start:(NSString *)ssid key:(NSString *)key timeout:(int)timeout;

- (void)stop;

- (BOOL)isRunning;

- (NSString *)version;

@end
