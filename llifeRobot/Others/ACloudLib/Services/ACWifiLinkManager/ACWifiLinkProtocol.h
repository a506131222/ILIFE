//
//  ACWifiLinker.h
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACWifiLinkProtocol <NSObject>

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password;
- (void)stop;

@end
