
//
//  ZJMBindFailVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/9/19.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMBindFailVC.h"
#import "ZJMConnectionVC.h"
@interface ZJMBindFailVC ()
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIButton *apBtn;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UILabel *step4Label;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ZJMBindFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.retryBtn setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
    [self.apBtn setTitle:NSLocalizedString(@"Configure network in the AP", nil) forState:UIControlStateNormal];
    self.step1Label.text = NSLocalizedString(@"1.Make sure your device is in the network configuration mode;", nil);
     self.step2Label.text = NSLocalizedString(@"2.Make sure the WiFi password entered is correct;", nil);
     self.step3Label.text = NSLocalizedString(@"3.Make sure that the access name of the wireless router is different under the 2.4GHz network and the 5Hz network, and the mobile phone is connected to the 2.4GHz network of the wireless router;", nil);
     self.step4Label.text = NSLocalizedString(@"4.Make sure that the black and white list (mac address filtering) function is turned off on the wireless router;", nil);
     self.titleLabel.text = NSLocalizedString(@"Please follow the steps below to troubleshoot possible issues:", nil);
    
    
    
}
- (IBAction)ApnetWork:(UIButton *)sender {
    ZJMConnectionVC *connectionVc = [[ZJMConnectionVC alloc]init];
    connectionVc.title = NSLocalizedString(@"Connection Wizard", nil);
    connectionVc.subDomain = _subDomain;
    [self.navigationController pushViewController:connectionVc animated:YES];
}
- (IBAction)retry:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
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
