//
//  ZJMAPConnectVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/8/29.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMAPConnectVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ZJMNetworkLoadingVC.h"
#import "ZJMDeviceNameVC.h"
#import "ZJMTabBarVC.h"
#import "ACDeviceMsg.h"
#import <NetworkExtension/NetworkExtension.h>
#import "ZJMBindFailVC.h"
@interface ZJMAPConnectVC ()


@property (nonatomic,copy)ACWifiLinkManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;
@property(nonatomic, strong) NSMutableArray  *unBindDevicesArrM;
@property (nonatomic,copy) ACLocalDevice *localDevice;
@property (nonatomic,copy) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITextField *wifiNameTF;
@property (nonatomic)  NSTimeInterval timeInterval;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (nonatomic,strong)ZJMNetworkLoadingVC *networkLoadingVC;

@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UILabel *prompLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *WiFiLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic,strong)NSString *IDStr;
@property (nonatomic)BOOL apply;
@property (nonatomic)BOOL connected;
@property (nonatomic,assign)NSInteger temp;
@end

@implementation ZJMAPConnectVC
{
    NSInteger count;
    NSInteger type;
    int j;
    
}
- (NSMutableArray *)unBindDevicesArrM {
    if (_unBindDevicesArrM == nil) {
        _unBindDevicesArrM = @[].mutableCopy;
    }
    return _unBindDevicesArrM;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _networkLoadingVC = [[ZJMNetworkLoadingVC alloc]init];
    self.title = NSLocalizedString(@"AP Networking Mode", nil);
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]){
        self.stepLabel.text = NSLocalizedString(@"Step Four", nil);
    }else{
        self.stepLabel.text = NSLocalizedString(@"Step Five", nil);
    }
    self.tipLabel.text = NSLocalizedString(@"*Tips: Please connect your mobile phone to the \"Robot-XXXX\" wireless network of robot with the default password is 123456789. Go back to this page after connected successfully, and click to start the connection.", nil);
    self.prompLabel.text = NSLocalizedString(@"The robot temporarily cannot be accessed to the WiFi of 5GHz", nil);
    [self.settingBtn setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
    self.WiFiLabel.text = NSLocalizedString(@"Robot Wi-Fi:", nil);
    [self.connectBtn setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
    _temp=0;
    [self applicationWillEnterForeground];
}
- (void)viewDidDisappear:(BOOL)animated{
    _timer.fireDate = [NSDate distantFuture];
    [_timer invalidate];
    _timer = nil;
    [self.manager stopWifiLink];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
    _connected=NO;
    count=4;
}
-(void)applicationWillEnterForeground{
    self.wifiNameTF.text=[ACWifiLinkManager getCurrentSSID];
    if (![self.wifiNameTF.text hasPrefix:@"Robot"]) {
        if (_temp==0) {
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Please jump to the phone settings interface, connect to the WiFi beginning with Robot what the default password is 123456789", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *str = @"QXBwLVByZWZzOnJvb3Q9V0lGSQ==";
                NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
                NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]]; 
            }]];
            [self presentViewController:alertVC animated:YES completion:nil];
        }else{
            _connected=NO;
            if (_connected==NO) {
                //加入其他WiFi后重新加入选择设置的WiFi
                [self performSelector:@selector(autoConnetionWiFi) withObject:nil afterDelay:20];
            }
        }
    }else{
        
        if (_connected==NO) {
            _networkLoadingVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:_networkLoadingVC animated:YES completion:nil];
            [_networkLoadingVC.networkIndicatorView startAnimating];
            [_networkLoadingVC.stopConnectBtn addTarget:self action:@selector(stopConnect:) forControlEvents:UIControlEventTouchUpInside];
            _networkLoadingVC.netWorkLab.text = NSLocalizedString(@"Activating Your Robot, Please Wait…", nil);
            self.lineCode = [self getCurrentWifiBSSID];
            [_connectBtn setTitle:NSLocalizedString(@"Activating Your Robot, Please Wait…", nil)forState:UIControlStateNormal];
            _manager = [[ACWifiLinkManager alloc] initWithLinkerName:ACLinkerNameAPMode];
            if ([_IDStr compare:@"845dd7" options:NSCaseInsensitiveSearch] != 0) {
                [_manager customApAddress:@"10.10.100.254"];
            }else{
                [_manager customApAddress:@"192.168.1.10"];
            }
            [self.manager APSendWifiInfo:_ssid password:_wifiPassWord timeout:15 callback:^(BOOL response, NSArray *localDevices, NSError *error){
            }];
            
            [self performSelector:@selector(autoConnetionWiFi) withObject:nil afterDelay:20];
        }
    }
   
}

