//
//  WifiLinkGuBei.m
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2017/4/8.
//  Copyright © 2017年 OK. All rights reserved.
//

#import "WifiLinkGuBei.h"
#import "ACWifiLinkProtocol.h"
#import "BLEasyConfig.h"

@interface WifiLinkGuBei()<ACWifiLinkProtocol> {
    BLEasyConfig *bleEasyConfig;
}
@end

@implementation WifiLinkGuBei

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    bleEasyConfig = [[BLEasyConfig alloc] init];
    [bleEasyConfig start:ssid key:password timeout:6000];
}

- (void)stop {
    [bleEasyConfig stop];
}

@end
