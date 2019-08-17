//
//  ZJMUpgrading.h
//  llifeRobot
//
//  Created by 张佳满 on 2019/3/29.
//  Copyright © 2019年 ZJM. All rights reserved.
//
#import "ZJMBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJMUpgradingVC : ZJMBaseVC


@property (nonatomic,copy)NSString *sudDomain;
@property (nonatomic)NSInteger type;
@property (nonatomic)NSInteger deviceId;
@property (nonatomic,copy)NSString *lastVersion;
@property (nonatomic,copy)NSString *physicalDeviceId;
@end

NS_ASSUME_NONNULL_END
