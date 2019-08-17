//
//  ACFindDevicesManager.h
//  AbleCloud
//
//  Created by zhourx5211 on 1/9/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACLocalDevice.h"

@class ACDeviceMsg;

@protocol ACFindDevicesDelegate <NSObject>

@optional

- (void)ac_findDeviceMgrDidFindTimeoutDevices:(NSArray<ACLocalDevice *> *)devices;
- (void)ac_findDeviceMgrDidFindDevices:(NSArray<ACLocalDevice *> *)devices;

@end

@interface ACFindDevicesManager : NSObject

@property (nonatomic, weak) id<ACFindDevicesDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *devices;

- (void)findDevicesWithSubDomainId:(NSInteger)subDomainId
                      findInterval:(NSTimeInterval)findInterval
                           timeout:(NSTimeInterval)timeout;
- (void)stop;
+ (void)setLocalPushDataHandler:(void(^)(ACLocalDevice *device, ACDeviceMsg *msg))handler;
+ (void)setLocalOnlineStatusHandler:(void(^)(ACLocalDevice *device, BOOL online))handler;

@end
