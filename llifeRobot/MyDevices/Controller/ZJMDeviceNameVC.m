//
//  ZJMDeviceNameVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/1.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMDeviceNameVC.h"
#import "ZJMMyDeviceVC.h"
#import "ZJMTabBarVC.h"
#import "ZJMDeviceCell.h"

@interface ZJMDeviceNameVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTF;
@property (weak, nonatomic) IBOutlet UILabel *devideNameLab;
@property (nonatomic, assign) NSInteger textLocation;//这里声明一个全局属性，用来记录输入位置
@end

@implementation ZJMDeviceNameVC



- (void)viewDidLoad {
    [super viewDidLoad];
    [IQKeyboardManager sharedManager].enable = YES;
    self.devideNameLab.text = NSLocalizedString(@"Robot Name:", nil);
    self.devideNameLab.font = [UIFont systemFontOfSize:15];
    self.devideNameLab.adjustsFontSizeToFitWidth=YES;
    self.deviceNameTF.text = NSLocalizedString(@"ILIFE Robot", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    self.deviceNameTF.placeholder = NSLocalizedString(@"Enter Robot Name", nil);
    self.deviceNameTF.font = [UIFont systemFontOfSize:17];
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    if (self.backType == 0) {
//        self.deviceNameTF.text = NSLocalizedString(@"ILIFE Robot", nil);
        NSLog(@"%@",self.physicalDeviceId);
        self.deviceNameTF.text =self.physicalDeviceId;
    }else{
        self.deviceNameTF.text = @"";
    }
      [self.deviceNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


- (void) textFieldDidChange:(UITextField *)textField {
    NSString *temp = [self.deviceNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   
    if (temp.length ==0) {
        self.deviceNameTF.text=@"";
    }
    else if (textField == self.deviceNameTF) {
        if (textField.text.length > 12) {
            UITextRange *textRange = [textField markedTextRange];
            if (textRange) {
                return;
            }
            NSRange range = [textField.text rangeOfComposedCharacterSequenceAtIndex:12];
            textField.text = [textField.text substringToIndex:range.location];
             [self showHudWithString:NSLocalizedString(@"Words exceed the Limit", nil)];
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
#pragma mark - 取消
- (IBAction)cancelResetName:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLabelTextNotification" object:_deviceNameTF.text];
        if (self.backType == 0) {
            [UIApplication sharedApplication].delegate.window.rootViewController = [ZJMTabBarVC new];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
    }];
    
}

#pragma mark - 确认
- (IBAction)confirmResetName:(UIButton *)sender {
      [_deviceNameTF resignFirstResponder];
    if ([_deviceNameTF.text isEqualToString:@""]) {
        [self showHudWithString:NSLocalizedString(@"Enter Robot Name", nil)];
    }
    else{
        if (self.backDeviceName) {
            self.backDeviceName(_deviceNameTF.text);
        }if (self.backType == 0) {
            [UIApplication sharedApplication].delegate.window.rootViewController = [ZJMTabBarVC new];
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}



@end
