//
//  WifiLinkSmartConnection.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkSmartConnection.h"
#import "ACWifiLinkProtocol.h"
#import "SmartConnection.h"

@interface WifiLinkSmartConnection()<ACWifiLinkProtocol>
@end

@implementation WifiLinkSmartConnection

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    const char *ssidCString = [ssid cStringUsingEncoding:NSASCIIStringEncoding];
    const char *passwordCString = [password cStringUsingEncoding:NSASCIIStringEncoding];
    InitSmartConnection();
    StartSmartConnection(ssidCString, passwordCString, "", 0x07);
}

- (void)stop {
    StopSmartConnection();
}

@end
