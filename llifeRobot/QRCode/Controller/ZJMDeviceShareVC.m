//
//  ZJMDeviceShareVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMDeviceShareVC.h"

@interface ZJMDeviceShareVC ()
@property (weak, nonatomic) IBOutlet UILabel *qrCodeLab;

@end

@implementation ZJMDeviceShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.qrCodeLab.text = NSLocalizedString(@"Scan QR Code To Bind The Robot", nil);
    self.qrCodeLab.font = [UIFont systemFontOfSize:17];
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
