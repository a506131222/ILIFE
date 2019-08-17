//
//  WifiLinkHFV8.m
//  ACInternalTest
//
//  Created by Ennnnnn7 on 2018/12/18.
//  Copyright © 2018 CJS__. All rights reserved.
//

#import "WifiLinkHFV8.h"
#import "ACWifiLinkProtocol.h"
#import "HFSmartLinkV8.h"
#import "HFSmartLinkDeviceInfoV8.h"

@interface WifiLinkHFV8 ()<ACWifiLinkProtocol> {
	HFSmartLinkV8 *smartLink;
	BOOL isConnecting;
}
@end

@implementation WifiLinkHFV8


- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
	smartLink = [HFSmartLinkV8 shareInstence];
	if(!isConnecting){
		isConnecting = YES;
		[smartLink startWithSSID:ssid Key:password UserStr:@"" withV3x:NO
				processblock: ^(NSInteger pro) {
				} successBlock:^(HFSmartLinkDeviceInfoV8 *dev) {
					NSLog(@"successBlock:%@",dev);
				} failBlock:^(NSString *failmsg) {
					NSLog(@"failBlock:%@",failmsg);
				} endBlock:^(NSDictionary *deviceDic) {
					isConnecting = NO;
				}];
	}else{
		[smartLink stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
			if(isOk){
				isConnecting = NO;
				NSLog(@"stopSmtlk:%@",isOk?@"YES":@"NO");
			}else{
				NSLog(@"stopSmtlk:%@",isOk?@"YES":@"NO");
			}
		}];
	}
}

- (void)stop {
		[smartLink stopWithBlock:^(NSString *stopMsg, BOOL isOk) { NSLog(@"Timeout－－stopLinkStop:%@",isOk?@"YES":@"NO"); }];
		[smartLink closeWithBlock:^(NSString *closeMsg, BOOL isOK) { NSLog(@"Timeout－－smartLinkClose:%@",isOK?@"YES":@"NO"); }];
}


@end

