//
//  UIImage+Image.m
//  彩票
//
//  Created by xiaomage on 15/9/21.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import "UIImage+Image.h"

@implementation UIImage (Image)

+ (instancetype)imageWithOriginalImageName:(NSString *)imageName
{
    // 加载图片
    UIImage *image = [UIImage imageNamed:imageName];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

}
@end
