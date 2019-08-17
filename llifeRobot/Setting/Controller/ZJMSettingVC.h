//
//  ZJMSettingVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/18.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"
@protocol SettingDelegate <NSObject>

-(void)returnData:(NSData *)data;
-(void)returnName:(NSString *)name;

@end
@interface ZJMSettingVC : ZJMBaseVC

@property (nonatomic,strong)NSData *randomData;

@property (nonatomic,weak)id <SettingDelegate>delegate;

@property (atomic,assign)NSInteger deviceID;

@property (nonatomic,copy)NSString *deviceName;

@property (nonatomic,copy)NSString *deviceStatus;

@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,copy)NSString *physicalDeviceId;
@property (nonatomic,assign)BOOL isManager;
@property (nonatomic,strong)NSData *data;
@end
