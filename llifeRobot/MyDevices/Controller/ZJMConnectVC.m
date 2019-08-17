//
//  ZJMConnectBVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/28.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMConnectVC.h"
#import <Reachability/Reachability.h>
#import "ZJMNewRobotVC.h"
@interface ZJMConnectVC ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *connectControl;
@property (weak, nonatomic) IBOutlet UILabel *midTextLab;

@end

@implementation ZJMConnectVC
{
    Reachability *reach;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Connect WLAN", nil);
    self.midTextLab.text = NSLocalizedString(@"Please confirm whether the phone is connecting with the Wi-Fi.", nil);
    [self.connectControl setTitle:NSLocalizedString(@"Go to connect", nil) forSegmentAtIndex:0];
    [self.connectControl setTitle:NSLocalizedString(@"I have connected", nil) forSegmentAtIndex:1];

    [self setUPSegmentControl];
    
    
}

#pragma mark - 设置UISegmentedControl
-(void)setUPSegmentControl{
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont systemFontOfSize:17],
                         NSFontAttributeName,nil];
    
    [ _connectControl setTitleTextAttributes:dic forState:UIControlStateNormal];
      
   }

#pragma mark- 去连接/我已连接
- (IBAction)systemConnect:(UISegmentedControl *)sender {
  
    if (sender.selectedSegmentIndex == 0) {
      
        if (![[self returnNetworkState] isEqualToString:@"WIFI"]) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
    }
}
    else{
    if (![[self returnNetworkState]isEqualToString:@"WIFI"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Note", nil)message:NSLocalizedString(@"Please connect your phone to home Wi-Fi", nil)
        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *knownAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"I see", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:knownAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }else{
        
         ZJMNewRobotVC *newRobotVc = [[ZJMNewRobotVC alloc]init];
        newRobotVc.subDomain=_subDomain;
        [self.navigationController pushViewController:newRobotVc  animated:YES];
        
        }
    
    }
}


@end
