//
//  ZJMAPNetworkVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMAPNetworkVC.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ACWifiInfo.h"
#import "ZJMDeviceNameVC.h"
#import "ACLocalDevice.h"
#import "ZJMNetworkLoadingVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZJMAPConnectVC.h"
@interface ZJMAPNetworkVC ()<UITextFieldDelegate>
@property (copy,nonatomic)ACWifiLinkManager *manager;
@property (strong,nonatomic)NSMutableArray  *wifiList;
@property (copy,nonatomic) NSString *apWifiName;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (copy,nonatomic)NSString *smartWifiName;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;



@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@property (weak, nonatomic) IBOutlet UILabel *settingLab;

@property (nonatomic, strong) NSTimer *wifiTimer;
@property (weak, nonatomic) IBOutlet UILabel *firstStepLab;
@property (weak, nonatomic) IBOutlet UILabel *firstTipsLab;

@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLab;


@property (weak, nonatomic) IBOutlet UILabel *secondStepLab;
@property (weak, nonatomic) IBOutlet UILabel *chooseWifiLab;
@property (weak, nonatomic) IBOutlet UILabel *secondTipsLab;
@property (weak, nonatomic) IBOutlet UILabel *robotNameLab;
@property(nonatomic, strong) NSMutableArray  *unBindDevicesArrM;

@property (nonatomic,copy) ACLocalDevice *localDevice;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;


@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *ssidTF;
@property (weak, nonatomic) IBOutlet UILabel *homewifiLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLabel;

@end

@implementation ZJMAPNetworkVC
{
    int j;
    BOOL bounded;
    ZJMNetworkLoadingVC *networkLoadingVC;
    int _downTime;
    NSInteger type;
    NSInteger count;
    NSInteger model;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
    
}
- (void)applicationWillEnterForeground{
    _ssidTF.text = [self getCurrentWifiName];
}

- (NSMutableArray *)unBindDevicesArrM {
    if (_unBindDevicesArrM == nil) {
        _unBindDevicesArrM = @[].mutableCopy;
    }
    return _unBindDevicesArrM;
}

#pragma mark - 获取WIFI名称
- (NSString *)getCurrentWifiName{
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            _apWifiName = [dict valueForKey:@"SSID"];
        }
    }
    CFRelease(myArray);
    
    return _apWifiName;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AP Networking Mode", nil);
    self.firstStepLab.text=NSLocalizedString(@"Step 1", nil);
    self.firstTipsLab.text=NSLocalizedString(@"Tips: Default Password For Robot-XXXX is 123456789", nil);
    self.robotNameLab.text =NSLocalizedString(@"Setting Choose WLAN Name Started with Robot-XXXX", nil);
    self.secondStepLab.text=NSLocalizedString(@"Step 2", nil);
    self.chooseWifiLab.text=NSLocalizedString(@"Choose WLAN",nil);
    self.secondTipsLab.text=NSLocalizedString(@"Tips: Please Enter Your WLAN Password Before Start to Connect Your Robot", nil);
    self.wifiPasswordLab.text=NSLocalizedString(@"WLAN Password:", nil);
    self.passwordTF.placeholder=NSLocalizedString(@"Enter WLAN Password", nil);
    //     [self.passwordTF becomeFirstResponder];
    [self.settingBtn setTitle:NSLocalizedString(@"Setting",nil) forState:UIControlStateNormal];
    self.settingBtn.titleLabel.font =[UIFont systemFontOfSize:16];
    self.chooseBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [self.chooseBtn setTitle:NSLocalizedString(@"Please Choose", nil) forState:UIControlStateNormal];
    [self.connectBtn setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
    networkLoadingVC = [[ZJMNetworkLoadingVC alloc]init];
    self.ssidTF.text = [ACWifiLinkManager getCurrentSSID];
    self.promptLabel.text = NSLocalizedString(@"The robot temporarily cannot be accessed to the WiFi of 5GHz", nil);
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain]||[self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        self.stepLabel.text = NSLocalizedString(@"Step Three", nil);
    }else{
         self.stepLabel.text = NSLocalizedString(@"Step Four", nil);
    }
    [self.nextBtn setTitle:NSLocalizedString(@"Next Step", nil) forState:UIControlStateNormal];
    
    self.homewifiLabel.text = NSLocalizedString(@"Home WiFi:", nil);
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [IQKeyboardManager sharedManager].enable = YES;
    
}
- (IBAction)next:(UIButton *)sender {
    [self.passwordTF resignFirstResponder];
    if ([self.ssidTF.text hasPrefix:@"Robot"]) {
        [self showHudWithString:NSLocalizedString(@"Please connect home Wi-Fi", nil)];
    }else if (_passwordTF.text.length==0) {
        [self showHudWithString:NSLocalizedString(@"Enter WLAN Password", nil)];
    }else{
        ZJMAPConnectVC *apConnectVc =[[ZJMAPConnectVC alloc]init];
        apConnectVc.ssid = self.ssidTF.text;
        apConnectVc.wifiPassWord= self.passwordTF.text;
        apConnectVc.subDomain = self.subDomain;
        apConnectVc.subID = self.subID;
        apConnectVc.robotName = self.robotName;
        [self.navigationController pushViewController:apConnectVc animated:YES];
    }
   
}

- (IBAction)setting:(UIButton *)sender {
    NSString *str = @"QXBwLVByZWZzOnJvb3Q9V0lGSQ==";
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]]; 

}

#pragma mark - 密文
- (IBAction)passwordTextEntry:(UIButton *)sender {
    _passwordTF.secureTextEntry=!_passwordTF.secureTextEntry;
    sender.selected=!sender.selected;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [self connect];
    return YES;
}
@end

