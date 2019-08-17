//
//  ZJMLoginVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/19.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMLoginVC.h"
#import "ZJMRegisterVC.h"
#import "ZJMResetPasswordVC.h"
#import "ZJMAPNetworkVC.h"
#import "ZJMNavigationController.h"

@interface ZJMLoginVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

//@property (strong, nonatomic) IBOutlet UIView *connectView;


//@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn;


@property (weak, nonatomic) IBOutlet UILabel *wifiNameLab;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTF;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic,assign)NSInteger userID;
@property (nonatomic,strong)UITextPosition *position;
@end

@implementation ZJMLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameTF.placeholder = NSLocalizedString(@"E-mail Address", nil);
    self.passwordTF.placeholder = NSLocalizedString(@"Password", nil);
    self.title = NSLocalizedString(@"Log In",nil);
    [self.resetBtn setTitle:NSLocalizedString(@"Reset Password", nil) forState:UIControlStateNormal];
    self.resetBtn.titleLabel.adjustsFontSizeToFitWidth=YES;
    [self.registerBtn setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
    [self.loginBtn setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    [_userNameTF becomeFirstResponder];
    _wifiPasswordTF.delegate=self;
    _resetBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
}

#pragma mark - 点击登录
- (IBAction)login {
    [self.view endEditing:YES];
    [_wifiPasswordTF resignFirstResponder];
    if ([_userNameTF.text isEqualToString:@""] ) {
        [self showHudWithString:NSLocalizedString(@"Please Enter E-mail Address", nil)];
    }else if ([self isValidateEmail:_userNameTF.text] == NO) {
        [self showHudWithString:NSLocalizedString(@"Wrong Email Format", nil)];
    }else if ([_passwordTF.text isEqualToString:@""]){
        [self showHudWithString:NSLocalizedString(@"Enter Password", nil)];
    }else if (_passwordTF.text.length<6){
        [self showHudWithString:NSLocalizedString(@"Please enter a password of 6-18 bits", nil)];
    }else{
        [self showHudWithRound];
        [ACAccountManager checkExist:_userNameTF.text callback:^(BOOL exist, NSError *error) {
            if (!error) {
                
                if (exist) {
                    [ACAccountManager loginWithUserInfo:_userNameTF.text password:_passwordTF.text callback:^(ACUserInfo *user, NSError *error) {
                        [self hideHud];
                        if (!error) {
                            _userID = user.userId;
                            [[NSUserDefaults standardUserDefaults]setInteger:_userID forKey:@"userID"];
                            
                            [self showHudWithString:NSLocalizedString(@"Log In Success", nil)];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            
                        }else{
                            
                            switch (error.code)
                            {
                                case 3501:
                                    [self showHudWithString:NSLocalizedString(@"This Email is Not Registered", nil)];
                                    break;
                                case 3504:
                                    [self showHudWithString:NSLocalizedString(@"Wrong Password", nil)];
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
                        }
                        
                    }];
                    
                    
                }else{
                    [ACAccountManager loginWithAccount:_userNameTF.text password:_passwordTF.text callback:^(NSString *uid, NSError *error) {
                        [self hideHud];
                        if (error) {
                            switch (error.code)
                            {
                                case 3501:
                                    [self showHudWithString:NSLocalizedString(@"This Email is Not Registered", nil)];
                                    break;
                                case 3504:
                                    [self showHudWithString:NSLocalizedString(@"Wrong Password", nil)];
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
                        }
                        else{
                            [[NSUserDefaults standardUserDefaults]setInteger:[uid integerValue] forKey:@"userID"];
                            [self showHudWithString:NSLocalizedString(@"Log In Success", nil)];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                    
                }
            }else{
                
                [self hideHud];
            }
        }];
    }
    
}

#pragma mark - 点击注册
- (IBAction)registClickBtn:(UIButton *)sender {
    
    ZJMRegisterVC *registerVc = [[ZJMRegisterVC alloc]init];
    registerVc.title = NSLocalizedString(@"Sign Up", nil);
    [self.navigationController pushViewController:registerVc animated:YES];
}

#pragma mark - 重置密码
- (IBAction)reset:(UIButton *)sender {
    
    ZJMResetPasswordVC *resetVc = [[ZJMResetPasswordVC alloc]init];
    resetVc.title = NSLocalizedString(@"Reset Password", nil);
    [self.navigationController pushViewController:resetVc animated:YES];
    
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self login];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString * allStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (range.length == 1 && string.length == 0) {
        textField.text = allStr;
        return NO;
    }
    if (_passwordTF.text.length >= 18) {
        //        _passwordTF.text = [textField.text substringToIndex:18];
        [self showHudWithString:NSLocalizedString(@"Password up to 6-18digits", nil)];
        return NO;
    }
    if ([self stringContainsEmoji:string]==YES ){
        [self showHudWithString:NSLocalizedString(@"Names can only contain numbers, letters, Chinese, and special characters under English", nil)];
        return NO;
    }
    if (textField.isSecureTextEntry == YES) {
        textField.text = allStr;
        return NO;
    }
    
    return YES;
    
}


#pragma mark - 禁止表情
- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                // surrogate pair
                                if (0xd800 <= hs && hs <= 0xdbff)
                                {
                                    if (substring.length > 1)
                                    {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f918)
                                        {
                                            returnValue = YES;
                                        }
                                    }
                                }
                                else if (substring.length > 1)
                                {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3 || ls == 0xFE0F || ls == 0xd83c)
                                    {
                                        returnValue = YES;
                                    }
                                }
                                else
                                {
                                    // non surrogate
                                    if (0x2100 <= hs && hs <= 0x27ff)
                                    {
                                        if (0x278b <= hs && 0x2792 >= hs)
                                        {
                                            returnValue = NO;
                                        }
                                        else
                                        {
                                            returnValue = YES;
                                        }
                                    }
                                    else if (0x2B05 <= hs && hs <= 0x2b07)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (0x2934 <= hs && hs <= 0x2935)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (0x3297 <= hs && hs <= 0x3299)
                                    {
                                        returnValue = YES;
                                    }
                                    else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0xd83e)
                                    {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}


#pragma mark - 是否密文
- (IBAction)passwordTextEntry:(UIButton *)sender {
    
    _passwordTF.secureTextEntry = !_passwordTF.secureTextEntry;
    //    _wifiPasswordTF.secureTextEntry = !_wifiPasswordTF.secureTextEntry;
    sender.selected  =! sender.selected;
}



@end
