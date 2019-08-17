//
//  ZJMRegisterVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/21.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMRegisterVC.h"
#import "ZJMVerificationVC.h"
#import "ZJMUserAgreeVC.h"

@interface ZJMRegisterVC ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UILabel *userAgreeLab;
@property (weak, nonatomic) IBOutlet UIButton *userAgreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *secondUserAgreeLab;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondSelectBtn;

@end

@implementation ZJMRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameTF.placeholder = NSLocalizedString(@"Please Enter E-mail Address", nil);
    self.userAgreeLab.text = NSLocalizedString(@"Read and Agreed", nil);
    [self.userAgreeBtn setTitle:NSLocalizedString(@"User Agreement", nil) forState:UIControlStateNormal];
    [self.nextBtn setTitle:NSLocalizedString(@"Next Step",nil) forState:UIControlStateNormal];
    self.secondUserAgreeLab.text = NSLocalizedString(@"Read and Agreed", nil);
    [self.privacyBtn setTitle:NSLocalizedString(@"Privacy Policy Agreement", nil) forState:UIControlStateNormal];
    _userBtn.selected  = YES;
    self.userNameTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
    self.userNameTF.leftViewMode = UITextFieldViewModeAlways;
    [self setTextFieldLayer];
     [_userNameTF becomeFirstResponder];
//   _userAgreeLab.font = [UIFont systemFontOfSize:16];
//    _userAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
}

-(void)setTextFieldLayer{
    
    _userNameTF.layer.borderWidth=1.0f;
    _userNameTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;

}


#pragma mark - 点击下一步
- (IBAction)nextStep{
    [self.view endEditing:YES];
    if ([_userNameTF.text isEqualToString:@""]) {
        [self showHudWithString:NSLocalizedString(@"Please Enter E-mail Address", nil)];
    } else if ([self isValidateEmail:_userNameTF.text] == NO) {
        
       [self showHudWithString:NSLocalizedString(@"Wrong Email Format", nil)];
    }else if (self.selectBtn.selected ==0){
        [self showHudWithString:NSLocalizedString(@"Please Read and Agree The User Agreement", nil)];
    }else if (self.secondSelectBtn.selected==0){
        NSString *readStr =NSLocalizedString(@"Please Read and Agree Privacy Policy Agreement", nil);
        [self showHudWithString:readStr];
        
    }else{
       [ACAccountManager checkExist:_userNameTF.text callback:^(BOOL exist, NSError *error) {
       
           if (!error) {
              
               if (!exist){
                  
                ZJMVerificationVC *verificationVc = [[ZJMVerificationVC alloc]init];
                verificationVc.mailAccount = self.userNameTF.text;
                verificationVc.title = NSLocalizedString(@"Sign Up", nil);
                [self.navigationController pushViewController:verificationVc animated:YES];
                
        }else{
               [self showHudWithString:NSLocalizedString(@"Mailbox Already Used, Please Try Another", nil)];
          
        }
          
           }else{
             
               switch (error.code) {
                   case 1998:
                       [self showHudWithString:NSLocalizedString(@"Network error, please check", nil)];
                       break;
                       
                   default:[self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                       break;
               }
           }
       }];
   }
}

#pragma mark -注册协议按钮
- (IBAction)rules:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
    [userDafaults setBool:sender.selected forKey:@"selected"];
    [userDafaults synchronize];
}

- (IBAction)privacy:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)UserAgree:(UIButton *)sender {
    ZJMUserAgreeVC *userAgreeVC = [[ZJMUserAgreeVC alloc]init];
    userAgreeVC.type=1;
    userAgreeVC.title =NSLocalizedString(@"User Agreement", nil);
    [self.navigationController pushViewController:userAgreeVC animated:YES];
}

- (IBAction)PrivacyAgree:(UIButton *)sender {
    ZJMUserAgreeVC *userAgreeVC = [[ZJMUserAgreeVC alloc]init];
    userAgreeVC.type=2;
    userAgreeVC.title =NSLocalizedString(@"Privacy Policy Agreement", nil);
    [self.navigationController pushViewController:userAgreeVC animated:YES];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextStep];
    return YES;
}
@end
