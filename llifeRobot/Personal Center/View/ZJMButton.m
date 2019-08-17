//
//  ZJMButton.m
//  llifeRobot
//
//  Created by 魏青青 on 2018/10/24.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMButton.h"

@implementation ZJMButton

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (_DeviceListTableView.isHidden) {
        CGPoint TextViewPoint = [self convertPoint:point toView:self.contextTextView];
        if ([self.contextTextView pointInside:TextViewPoint withEvent:event]) {
            return _contextTextView;
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
