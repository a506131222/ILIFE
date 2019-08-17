//
//  WifiLinkSimpleConfig.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkSimpleConfig.h"
#import "ACWifiLinkProtocol.h"
#import "SimpleConfig.h"

@interface WifiLinkSimpleConfig()<ACWifiLinkProtocol> {
    SimpleConfig *simpleConfig;
}
@end

@implementation WifiLinkSimpleConfig

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    NSString *pattern_name = @"sc_mcast_udp";
    simpleConfig = [[SimpleConfig alloc] initWithPattern:PATTERN_TWO
                                                    flag:(PATTERN_USING_UDP_SOCKET | PATTERN_VALID )
                                                    name:pattern_name];
    
    [simpleConfig.pattern set_index:2];
    [simpleConfig rtk_sc_set_ssid:ssid];
    [simpleConfig rtk_sc_set_password:password];
    [simpleConfig rtk_sc_gen_random];
    [simpleConfig rtk_sc_build_profile];
    
    [NSThread detachNewThreadSelector:@selector(rtk_sc_start) toTarget:simpleConfig withObject:nil];
}

- (void)stop {
    [simpleConfig rtk_sc_stop];
    [simpleConfig rtk_sc_exit];
}

@end
