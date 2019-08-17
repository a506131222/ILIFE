//
//  UIButton+Corner.m
//  igame
//
//  Created by Interest on 2016/12/8.
//  Copyright © 2016年 Interest. All rights reserved.
//

#import "UIImageView+Corner.h"

@implementation UIImageView(Corner)

- (void)cornerRadius:(CGFloat )radius{
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius =radius;
}

- (void)borderColor:(UIColor *)color{
    
    self.layer.masksToBounds = YES;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
}
@end
