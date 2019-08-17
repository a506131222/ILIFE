//
//  ZJMVerificationVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/21.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMVerificationVC.h"
#import "ZJMTabBarVC.h"
#import "timeoutManager.h"

@interface ZJMVerificationVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *verificationTF;

@property (weak, nonatomic) IBOutlet UITextField *passWordTF;

@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (nonatomic, assign) __block int timeout;
@end

@implementation ZJMVerificationVC
{
    NSInteger type;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    _verificationTF.layer.borderWidth=1.0f;
    _verificationTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;
    _verificationTF.placeholder = NSLocalizedString(@"Enter Verification Code", nil);
   
    [_getCodeBtn  setTitle:NSLocalizedString(@"Verification Code Obtaining…", nil) forState:UIControlStateNormal];
    _getCodeBtn.titleLabel.numberOfLines = 0;
    [_getCodeBtn sizeToFit];
    _passWordTF.layer.borderWidth=1.0f;
    _passWordTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;
    _passWordTF.placeholder = NSLocalizedString(@"Please Set Password", nil);
    _timeout = 60;
    [_registerBtn setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
    self.verificationTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.verificationTF.leftViewMode = UITextFieldViewModeAlways;
    self.passWordTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.passWordTF.leftViewMode = UITextFieldViewModeAlways;
//    [self.verificationTF becomeFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    timeoutManager *manager = [timeoutManager sharedTimerManager];
    
    int temp = manager.timeout;
    int code = manager.codeType;
    if (code == 1) {
        if (temp > 0) {
            
            _timeout= temp; //倒计时时间
            
            [self outTimeDown];
            
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    if (type == 1) {
        if (self.timeout > 0 && self.timeout != 60) {
            
            timeoutManager *manager = [timeoutManager sharedTimerManager];
            
            
            manager.timeout = _timeout;
            
            [manager countDown];
            
            
            
            _timeout = 0;//置为0，释放controller
            
        }
        
    }
    
}


#pragma mark - 点击注册
- (IBAction)registerAccount{
   
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
    else if(_passWordTF.text.length < 6 ){
        
        [self showHudWithString:NSLocalizedString(@"Please enter a password of 6-18 bits", nil)];
        return ;
        
    }
    else{
        
        [ACAccountManager registerWithPhone:nil email:_mailAccount password:_passWordTF.text verifyCode:_verificationTF.text callback:^(NSString *uid, NSError *error) {
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
                default:
                    break;
            }
        }else{
             [[NSUserDefaults standardUserDefaults]setInteger:[uid integerValue] forKey:@"userID"];
            _timeout = 60;
            ZJMTabBarVC *tabBar = [[ZJMTabBarVC alloc]init];
            [self presentViewController:tabBar animated:YES completion:nil];
            }
        }];
    }
}
    

#pragma mark - 获取验证码
- (IBAction)getVerifyCode:(UIButton *)btn {
    if (![btn.titleLabel.text isEqualToString:NSLocalizedString(@"Verification Code Obtaining…", nil)]) {
        [self showHudWithString:NSLocalizedString(@"Do not operate frequently", nil)];
        return;
    }
    timeoutManager *manager = [timeoutManager sharedTimerManager];
    type=1;
    manager.codeType = 1;
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

       [ACAccountManager sendVerifyCodeWithAccount:_mailAccount template:template callback:^(NSError *error) {
       
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
                    default:[self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                        break;
                }
        }
       
    }];
}

-(void)outTimeDown{
    if (type==1) {
        [self showHudWithString:NSLocalizedString(@"Verification Code Successfully Got", nil)];
    }
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (_timeout <= 0) {
            _timeout = 60;
            dispatch_source_cancel(timer);
            dispatch_async(mainQueue, ^{
                [_getCodeBtn setTitle:NSLocalizedString(@"Verification Code Obtaining…", nil) forState:UIControlStateNormal];
               
                
            });
            
        } else {
            _timeout--;
            dispatch_async(mainQueue, ^{
                NSString *second = NSLocalizedString(@"Seconds", nil);
                NSString *btnInfo = [NSString stringWithFormat:@"%ld %@", (long)(_timeout + 1),second];
                
                
                [_getCodeBtn setTitle:btnInfo forState:UIControlStateNormal];
            });
        }
    });
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"Cancel Handler");
    });
    dispatch_resume(timer);
}
- (IBAction)setPassword:(id)sender {
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
    [self registerAccount];
    return YES;
}

@end
