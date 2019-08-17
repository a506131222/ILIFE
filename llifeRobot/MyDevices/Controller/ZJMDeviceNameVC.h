//
//  ZJMDeviceNameVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/1.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"


typedef void(^BackDeviceName)(NSString *deviceName);

@interface ZJMDeviceNameVC : ZJMBaseVC

@property (nonatomic,copy)NSString *physicalDeviceId;

@property (nonatomic,copy)BackDeviceName backDeviceName;

@property (assign,atomic)NSInteger backType;


@end
