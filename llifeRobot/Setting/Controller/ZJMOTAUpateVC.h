//
//  ZJMOTAUpateVC.h
//  llifeRobot
//
//  Created by 魏青青 on 2019/2/22.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJMOTAUpateVC : ZJMBaseVC
@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,copy)NSString *physicalDeviceId;
@property (nonatomic,assign)BOOL isUpdate;
@property (nonatomic)NSInteger deviceId;
@end

NS_ASSUME_NONNULL_END
