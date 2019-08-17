//
//  ZJMConnectBVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/28.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMConnectVC.h"
#import <Reachability/Reachability.h>
#import "ZJMConnectionVC.h"
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
    self.midTextLab.text = NSLocalizedString(@"Please Check If Mobile Has Connected to WLAN", nil);
    [self.connectControl setTitle:NSLocalizedString(@"Setting", nil) forSegmentAtIndex:0];
    [self.connectControl setTitle:NSLocalizedString(@"Already Connected", nil) forSegmentAtIndex:1];
    
    [self setUPSegmentControl];
    
    
}

#pragma mark - 设置UISegmentedControl
-(void)setUPSegmentControl{
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIFont systemFontOfSize:12],
                         NSFontAttributeName,nil];
    
    [ _connectControl setTitleTextAttributes:dic forState:UIControlStateNormal];
    
}

#pragma mark- 去连接/我已连接
- (IBAction)systemConnect:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        
        if (![[self returnNetworkState] isEqualToString:@"WIFI"]) {
            NSString *str = @"QXBwLVByZWZzOnJvb3Q9V0lGSQ==";
            NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
            NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]]; 
        }else{
            ZJMConnectionVC *connectionVc = [[ZJMConnectionVC alloc]init];
            connectionVc.subDomain=_subDomain;
            [self.navigationController pushViewController:connectionVc  animated:YES];
        }
    }
    else{
        
        if (![[self returnNetworkState]isEqualToString:@"WIFI"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Remind", nil)message:NSLocalizedString(@"Please Check If Mobile Has Connected to WLAN", nil)preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *knownAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:knownAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            
            ZJMConnectionVC *connectionVc = [[ZJMConnectionVC alloc]init];
            connectionVc.subDomain=_subDomain;
            [self.navigationController pushViewController:connectionVc  animated:YES];
            
        }
        
    }
}


@end
