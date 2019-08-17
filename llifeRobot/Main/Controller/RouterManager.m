//
//  RouterManager.m
//  llifeRobot
//
//  Created by 张佳满 on 2019/8/16.
//  Copyright © 2019 ZJM. All rights reserved.
//

#import "RouterManager.h"
#import "ZJMNavigationController.h"
#import "ZJMChoiceRobotVC.h"
@implementation RouterManager

+(void)load{
    [MGJRouter registerURLPattern:@"link://router/choiceRobot" toHandler:^(NSDictionary *routerParameters) {
        ZJMNavigationController *navVc=routerParameters[MGJRouterParameterUserInfo][@"navVc"];
        ZJMChoiceRobotVC *choiceRobotVc=[[ZJMChoiceRobotVC alloc]init];
        choiceRobotVc.hidesBottomBarWhenPushed=YES;
        choiceRobotVc.title=@"11";
        [navVc pushViewController:choiceRobotVc animated:YES];
    }];
}
@end
