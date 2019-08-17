//
//  WifiLinkEspTouch.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkEspTouch.h"
#import "ACWifiLinkProtocol.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ESPTouchResult.h"
#import "ESPTouchTask.h"

@interface WifiLinkEspTouch()<ACWifiLinkProtocol> {
    ESPTouchTask *esptouchTask;
}
@end

@implementation WifiLinkEspTouch

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    
    NSString *apBssid = @"";
    if (SSIDInfo && SSIDInfo[@"BSSID"]) {
        apBssid = SSIDInfo[@"BSSID"];
    }
    
    ESPTouchTask *esptouchtask = [[ESPTouchTask alloc] initWithApSsid:ssid andApBssid:apBssid andApPwd:password andIsSsidHiden:NO];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [esptouchtask executeForResult];
    });
}

- (void)stop {
    [esptouchTask interrupt];
}

@end
