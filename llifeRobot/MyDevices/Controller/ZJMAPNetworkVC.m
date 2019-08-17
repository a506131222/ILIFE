//
//  ZJMAPNetworkVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMAPNetworkVC.h"
#import "ZJMWifiTableViewCell.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ZJMWifiListVC.h"
#import "ACWifiInfo.h"
#import "ZJMDeviceNameVC.h"
#import "ACLocalDevice.h"
#import "ZJMNetworkLoadingVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ZJMAPNetworkVC ()<UITextFieldDelegate>
@property (copy,nonatomic)ACWifiLinkManager *manager;
@property (strong,nonatomic)NSMutableArray  *wifiList;
@property (copy,nonatomic) NSString *apWifiName;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (copy,nonatomic)NSString *smartWifiName;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (nonatomic,strong)NSString *robotName;

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
@end

@implementation ZJMAPNetworkVC
{
    int j;
    BOOL bounded;
    ZJMNetworkLoadingVC *networkLoadingVC;
    int _downTime;
    NSInteger type;
    NSInteger count;
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
    
}
- (void)applicationWillEnterForeground{
    
    [self getCurrentWifiName];
    [_settingBtn setTitle:_apWifiName forState:UIControlStateNormal];
    
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
    self.title = NSLocalizedString(@"AP Distribution Mode", nil);
    self.firstStepLab.text=NSLocalizedString(@"First Step", nil);
    self.firstTipsLab.text=NSLocalizedString(@"Tip: the password for 'Robot-XXXX' is 123456789", nil);
    self.robotNameLab.text =NSLocalizedString(@"Please jump to the WiFi-Setting name at the beginning of the connection Robot", nil);
    self.secondStepLab.text=NSLocalizedString(@"Second Step", nil);
    self.chooseWifiLab.text=NSLocalizedString(@"Please Select the Wi-Fi",nil);
    self.secondTipsLab.text=NSLocalizedString(@"Tips:Click to enter the Wi-Fi password of your choice before starting to connect", nil);
    self.wifiPasswordLab.text=NSLocalizedString(@"Wi-Fi password:", nil);
    self.passwordTF.placeholder=NSLocalizedString(@"Input Wi-Fi Password", nil);
    [self.settingBtn setTitle:NSLocalizedString(@"Setting",nil) forState:UIControlStateNormal];
    self.settingBtn.titleLabel.font =[UIFont systemFontOfSize:17];
    self.chooseBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [self.chooseBtn setTitle:NSLocalizedString(@"Select", nil) forState:UIControlStateNormal];
    [self.connectBtn setTitle:NSLocalizedString(@"Begin to Connect", nil) forState:UIControlStateNormal];
    networkLoadingVC = [[ZJMNetworkLoadingVC alloc]init];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (IBAction)setting:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (IBAction)chooseWifi:(UIButton *)sender {
    
    if (![_apWifiName hasPrefix:@"Robot"]) {
        
        [self showHudWithString:NSLocalizedString(@"Please select the WiFi name at the beginning of Robot", nil)];
    }else{
        _manager = [[ACWifiLinkManager alloc] initWithLinkerName:ACLinkerNameAPMode];
        [_manager customApAddress:@"192.168.1.10"];
        _wifiList = [NSMutableArray array];
        [self showHudWithRound];
        [_manager searchAvailableWifiTimeout:30 callback:^(NSArray<ACWifiInfo *> *wifiInfo, NSError *error) {
            if (!error) {
                [self hideHud];
                for (ACWifiInfo *wifiSSID in wifiInfo) {
                    [_wifiList addObject:wifiSSID.ssid];
                    ZJMWifiListVC *wifiListVC = [[ZJMWifiListVC alloc]init];
                    wifiListVC.wifiList = _wifiList;
                    wifiListVC.backWifiName = ^(NSString *wifiName) {
                        _smartWifiName=wifiName;
                        [_chooseBtn setTitle:_smartWifiName forState:UIControlStateNormal];
                    };
                    wifiListVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    [self presentViewController:wifiListVC animated:YES completion:nil];
                }
            }else{
                [self hideHud];
                [self showHudWithString:NSLocalizedString(@"Failed to Connect to the hot spot of the device, Please try again", nil)];
            }
        }];
    }
}

#pragma mark - 停止配网
-(void)stopConnect:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"是否取消配网?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        bounded=YES;
        [_wifiTimer invalidate];
        _wifiTimer=nil;
        [_manager stopWifiLink];
        [networkLoadingVC.networkIndicatorView stopAnimating];
        [networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
        [_connectBtn setTitle:NSLocalizedString(@"Begin to Connect", nil) forState:UIControlStateNormal];
        _connectBtn.enabled = YES;
        [_passwordTF setEnabled:YES];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [networkLoadingVC presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark- 开始连接
- (IBAction)connect{
    [self.view endEditing:YES];
    if (![_apWifiName hasPrefix:@"Robot"]) {
        
        [self showHudWithString:NSLocalizedString(@"Please select the WiFi name at the beginning of Robot", nil)];
    }
    else if ([_passwordTF.text isEqualToString:@""]) {
        
        [self showHudWithString:NSLocalizedString(@"Input Wi-Fi Password", nil)];
    }else{
        networkLoadingVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:networkLoadingVC animated:YES completion:nil];
        [networkLoadingVC.networkIndicatorView startAnimating];
        [networkLoadingVC.stopConnectBtn addTarget:self action:@selector(stopConnect:) forControlEvents:UIControlEventTouchUpInside];
        networkLoadingVC.netWorkLab.text = NSLocalizedString(@"Activating Device,Please wait...", nil);
        [_connectBtn setTitle:NSLocalizedString(@"Activating Device,Please wait...", nil) forState:UIControlStateNormal];
        [_passwordTF setEnabled:NO];
        _connectBtn.enabled = NO;
        j=0;
        _connectBtn.enabled = YES;
        [self.manager APSendWifiInfo:_smartWifiName password:_passwordTF.text timeout:30 callback:^(BOOL response, NSArray *localDevices, NSError *error) {
            if (error) {
                _wifiTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(smartConnect) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop]addTimer:_wifiTimer forMode:NSDefaultRunLoopMode];
                [self searchAllDevices];
            }else{
                NSLog(@"%@",localDevices);
                _localDevice = [localDevices lastObject];
                [self bindDeviceWithSubDomain:_subDomain physicalDeviceId:_localDevice.deviceId];
            }
        }
         ];
    }
}

