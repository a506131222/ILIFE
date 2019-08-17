//
//  WifiLinkEasyConfig.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkEasyConfig.h"
#import "ACWifiLinkProtocol.h"
#import "EasyConfig.h"

@interface WifiLinkEasyConfig()<ACWifiLinkProtocol> {
    EasyConfig *easyConfig;
}
@end

@implementation WifiLinkEasyConfig

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    easyConfig = [[EasyConfig alloc] init];
    [easyConfig SendDataWithPsk:password andSSID:ssid];
}

- (void)stop {
    [easyConfig stop_send];
}

@end
