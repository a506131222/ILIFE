//
//  ZJMAvatarBVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/20.
//  Copyright © 2017年 ZJM. All rights reserved.
//


#import "ZJMBaseVC.h"


typedef void (^BackUserNameBlock) (NSString *userName);

@interface ZJMUserNameVC : ZJMBaseVC

@property(nonatomic, copy) BackUserNameBlock backUserNameBlock;

@end