#pragma mark - 停止配网
-(void)stopConnect:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Stop?", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoConnetionWiFi) object:nil];
        self.wifiNameTF.text=[ACWifiLinkManager getCurrentSSID];
        _timer.fireDate = [NSDate distantFuture];
        [_timer invalidate];
        _timer=nil;
        [_manager stopWifiLink];
        [_networkLoadingVC.networkIndicatorView stopAnimating];
        [_networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
        [_connectBtn setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
        _connectBtn.enabled = YES;
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [_networkLoadingVC presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark - 系统设置
- (IBAction)setting:(UIButton *)sender {
    NSString *str = @"QXBwLVByZWZzOnJvb3Q9V0lGSQ==";
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
    } else {
       
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]]; 
    }

}

#pragma mark - 开始连接
- (IBAction)connect:(UIButton *)sender {
    if (![self.wifiNameTF.text hasPrefix:@"Robot"]) {
        
        [self showHudWithString:NSLocalizedString(@"Please Choose WLAN Name Started with Robot-XXXX", nil)];
    }else{
        _connected=YES;
        count=4;
        _networkLoadingVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:_networkLoadingVC animated:YES completion:nil];
        [_networkLoadingVC.networkIndicatorView startAnimating];
        [_networkLoadingVC.stopConnectBtn addTarget:self action:@selector(stopConnect:) forControlEvents:UIControlEventTouchUpInside];
        _networkLoadingVC.netWorkLab.text = NSLocalizedString(@"Activating Your Robot, Please Wait…", nil);
        [_connectBtn setTitle:NSLocalizedString(@"Activating Your Robot, Please Wait…", nil)forState:UIControlStateNormal];
        _manager = [[ACWifiLinkManager alloc] initWithLinkerName:ACLinkerNameAPMode];
        if ([_IDStr compare:@"845dd7" options:NSCaseInsensitiveSearch] != 0) {
            [_manager customApAddress:@"10.10.100.254"];
        }else{
            [_manager customApAddress:@"192.168.1.10"];
        }
        [self.manager APSendWifiInfo:_ssid password:_wifiPassWord timeout:15 callback:^(BOOL response, NSArray *localDevices, NSError *error){
            
        }];
        [self performSelector:@selector(autoConnetionWiFi) withObject:nil afterDelay:20];
    }
}
#pragma mark - 自动连接Wi-Fi
-(void)autoConnetionWiFi{
    if (@available(iOS 11.0, *)) {
        
        //        询问设置自动连接Wi-Fi
        NEHotspotConfiguration *hotspotConfig = [[NEHotspotConfiguration alloc]initWithSSID:_ssid passphrase:_wifiPassWord isWEP:NO];
        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotspotConfig completionHandler:^(NSError * _Nullable error) {
            _temp++;
            if (error && error.code != 13 && error.code != 7) {
                NSLog(@"加入失败");
                _timer.fireDate = [NSDate distantFuture];
                [_timer invalidate];
                _timer=nil;
                [self.manager stopWifiLink];
                [_networkLoadingVC.networkIndicatorView stopAnimating];
                [_networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
                ZJMBindFailVC *failVc = [[ZJMBindFailVC alloc]init];
                failVc.subDomain=self.subDomain;
                [self.navigationController pushViewController:failVc animated:YES];
            }else if(error.code ==7){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Connect WLAN", nil) message:[NSString stringWithFormat:@"请将手机切换到WiFi\"%@\"后返回App",_ssid] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *settingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Setting", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    NSString *str = @"QXBwLVByZWZzOnJvb3Q9V0lGSQ==";
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
                    NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]]; 
                    }
                }];
                [alertController addAction:settingAction];
                [_networkLoadingVC presentViewController:alertController animated:YES completion:nil];
            }else{
                [self haveNetwork];
            }
        }];
        
    }else {
        [self haveNetwork];
    }
}

