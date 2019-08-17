//
//  ZJMBaseVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import <objc/message.h>
#import "ZJMLoginVC.h"
#import <Reachability/Reachability.h>
@interface ZJMBaseVC ()
@property (nonatomic, strong) NSTimer *hideTimer;
@end

@implementation ZJMBaseVC
{
    MBProgressHUD *mbpHud;
    BOOL isHide;
}

- (id)init{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        self.navigationItem.leftBarButtonItem = self.commonbackItem;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    _hideTimer=nil;
    [_hideTimer invalidate];
}
- (UIBarButtonItem *)commonbackItem{
    
    if (_commonbackItem  == nil) {
        
        UIButton *blogItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [blogItem setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        [blogItem addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        _commonbackItem = [[UIBarButtonItem alloc]initWithCustomView:blogItem];
        
        
    }
    
    return _commonbackItem;
}

//-(UIBarButtonItem *)commonaddItem{
//    
//    if (_commonaddItem == nil) {
//        UIButton *rightItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//        [rightItem setImage:[UIImage imageNamed:@"＋图标"] forState:UIControlStateNormal];
//        [rightItem setImage:[UIImage imageNamed:@"＋图标-选中"] forState:UIControlStateSelected];
//        [rightItem addTarget:self action:@selector(addDevice) forControlEvents:UIControlEventTouchUpInside];
//        _commonaddItem = [[UIBarButtonItem alloc]initWithCustomView:rightItem];
//    }
//    return _commonaddItem;
//}

#pragma mark - +号登录或添加设备

-(void)addDevice{
    
    ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
    [self.navigationController pushViewController:loginVc animated:YES];
    
}

#pragma mark- 返回上一级

- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
}


#pragma mark - NSString转NSData
-(NSData *)hexToBytesWith:(NSString *)str{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}


#pragma mark - 十六进制转颜色
-(UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark - Mailbox format

- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}
- (void)showHud{
    
    
    AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    mbpHud =[[MBProgressHUD alloc]initWithView:dele.window];
    
    [dele.window addSubview:mbpHud];
    
    [mbpHud show:YES];
    
    
}

- (void)hideHud{
    mbpHud.hidden = YES;
    isHide=YES;
    [mbpHud removeFromSuperview];
    mbpHud=nil;
    _hideTimer.fireDate = [NSDate distantFuture];
    [_hideTimer invalidate];
    _hideTimer = nil;
}

- (void)showHudWithString:(NSString *)string{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:dele.window];
        [dele.window addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *languageName = [appLanguages objectAtIndex:0];
        if ([languageName containsString:@"Han"]==YES) {
            hud.labelText = string;
            hud.labelFont = [UIFont fontWithName:@"PingFangSC-Light" size:17];
        }else {
            hud.detailsLabelText = string;
            hud.detailsLabelFont = [UIFont fontWithName:@"PingFangSC-Light" size:15];
        }
        
        [hud show:YES];
        [hud hide:YES afterDelay:0.8];
        
    });
}


-(void)showHudWithRound{
    //初始化进度框，置于当前的View当中
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        mbpHud = [[MBProgressHUD alloc]initWithView:dele.window];
        float time = mbpHud.minShowTime;
        isHide = NO;
        NSLog(@"%f",time);
        [dele.window addSubview:mbpHud];
        [mbpHud show:YES];
        _hideTimer = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(connectTimeOut) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop]addTimer:_hideTimer forMode:NSDefaultRunLoopMode];
    });
}
-(void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}
-(void)connectTimeOut{
    if (isHide==NO) {
        [self hideHud];
        self.errorType = NSLocalizedString(@"Connecting Timeout", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Network error, please check", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        return;
    }
    
}
#pragma mark - 判断网络状态
-(NSString *)returnNetworkState{
    NSString *network;
    Reachability *reachchability = [Reachability reachabilityWithHostname:@"www.google.com"];
    switch ([reachchability currentReachabilityStatus]) {
        case NotReachable:
            network = @"无网络";
            break;
        case ReachableViaWiFi:
            network = @"WIFI";
            break;
        case ReachableViaWWAN:
            network = @"WWAN";
            break;
        default:
            break;
    }
    return network;
    
}

@end
