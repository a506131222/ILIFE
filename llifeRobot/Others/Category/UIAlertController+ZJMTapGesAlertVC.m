//
//  UIAlertController+ZJMTapGesAlertVC.m
//  llifeRobot
//
//  Created by 魏青青 on 2019/8/13.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "UIAlertController+ZJMTapGesAlertVC.h"

@implementation UIAlertController (ZJMTapGesAlertVC)
- (void)tapGesAlert{
    
    NSArray * arrayViews = [UIApplication sharedApplication].keyWindow.subviews;
    if (arrayViews.count>0) {
        //array会有两个对象，一个是UILayoutContainerView，另外一个是UITransitionView，我们找到最后一个
        UIView * backView = arrayViews.lastObject;
        //我们可以在这个backView上添加点击事件，当然也可以在其子view上添加，如下：
        //        NSArray * subBackView = [backView subviews];
        //        backView = subBackView[0];  或者如下
        //        backView = subBackView[1];
        backView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [backView addGestureRecognizer:tap];
    }
    
}
-(void)tap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
