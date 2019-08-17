
//
//  ZJMLIneCodeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/8/29.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMLineCodeVC.h"
#import "ZJMAPConnectVC.h"
#import "RHScanViewController.h"
@interface ZJMLineCodeVC ()


@property (weak, nonatomic) IBOutlet UITextField *codeTF;


@end

@implementation ZJMLineCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.lineCodeTF.text
    
}
- (IBAction)next:(UIButton *)sender {
    if (self.lineCodeTF.text.length==0) {
        [self showHudWithString:@"ID条码不能为空"];
    }else if (self.lineCodeTF.text.length>12){
        [self showHudWithString:@"ID条码过长"];
    }else if (self.lineCodeTF.text.length<12){
        [self showHudWithString:@"ID条码过短"];
    }
    else{
        ZJMAPConnectVC *apConnectVc =[[ZJMAPConnectVC alloc]init];
        apConnectVc.title= @"AP配网模式";
        apConnectVc.ssid = self.ssid;
        apConnectVc.wifiPassWord= self.wifiPassWord;
        apConnectVc.lineCode =self.lineCodeTF.text;
        [self.navigationController pushViewController:apConnectVc animated:YES];
    }
  
}
- (IBAction)scanLineCode:(UIButton *)sender {
    RHScanViewController *scanVc = [[RHScanViewController alloc]init];
    scanVc.title = @"扫描ID条码";
    scanVc.type=1;
    scanVc.backLineCode = ^(NSString *code) {
        _codeTF.userInteractionEnabled=NO;
        _codeTF.text=code;
    };
    [self.navigationController pushViewController:scanVc animated:YES];
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
