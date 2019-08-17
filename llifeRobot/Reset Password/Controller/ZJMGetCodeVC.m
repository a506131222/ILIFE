//
//  ZJMGetCodeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/23.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMGetCodeVC.h"
#import "ZJMMyDeviceVC.h"
#import "timeoutManager.h"
@interface ZJMGetCodeVC ()


@property (weak, nonatomic) IBOutlet UITextField *verificationTF;

@property (weak, nonatomic) IBOutlet UITextField *passWordTF;

@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;


@end

@implementation ZJMGetCodeVC
{
    int _downTime;
    dispatch_source_t timer;
    BOOL show;
    NSString *btnInfo;
    NSInteger type;
}
static dispatch_source_t timer;


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_verificationTF becomeFirstResponder];
    timeoutManager *manager = [timeoutManager sharedTimerManager];

    int temp = manager.timeout;
    int code = manager.codeType;
    if (code == 0) {
        if (temp > 0) {

            _downTime= temp; //倒计时时间

            [self outTimeDown];

        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    if (type == 1) {
        if (_downTime > 0 && _downTime != 60) {
            timeoutManager *manager = [timeoutManager sharedTimerManager];
            manager.timeout = _downTime;
            
            [manager countDown];
            _downTime = 0;//置为0，释放controller
        }
        
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _verificationTF.layer.borderWidth=1.0f;
    _verificationTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;
    self.verificationTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.verificationTF.leftViewMode = UITextFieldViewModeAlways;
      _passWordTF.layer.borderWidth=1.0f;
    _passWordTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;
    _downTime = 60;
    self.passWordTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.passWordTF.leftViewMode = UITextFieldViewModeAlways;
    _verificationTF.placeholder = NSLocalizedString(@"Enter Verification Code", nil);
    _passWordTF.placeholder = NSLocalizedString(@"Enter New Password", nil);
    [_getCodeBtn setTitle:NSLocalizedString(@"Verification Code Obtaining…",nil) forState:UIControlStateNormal];
    _getCodeBtn.titleLabel.numberOfLines = 0;
    [self.resetPasswordBtn setTitle:NSLocalizedString(@"Reset Password", nil) forState:UIControlStateNormal];
}

#pragma mark - 获取验证码
- (IBAction)gerCode:(UIButton *)btn {
    if (![btn.titleLabel.text isEqualToString:NSLocalizedString(@"Verification Code Obtaining…", nil)]) {
        [self showHudWithString:NSLocalizedString(@"Do not operate frequently", nil)];
        return;
    }
    type = 1;
    timeoutManager *manager = [timeoutManager sharedTimerManager];
    manager.codeType = 0;
    //TODO:
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    NSInteger template;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.appRegion == 0) {
        //中文
        if ([languageName containsString:@"Han"]==YES) {
            template=3;
        }else{
            //英文
            template=2;
        }
    }else if (delegate.appRegion == 1){
        template = 2;
    }else if (delegate.appRegion == 2){
        template = 2;
    }else{
        template = 2;
    }
    
    [ACAccountManager sendVerifyCodeWithAccount:_account template:template callback:^(NSError *error) {
      
        if (error == nil) {
            [self outTimeDown];
        }
        else
        {
            switch (error.code)
            {
                case 3004:
                    [self showHudWithString:NSLocalizedString(@"Verification Code Has Been Sent", nil)];
                    break;
                default:
                    break;
            }
       }
        
    }];
}
-(void)outTimeDown{
    if (type == 1) {
        [self showHudWithString:NSLocalizedString(@"Verification Code Successfully Got", nil)];
    }
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (_downTime <= 0) {
            
            _downTime = 60;
            dispatch_source_cancel(timer);
            dispatch_async(mainQueue, ^{
                [_getCodeBtn setTitle:NSLocalizedString(@"Verification Code Obtaining…", nil) forState:UIControlStateNormal];
               
            });
            
        } else {
            _downTime--;
            dispatch_async(mainQueue, ^{
                NSString *second = NSLocalizedString(@"Seconds", nil);
                btnInfo = [NSString stringWithFormat:@"%ld %@", (long)(_downTime + 1),second];
              
                [_getCodeBtn setTitle:btnInfo forState:UIControlStateNormal];
                
            });
        }
    });
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"Cancel Handler");
    });
    dispatch_resume(timer);
}
#pragma mark - 重置密码
- (IBAction)resetPassword {
    if ([_verificationTF.text isEqualToString:@""])
    {
        
        [self showHudWithString:NSLocalizedString(@"Enter Verification Code", nil)];
        return;
    }
    else if ([_passWordTF.text isEqualToString:@""])
    {
        [self showHudWithString:NSLocalizedString(@"Enter Password", nil)];
        return;
    }
    else if(_passWordTF.text.length < 6 )
    {
        
        [self showHudWithString:NSLocalizedString(@"Please enter a password of 6-18 bits", nil)];
        return ;
        
    }
   
    [ACAccountManager resetPasswordWithAccount:_account verifyCode:_verificationTF.text password:_passWordTF.text callback:^(NSString *uid, NSError *error) {
        
        if (error) {
            switch (error.code)
            {
                case 3502:
                    [self showHudWithString:NSLocalizedString(@"Mailbox Already Used, Please Try Another", nil)];
                    break;
                case 3505:
                    [self showHudWithString:NSLocalizedString(@"Wrong Verification Code", nil)];
                    break;
                case 3506:
                    [self showHudWithString:NSLocalizedString(@"Verification Code Invalid", nil)];
                    break;
                case 3507:
                    [self showHudWithString:NSLocalizedString(@"Invalid Email", nil)];
                    break;
                case 3509:
                    [self showHudWithString:NSLocalizedString(@"Account Status Abnormal", nil)];
                    break;
                default:[self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    break;
            }
        }else{
             [[NSUserDefaults standardUserDefaults]setInteger:[uid integerValue] forKey:@"userID"];
            _downTime = 60;
            [self showHudWithString:NSLocalizedString(@"Reset Password Done", nil)];
            ZJMMyDeviceVC *myDeviceVC = [[ZJMMyDeviceVC alloc]init];
            myDeviceVC.title = NSLocalizedString(@"My Robot", nil);
            [self.navigationController popToRootViewControllerAnimated:YES];
         
        }
    }];

}

- (IBAction)newPassword:(UITextField *)sender {
    [self.passWordTF becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _passWordTF) {
        
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (_passWordTF.text.length >= 18) {
            _passWordTF.text = [textField.text substringToIndex:18];
            [self showHudWithString:NSLocalizedString(@"Password up to 6-18digits", nil)];
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resetPassword];
    return YES;
}

@end
