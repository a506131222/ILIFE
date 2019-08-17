//
//  ZJMAvatarBVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/20.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMUserNameVC.h"

@interface ZJMUserNameVC ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (nonatomic,strong)NSString *toBeString;
@property (nonatomic,strong)UITextPosition *position;

@end

@implementation ZJMUserNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [IQKeyboardManager sharedManager].enable = YES;
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.userNameLab.text = NSLocalizedString(@"User Name:", nil);
    self.userNameLab.font = [UIFont systemFontOfSize:17];
    self.userNameTF.placeholder = NSLocalizedString(@"Enter User Name",nil);
    [self.confirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [self.cancelBtn setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
       [_userNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}
- (void) textFieldDidChange:(UITextField *)textField {
    self.toBeString = [self.userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        _position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!_position) {
            if (_toBeString.length > 12) {
                [self showHudWithString:NSLocalizedString(@"Words exceed the Limit", nil)];
                textField.text = [_toBeString substringToIndex:12];
            }
        }
    }else {
        if(_toBeString.length > 12) {
             [self showHudWithString:NSLocalizedString(@"Words exceed the Limit", nil)];
            textField.text = [_toBeString substringToIndex:12];
            
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self stringContainsEmoji:string] == YES || [[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        [self showHudWithString:NSLocalizedString(@"Names can only contain numbers, letters, Chinese, and special characters under English", nil)];
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//释放第一响应者
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 取消
- (IBAction)cancle:(UIButton *)sender {
  
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 确定
- (IBAction)confirm:(UIButton *)sender {
    if ([_userNameTF.text isEqualToString:@""]) {
        [self showHudWithString:NSLocalizedString(@"Please Enter User Name", nil)];
    }
    else if(self.backUserNameBlock) {
        self.backUserNameBlock(_userNameTF.text);
        [ACAccountManager changeNickName:_userNameTF.text callback:^(NSError *error) {
            
            if (!error) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self showHudWithString:NSLocalizedString(@"User Name Update Done", nil)];
            }
        }];
    }
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
