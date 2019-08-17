//
//  WifiLinkLTLink.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkLTLink.h"
#import "ACWifiLinkProtocol.h"
#import "LTLink.h"

@interface WifiLinkLTLink () <ACWifiLinkProtocol> {
    LTLink  *mlink;
}
@end

@implementation WifiLinkLTLink

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    mlink = [[LTLink alloc]init];
    [mlink startLinkWithSSID:ssid password:password secureKey:nil];
}

- (void)stop {
    [mlink stopLink];
}

@end
