//
//  ZJMBaseVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ACAccountManager.h"
#import "ACBindManager.h"
#import "ACLocalDevice.h"
#import "PreHeader.h"
#import "AppDelegate.h"
#import "ACDeviceMsg.h"
#import "DeviceMsg.h"
#import "MJRefresh.h"
#import "ACDeviceDataManager.h"
#import "NetworkTool.h"
#import "ACUserDevice.h"
#import "ACProductManager.h"
#import "ACProduct.h"
#import "ACWifiLinkManager.h"
#import "ACUserDevice.h"
#import "UIImageView+Corner.h"
#import "ACFeedBackManager.h"
#import "IQKeyboardManager.h"
#import "ACNotificationManager.h"
#import "UMessage.h"
#import "ACUserInfo.h"
#import "ACWifiLinkManager.h"
#import "ACAccountManager.h"
#import "ACMsg.h"
#import "ACObject.h"
#import "UIImage+GIF.h"
#import "CustomButton.h"
#import "ACClassDataManager.h"
#import "constServiceName.h"

@interface ZJMBaseVC : UIViewController


@property (nonatomic,strong) UIBarButtonItem *commonbackItem;

@property (nonatomic,strong)UIBarButtonItem *commonaddItem;
@property (nonatomic,strong)NSString * errorType;

- (void)showHudWithString:(NSString *)string;

-(void)showHudWithRound;
- (void)showHud;

- (void)hideHud;


-(NSData *)hexToBytesWith:(NSString *)str;


- (BOOL)isValidateEmail:(NSString *)email;
-(NSString *)returnNetworkState;

@end
