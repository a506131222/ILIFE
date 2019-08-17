//
//  ZJMRechargeVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/7.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@interface ZJMX786RechargeVC : ZJMBaseVC

@property (nonatomic,copy)NSString *physicalDeviceId;

@property (atomic,assign)NSInteger deviceID;

@property (nonatomic,copy)NSString *deviceName;

@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,assign)BOOL isManager;
@end
