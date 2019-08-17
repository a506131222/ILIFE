//
//  AppDelegate.h
//  llifeRobot
//
//  Created by Yannis on 16/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceMsg.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 逻辑ID*/
@property (strong,nonatomic) NSString *physicalDeviceId;

/** 物理ID*/
@property (assign) NSInteger deviceId;

/** 设备名称*/
@property (strong,nonatomic)NSString *deviceName;

/**用户ID*/
@property (assign,atomic)NSInteger userId;

/** 管理员ID*/
@property (assign,atomic)NSInteger *ownerId;

@property (strong,nonatomic)NSMutableArray *deviceNameList;


@property (assign,atomic)NSInteger reserCount;
@property (strong,nonatomic)NSMutableArray *deviceList;

@property (strong,nonatomic)NSMutableArray<ACUserDevice *> *ownerDeviceList;
@end

