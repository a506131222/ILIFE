//
//  ZJMEmailButton.m
//  llifeRobot
//
//  Created by 魏青青 on 2018/10/30.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMEmailButton.h"

@implementation ZJMEmailButton

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (![self.emailTF.text isEqualToString:@""] ) {
        CGPoint TextViewPoint = [self convertPoint:point toView:self.emailTF];
        if ([self.emailTF pointInside:TextViewPoint withEvent:event]) {
            return _emailTF;
        }
    }
    
    return [super hitTest:point withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
