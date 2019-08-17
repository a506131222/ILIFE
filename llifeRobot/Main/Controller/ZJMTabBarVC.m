//
//  ZJMTabBarVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMTabBarVC.h"
#import "ZJMMyDeviceVC.h"
#import "ZJMPersonalVC.h"
#import "ZJMNavigationController.h"
#import "PreHeader.h"

@interface ZJMTabBarVC ()<UITabBarControllerDelegate,UITabBarDelegate>


@end

@implementation ZJMTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (id)init{
    
    self = [super init];
    
    if(self){
        
        self.tabBar.opaque = YES;
        UITabBarItem *item1 = [[UITabBarItem alloc] init];
        item1.tag = 1;
        item1.title = NSLocalizedString(@"My Robot", nil);
        [item1 setImage:[UIImage imageNamed:@"我的设备"]];
        [item1 setSelectedImage:[[UIImage imageNamed:@"我的设备-选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item1 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:189/255.0 blue:180/255.0 alpha:1.0]}forState:UIControlStateSelected];
        
        UITabBarItem *item2 = [[UITabBarItem alloc] init];
        item2.tag = 2;
        item2.title = NSLocalizedString(@"My Center", nil);
        [item2 setImage:[UIImage imageNamed:@"个人中心"]];
        [item2 setSelectedImage:[[UIImage imageNamed:@"个人中心-选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item2 setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:189/255.0 blue:180/255.0 alpha:1.0]}forState:UIControlStateSelected];
        
        
        
        ZJMMyDeviceVC *deviceVC = [[ZJMMyDeviceVC alloc]initWithNibName:nil bundle:nil];
        deviceVC.title = NSLocalizedString(@"My Robot", nil);
        ZJMNavigationController *deviceNav = [[ZJMNavigationController alloc]initWithRootViewController:deviceVC];
        deviceNav.tabBarItem =item1;
        
        
        ZJMPersonalVC *personVC = [[ZJMPersonalVC alloc]initWithNibName:nil bundle:nil];
        personVC.title =  NSLocalizedString(@"My Center", nil);
        ZJMNavigationController *personNav = [[ZJMNavigationController alloc]initWithRootViewController:personVC];
        personNav.tabBarItem =item2;
        
        self.viewControllers = @[deviceNav,personNav];
        
        self.delegate = self;
        
        
        return  self;
    }
    return nil;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height); //  <- Here
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)loadView
{
    [super loadView];
    //修改高度
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGFloat tabBarHeight = 49;
    self.tabBar.frame = CGRectMake(0, height-tabBarHeight, width, tabBarHeight);
    self.tabBar.clipsToBounds = YES;
    UIView *transitionView = [[self.view subviews] objectAtIndex:0];
    //    transitionView.height = height-tabBarHeight;
    
    CGRect rect = transitionView.frame;
    
    rect.size.height =height-tabBarHeight;
    
    transitionView.frame = rect;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationPortrait==interfaceOrientation);
}
@end
