//
//  ZJMLIneCodeVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/8/29.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@interface ZJMLineCodeVC : ZJMBaseVC
@property (nonatomic,copy)NSString *ssid;
@property (nonatomic,copy)NSString *wifiPassWord;
@property (weak, nonatomic) IBOutlet UITextField *lineCodeTF;
@end
