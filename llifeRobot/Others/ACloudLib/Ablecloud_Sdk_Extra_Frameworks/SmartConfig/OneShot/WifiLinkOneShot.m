//
//  WifiLinkOneShot.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkOneShot.h"
#import "ACWifiLinkProtocol.h"
#import "OneShotConfig.h"

@interface WifiLinkOneShot()<ACWifiLinkProtocol> {
    NSThread *thread;
    NSTimer *timer;
}
@end

@implementation WifiLinkOneShot

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    [timer setFireDate:[NSDate distantFuture]];
    NSMutableDictionary *wifiInfo = [[NSMutableDictionary alloc] init];
    if (ssid) {
        wifiInfo[@"ssid"] = ssid;
    }
    if (password) {
        wifiInfo[@"password"] = password;
    }
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(sendDataWithWifiInfo:) object:wifiInfo];
    [thread start];
}

-(void)sendDataWithWifiInfo:(NSDictionary *)wifiInfo {
    NSString *ssid = wifiInfo[@"ssid"];
    NSString *password = wifiInfo[@"password"];
    @autoreleasepool {
        while (1) {
            if ([NSThread currentThread].isCancelled) {
                [NSThread exit];//只会终止while循环并不会阻断本次调用时的UDP包发送
            }
            else{
                //网络出现故障
                int status = [[OneShotConfig getInstance] startConfig:ssid pwd:password];
                if ( status == -1) {
                    [[OneShotConfig getInstance] stopConfig];//终止当前调用中UDP包的发送
                    [self performSelectorOnMainThread:@selector(fireTimer) withObject:nil waitUntilDone:NO];
                    [thread cancel];
                }
            }
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

-(void)fireTimer {
    [timer setFireDate:[NSDate distantPast]];
}

- (void)stop {
    [timer setFireDate:[NSDate distantPast]];
    [thread cancel];
    [[OneShotConfig getInstance] stopConfig];
}
@end
