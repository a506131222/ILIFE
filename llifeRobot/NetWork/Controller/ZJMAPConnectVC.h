//
//  ZJMAPConnectVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/8/29.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@interface ZJMAPConnectVC : ZJMBaseVC
@property (nonatomic,copy)NSString *ssid;
@property (nonatomic,copy)NSString *wifiPassWord;

@property (nonatomic,copy)NSString *lineCode;
@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,copy)NSString *subID;
@property (nonatomic,strong)NSString *robotName;
@end
