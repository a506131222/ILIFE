//
//  ZJMResetPasswordVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/21.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMResetPasswordVC.h"
#import "ZJMGetCodeVC.h"

@interface ZJMResetPasswordVC ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation ZJMResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _userNameTF.layer.borderWidth=1.0f;
    _userNameTF.layer.borderColor=HexColor(0xBFBFBF).CGColor;
    _userNameTF.placeholder = NSLocalizedString(@"Please Enter E-mail Address", nil);
    [_nextBtn setTitle:NSLocalizedString(@"Next Step", nil) forState:UIControlStateNormal];
    _userNameTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
    _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    [_userNameTF becomeFirstResponder];
}


#pragma mark - 点击下一步
- (IBAction)nextStep{
    if ([_userNameTF.text isEqualToString:@""] ) {
        [self showHudWithString:NSLocalizedString(@"Please Enter E-mail Address", nil)];
    }
   else if ([self isValidateEmail:_userNameTF.text] == NO) {
        
       [self showHudWithString:NSLocalizedString(@"Wrong Email Format", nil)];
    }
         
    else{
        
        [ACAccountManager checkExist:_userNameTF.text callback:^(BOOL exist, NSError *error) {
       
            if (!error) {
            
                if (!exist) {
                
                    [self showHudWithString:NSLocalizedString(@"This Email is Not Registered", nil)];
                }
                else
                
                {
                ZJMGetCodeVC *getCodeVc = [[ZJMGetCodeVC alloc]init];
                getCodeVc.title = NSLocalizedString(@"Reset Password", nil);
                getCodeVc.account = _userNameTF.text;
                [self.navigationController pushViewController:getCodeVc animated:YES];
           
                }
            }else{
                switch (error.code) {
                    case 1998:
                        [self showHudWithString:NSLocalizedString(@"NetWork Error", nil)];
                        break;
                        
                    default:[self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                        break;
                }
            }
        }];
    }
    
}
                
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextStep];
    return YES;
}




@end
