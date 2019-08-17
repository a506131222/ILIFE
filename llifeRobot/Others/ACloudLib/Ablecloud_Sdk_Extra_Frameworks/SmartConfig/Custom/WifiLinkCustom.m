//
//  WifiLinkCustom.m
//  ac-service-ios-Demo
//
//  Created by fariel on 2017/7/27.
//  Copyright © 2017年 OK. All rights reserved.
//

#import "WifiLinkCustom.h"
#import "ACWifiLinkProtocol.h"

@interface WifiLinkCustom () <ACWifiLinkProtocol>
@end

@implementation WifiLinkCustom

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
}

- (void)stop {
}

@end
