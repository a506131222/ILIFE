
//
//  ZJMLIneCodeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/8/29.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMLineCodeVC.h"
#import "ZJMAPConnectVC.h"
@interface ZJMLIneCodeVC ()


@end

@implementation ZJMLIneCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.lineCodeTF.text
    
}
- (IBAction)next:(UIButton *)sender {
    ZJMAPConnectVC *apConnectVc =[[ZJMAPConnectVC alloc]init];
    apConnectVc.ssid = self.ssid;
    apConnectVc.wifiPassWord= self.wifiPassWord;
    apConnectVc.lineCode =self.lineCodeTF.text;
    [self.navigationController pushViewController:apConnectVc animated:YES];
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
