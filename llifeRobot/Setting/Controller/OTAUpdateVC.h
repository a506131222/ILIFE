//
//  ZJMOTAUpdateVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2019/2/25.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTAUpdateVC : ZJMBaseVC


@property (nonatomic,copy)NSString *subDomain;

@property (nonatomic,copy)NSString *lastVersion;

@property (nonatomic)NSInteger deviceId;
@property (nonatomic)NSString *physicalDeviceId;

@end

NS_ASSUME_NONNULL_END
