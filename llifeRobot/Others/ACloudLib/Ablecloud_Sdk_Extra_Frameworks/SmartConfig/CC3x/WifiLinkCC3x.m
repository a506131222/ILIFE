//
//  WifiLinkCC3x.m
//  AbleCloudLib
//
//  Created by fariel huang on 2017/4/5.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "WifiLinkCC3x.h"
#import "ACWifiLinkProtocol.h"
#import "FirstTimeConfig.h"

@interface WifiLinkCC3x()<ACWifiLinkProtocol> {
    FirstTimeConfig *firstConfig;
}
@end

@implementation WifiLinkCC3x

- (void)startWithSSID:(NSString *)ssid password:(NSString *)password {
    firstConfig = [[FirstTimeConfig alloc] initWithKey:password];
    [firstConfig transmitSettings];
    [NSThread detachNewThreadSelector:@selector(waitForAckThread:) toTarget:self withObject:nil];
}

- (void) waitForAckThread: (id)sender{
    @try {
        NSLog(@"%s begin", __PRETTY_FUNCTION__);
        Boolean val = [firstConfig waitForAck];
        if (val) {
            [firstConfig stopTransmitting];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%s exception == %@",__FUNCTION__,[exception description]);
    }
    @finally {
    }
    
    if ( [NSThread isMainThread]  == NO ){
        NSLog(@"this is not main thread");
        [NSThread exit];
    }else {
        NSLog(@"this is main thread");
    }
    NSLog(@"%s end", __PRETTY_FUNCTION__);
}

- (void)stop {
    [firstConfig stopTransmitting];
}

@end
