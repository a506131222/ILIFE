//
//  WifiLinkXlw.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkXlw.h"
#import "ACWifiLinkProtocol.h"
#import "XlwDevice.h"

@interface WifiLinkXlw()<ACWifiLinkProtocol, XlwDeviceDelegate> {
    XlwDevice *xlwDevice;
    char g_mac[20];
}
@end

@implementation WifiLinkXlw

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    xlwDevice = [[XlwDevice alloc] init];
    xlwDevice.delegate = self;
    char *ssidC = (char *)[ssid UTF8String];
    char *passwordC = (char *)[password UTF8String];
    [xlwDevice SmartConfigStart:ssidC PASSWORD:passwordC TIMEOUT:60000];
}

- (void)stop {
    [xlwDevice SmartConfigStop];
}

#pragma mark - xlw模块代理
-(bool)onSmartFound:(char *)mac MODULE_IP:(char *)ip MODULE_VER:(char *)ver MODULE_CAP:(char *)cap MODULE_EXT:(char*)ext {
    [xlwDevice SmartConfigStop];
    strcpy(g_mac, mac);
    return true;
}

-(bool)onSearchFound:(char*)mac MODULE_IP:(char*)ip MODULE_VER:(char*)ver MODULE_CAP:(char*)cap MODULE_EXT:(char*)ext {
    strcpy(g_mac, mac);
    NSLog(@"find it");
    return true;
}

-(void)onStatusChange:(char *)mac MODULE_STATUS:(int)status { }

-(void)onReceive:(char*)mac RECEIVE_DATA:(char*)data RECEIVE_LEN:(int)len; { }

-(void)onSendError:(char*)mac SEND_SN:(int)sn SEND_ERR:(int)err; { }

@end
