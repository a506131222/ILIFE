//
//  ZJMVolumeSettingVC.h
//  llifeRobot
//
//  Created by 魏青青 on 2019/8/9.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZJMVolumeSettingVC : ZJMBaseVC
@property (nonatomic,strong)NSString *subDomain;
@property (nonatomic,strong)NSString *physicalDeviceId;
@property (nonatomic,assign) NSInteger volume;
@property (nonatomic,assign) BOOL isOpen;
@end

NS_ASSUME_NONNULL_END
