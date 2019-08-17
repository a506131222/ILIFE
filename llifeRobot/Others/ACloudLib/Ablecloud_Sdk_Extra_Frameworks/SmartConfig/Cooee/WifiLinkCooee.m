//
//  WifiLinkCooee.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkCooee.h"
#import "ACWifiLinkProtocol.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Cooee.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface WifiLinkCooee()<ACWifiLinkProtocol>
@end

@implementation WifiLinkCooee

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    const char *PWD = [ssid UTF8String];
    const char *SSID = [password UTF8String];
    const char *KEY = [@"" UTF8String];
    struct in_addr addr;
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    inet_aton([address UTF8String], &addr);
    unsigned int ip = CFSwapInt32BigToHost(ntohl(addr.s_addr));
    
    send_cooee(SSID, (int)strlen(SSID), PWD, (int)strlen(PWD), KEY, 0, ip);
}

- (void)stop {
}

@end
