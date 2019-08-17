//
//  UIFont+runtime.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/3/3.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "UIFont+runtime.h"
#import <objc/runtime.h>
#import "PreHeader.h"

@implementation UIFont (runtime)

+ (void)load {
    // 获取替换后的类方法
    Method newMethod = class_getClassMethod([self class], @selector(adjustFont:));
    // 获取替换前的类方法
    Method method = class_getClassMethod([self class], @selector(systemFontOfSize:));
    // 然后交换类方法，交换两个方法的IMP指针，(IMP代表了方法的具体的实现）
    method_exchangeImplementations(newMethod, method);
}

+ (UIFont *)adjustFont:(CGFloat)fontSize {
    UIFont *newFont = nil;
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    
    //中文
    if ([languageName containsString:@"Han"]==YES) {
        newFont = [UIFont adjustFont:fontSize *1.0];
    }else if ([languageName hasPrefix:@"de"]==YES){
        newFont = [UIFont adjustFont:fontSize *0.6];
        
    }else{
         newFont = [UIFont adjustFont:fontSize *0.6];
    }
    
    if (iPhone5) {
         newFont = [UIFont adjustFont:fontSize -3];
    }else if (iPhone6){
         newFont = [UIFont adjustFont:fontSize *1.0];
    }else if (iPhone6Plus){
         newFont = [UIFont adjustFont:fontSize +2];
    }
    newFont = [UIFont fontWithName:@"PingFangSC-Light" size:fontSize];
    return newFont;
}

@end
