//
//  WifiLinkEasyLink.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkEasyLink.h"
#import "ACWifiLinkProtocol.h"
#import "EASYLINK.h"

@interface WifiLinkEasyLink()<ACWifiLinkProtocol> {
    EASYLINK *easylink_config;
}
@end

@implementation WifiLinkEasyLink

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    
    NSLog(@"EASYLINK version ---- %@",[EASYLINK version]);
    
    easylink_config = [[EASYLINK alloc]init];
    
    NSMutableDictionary *wlanConfig = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSData *ssidData = [EASYLINK ssidDataForConnectedNetwork];
    
    [wlanConfig setObject:ssidData forKey:KEY_SSID];
    [wlanConfig setObject:password forKey:KEY_PASSWORD];
    [wlanConfig setObject:[NSNumber numberWithBool:YES] forKey:KEY_DHCP];
    
    [easylink_config prepareEasyLink_withFTC:wlanConfig info:nil mode:EASYLINK_V2_PLUS];
    [easylink_config transmitSettings];
}

- (void)stop {
    [easylink_config stopTransmitting];
}

@end
