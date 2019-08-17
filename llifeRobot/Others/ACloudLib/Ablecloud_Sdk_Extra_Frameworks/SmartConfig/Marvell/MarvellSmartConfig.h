//
//  MarvellSmartConfig.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/6.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarvellSmartConfig : NSObject
- (void)marvell:(NSString *)ssid password:(NSString *)password;
- (void)stopSmartConfig;
@end
