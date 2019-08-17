//
//  UIImage+Util.h
//  YouLa
//
//  Created by Carl on 13-12-5.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Size)
+ (UIImage *)imageFromView:(UIView *)view;
- (UIImage *)imageWithScale:(CGFloat)scale;
- (UIImage *)imageWithSize:(CGSize)size;
- (NSString *)encodeBase64;
@end
