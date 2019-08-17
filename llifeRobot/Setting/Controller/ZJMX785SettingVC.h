//
//  ZJMX785SettingVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/4/12.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@protocol X785SettingDelegate <NSObject>

-(void)returnData:(NSData *)data;
-(void)returnName:(NSString *)name;

@end

@interface ZJMX785SettingVC : ZJMBaseVC

@property (nonatomic,strong)NSData *data;

@property (nonatomic,weak)id <X785SettingDelegate>delegate;

@property (atomic,assign)NSInteger deviceID;

@property (nonatomic,copy)NSString *deviceName;

@property (nonatomic,copy)NSString *deviceStatus;

@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,copy)NSString *physicalDeviceId;
@property (nonatomic,assign)BOOL isManager;
@end
