//
//  WifiLinkHF.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkHF.h"
#import "ACWifiLinkProtocol.h"
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"

@interface WifiLinkHF()<ACWifiLinkProtocol> {
    HFSmartLink *smtlk;
    BOOL isconnecting;
}
@end

@implementation WifiLinkHF

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    smtlk = [HFSmartLink shareInstence];
    if(!isconnecting){
        [smtlk startWithSSID:ssid Key:password withV3x:true processblock:^(NSInteger process) {
        } successBlock:^(HFSmartLinkDeviceInfo *dev) {
            NSLog(@"successBlock:%@",dev);;
        } failBlock:^(NSString *failmsg) {
            NSLog(@"failBlock:%@",failmsg);
        } endBlock:^(NSDictionary *deviceDic) {
            isconnecting  = NO;
        }];
        isconnecting = YES;
    } else {
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            if(isOk){
                NSLog(@"stopSmtlk:%@",isOk?@"YES":@"NO");
            }else{
                NSLog(@"stopSmtlk:%@",isOk?@"YES":@"NO");
            }
        }];
    }
}

- (void)stop {
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) { NSLog(@"Timeout－－stopLinkStop:%@",isOk?@"YES":@"NO"); }];
    [smtlk closeWithBlock:^(NSString *closeMsg, BOOL isOK) { NSLog(@"Timeout－－smartLinkClose:%@",isOK?@"YES":@"NO"); }];
}

@end
