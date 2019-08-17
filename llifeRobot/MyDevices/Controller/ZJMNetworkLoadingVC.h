//
//  ZJMNetworkLoadingVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/3/9.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJMNetworkLoadingVC : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *netWorkLab;
@property (weak, nonatomic) IBOutlet UIButton *stopConnectBtn;

@end
