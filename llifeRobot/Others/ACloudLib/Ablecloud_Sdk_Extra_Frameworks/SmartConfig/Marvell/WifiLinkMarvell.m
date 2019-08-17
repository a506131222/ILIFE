//
//  WifiLinkMarvell.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkMarvell.h"
#import "ACWifiLinkProtocol.h"
#import "MarvellSmartConfig.h"

@interface WifiLinkMarvell()<ACWifiLinkProtocol> {
    MarvellSmartConfig *marvell;
}
@end

@implementation WifiLinkMarvell

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    marvell = [[MarvellSmartConfig alloc] init];
    [marvell marvell:ssid password:password];
}

- (void)stop {
    [marvell stopSmartConfig];
}

@end
