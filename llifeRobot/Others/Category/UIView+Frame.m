//
//  UIView+Frame.m
//  彩票
//
//  Created by xiaomage on 15/9/22.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)
- (CGFloat)width
{
    return self.bounds.size.width;
}
- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (CGFloat)height
{
    return self.bounds.size.height;
}
- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (CGFloat)x
{
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;

}
- (CGFloat)y
{
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;

}
@end
