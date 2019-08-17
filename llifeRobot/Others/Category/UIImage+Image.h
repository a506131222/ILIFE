//
//  UIImage+Image.h
//  彩票
//
//  Created by xiaomage on 15/9/21.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Image)
// 给定一个最原始的图片名称生成一个原始的图片
+ (instancetype)imageWithOriginalImageName:(NSString *)imageName;
@end