-(void)haveNetwork{
    [self bindDeviceWithSubDomain:self.subDomain physicalDeviceId:_lineCode];
    _timer= [NSTimer timerWithTimeInterval:15 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self bindDeviceWithSubDomain:self.subDomain physicalDeviceId:_lineCode];
    }];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}
#pragma mark - 绑定设备
-(void)bindDeviceWithSubDomain:(NSString *)subDomain physicalDeviceId:(NSString *)physicalDeviceId{
    //是否被绑定
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 绑定设备
    [ACBindManager bindDeviceWithSubDomain:subDomain physicalDeviceId:physicalDeviceId name:nil callback:^(ACUserDevice *userDevice, NSError *error) {
        
        if(!error){
            _timer.fireDate = [NSDate distantFuture];
            [_timer invalidate];
            _timer=nil;
            [self.manager stopWifiLink];
            _networkLoadingVC.netWorkLab.text = NSLocalizedString(@"Binding Done", nil);
            [_networkLoadingVC.networkIndicatorView stopAnimating];
            [_connectBtn setTitle:NSLocalizedString(@"Binding Done", nil) forState:UIControlStateNormal];
            [_networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
            ZJMDeviceNameVC *deviceNameVC = [[ZJMDeviceNameVC alloc]init];
            deviceNameVC.physicalDeviceId = [userDevice.physicalDeviceId uppercaseString];
            deviceNameVC.backDeviceName = ^(NSString *deviceName) {
                
                //设备名称
                [ACBindManager changNameWithSubDomain:subDomain deviceId:userDevice.deviceId name:deviceName callback:^(NSError *error) {
                    NSLog(@"修改成功");
                    [ACBindManager getDeviceProfileWithSubDomain:subDomain deviceId:delegate.deviceId callback:^(ACObject *profile, NSError *error) {
                        
                    }];
                }];
            };
            deviceNameVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            deviceNameVC.backType = type;
            deviceNameVC.physicalDeviceId = [userDevice.physicalDeviceId uppercaseString];
            [self presentViewController:deviceNameVC animated:YES completion:nil];
        }else{
            NSLog(@"%ld",count);
            count--;
            if (count==0) {
                _timer.fireDate = [NSDate distantFuture];
                [_timer invalidate];
                _timer=nil;
                [self.manager stopWifiLink];
                [_networkLoadingVC.networkIndicatorView stopAnimating];
                [_networkLoadingVC dismissViewControllerAnimated:YES completion:nil];
                [_connectBtn setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
                self.wifiNameTF.text=[ACWifiLinkManager getCurrentSSID];
            }
        }
    }];
}

#pragma mark - 获取WIFI名称
- (NSString *)getCurrentWifiBSSID{
    NSMutableString * BSSID = [[NSMutableString alloc] initWithString:@""];
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            NSArray * tempArr = [[dict valueForKey:@"BSSID"] componentsSeparatedByString:@":"];
            for (NSString * str in tempArr) {
                if (str.length==2) {
                    [BSSID appendFormat:@"%@",str];
                }else{
                    [BSSID appendFormat:@"0%@",str];
                }
            }
            _IDStr = [BSSID substringWithRange:NSMakeRange(0, 6)];
            if ([_IDStr compare:@"845dd7" options:NSCaseInsensitiveSearch] != 0) {
                NSInteger b = strtoul([BSSID UTF8String], 0, 16)-1;
                BSSID = [[NSMutableString alloc] initWithString:[self getHexByDecimal:b]] ;
            }
        }
    }
    CFRelease(myArray);
    
    return BSSID;
}
-(NSString *)getHexByDecimal:(NSInteger)decimal {
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<12; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            break;
        }
    }
    return hex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
