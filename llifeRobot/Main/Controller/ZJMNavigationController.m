//
//  ZJMNavigationController.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMNavigationController.h"
#import "PreHeader.h"

@interface ZJMNavigationController ()

@end

@implementation ZJMNavigationController
{
    UIBarButtonItem *_commonaddItem;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self.navigationBar.translucent = NO;

    self = [super initWithRootViewController:rootViewController];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
     [[UINavigationBar appearance]setBarTintColor:HexColor(0x00BDB5)];
     [UINavigationBar appearance].translucent = NO;
    
    if (self) {
        if (iPhone5) {
            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:19]}];
        }else{
            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:21]}];
        }

        
    }
    return self;
}


@end
