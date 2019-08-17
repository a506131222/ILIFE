//
//  ZJMReserView.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/12.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMReserView.h"

@implementation ZJMReserView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[[NSBundle mainBundle]loadNibNamed:@"ZJMReserView"owner:self options:nil] firstObject];
        
    }
    return self;
}

@end