-(void)dealloc {
    [_wifiTimer invalidate];
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}
#pragma mark - 搜索设备
-(void)searchAllDevices{
    NSTimeInterval time_out_cnt = 10;
    
    if (count >= 4)
    {
        time_out_cnt = 15;
    }
    
    [_manager sendWifiInfo:_apWifiName password:_passwordTF.text timeout:time_out_cnt callback:^(NSArray *localDevices, NSError *error) {
        if (error)
        {
            
        }
        else
        {
            
            NSLog(@"%@",localDevices);
            _localDevice = [localDevices lastObject];
            [self bindDeviceWithSubDomain:_subDomain physicalDeviceId:_localDevice.deviceId];
        }
        
    }];
}
#pragma mark - 绑定设备
-(void)bindDeviceWithSubDomain:(NSString *)subDomain physicalDeviceId:(NSString *)physicalDeviceId{
    //是否被绑定
    self.unBindDevicesArrM = [NSMutableArray array];
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    [ACBindManager isDeviceBoundsWithSubDomain:subDomain physicalDeviceId:physicalDeviceId callback:^(BOOL isBounded, NSError *error) {
        NSLog(@"%@",_localDevice.deviceId);
        
        if (!error) {
            if (isBounded == NO) {
                if (![self.unBindDevicesArrM containsObject:_localDevice.deviceId]) {
                    [self.unBindDevicesArrM addObject:_localDevice.deviceId];
                }
                NSLog(@"未绑定的id---%@",self.unBindDevicesArrM);
                // 绑定设备
                
                [_unBindDevicesArrM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [ACBindManager bindDeviceWithSubDomain:_subDomain physicalDeviceId:_unBindDevicesArrM[idx] name:nil callback:^(ACUserDevice *userDevice, NSError *error) {
                        
                        if(!error){
                            count=0;
                            [_wifiTimer invalidate];
                            _wifiTimer=nil;
                            _connectBtn.enabled = YES;
                            delegate.deviceId = [[userDevice valueForKey:@"deviceId"]integerValue];
                            
                            [_manager stopWifiLink];
                            networkLoadingVC.netWorkLab.text = NSLocalizedString(@"Device Binding Success", nil);
                            [networkLoadingVC.networkIndicatorView stopAnimating];
                            
                            NSLog(@"id------%@",delegate.physicalDeviceId);
                            [_connectBtn setTitle:NSLocalizedString(@"Device Binding Success", nil) forState:UIControlStateNormal];
                            
                            [networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
                            ZJMDeviceNameVC *deviceNameVC = [[ZJMDeviceNameVC alloc]init];
                            deviceNameVC.physicalDeviceId = delegate.physicalDeviceId;
                            deviceNameVC.backDeviceName = ^(NSString *deviceName) {
                                _robotName = deviceName;
                                
                                //设备名称
                                [ACBindManager changNameWithSubDomain:_subDomain deviceId:delegate.deviceId name:_robotName callback:^(NSError *error) {
                                    NSLog(@"修改成功");
                                    [ACBindManager getDeviceProfileWithSubDomain:_subDomain deviceId:delegate.deviceId callback:^(ACObject *profile, NSError *error) {
                                        
                                    }];
                                }];
                            };
                            deviceNameVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                            deviceNameVC.backType = type;
                            
                            [self presentViewController:deviceNameVC animated:YES completion:nil];
                            
                        }else{
                            
                        }
                    }];
                }];
                
                
            }else{
                NSLog("已经绑定的id---%@",_localDevice.deviceId);
                
            }
        }else{
            
        }
    }];
}

-(void)smartConnect{
    
    if (count++ >6)
    {
        count = 0;
        [_wifiTimer invalidate];
        _wifiTimer=nil;
        [self showHudWithString:NSLocalizedString(@"Activation failed, please re-connect", nil)];
        [networkLoadingVC.networkIndicatorView stopAnimating];
        [networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
        [_connectBtn setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
        _connectBtn.enabled = YES;
        _passwordTF.enabled=YES;
    }
    else if (count == 4)
    {
        [_wifiTimer invalidate];
        _wifiTimer=nil;
        _wifiTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(smartConnect)userInfo:nil repeats:YES];
    }
    [self searchAllDevices];
    
}
#pragma mark - 密文
- (IBAction)passwordTextEntry:(UIButton *)sender {
    
    _passwordTF.secureTextEntry=!_passwordTF.secureTextEntry;
    sender.selected=!sender.selected;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self connect];
    return YES;
}
@end

