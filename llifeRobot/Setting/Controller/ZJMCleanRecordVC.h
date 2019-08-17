//
//  ZJMCleanRecordVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@interface ZJMCleanRecordVC : ZJMBaseVC

@property (assign,atomic)NSInteger deviceID;

@property (nonatomic,copy)NSString *subDomain;

@property (nonatomic,copy)NSString *physicalDeviceId;

@end

