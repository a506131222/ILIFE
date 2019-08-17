//
//  ZJMDeviceMsg.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/19.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACUserDevice;

@interface DeviceMsg : NSObject

@property (nonatomic,strong)ACUserDevice *userDevice;
@end
