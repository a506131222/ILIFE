//
//  NSBundle+Localizations.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/6/19.
//  Copyright © 2018年 ZJM. All rights reserved.
//


#import <Foundation/Foundation.h>

extern NSString *const UserDefaultKey_AppLanguage;

@interface BundleEx : NSBundle

@end

@interface NSBundle (Localizations)

+ (void)setLanguage:(NSString *)language;

@end
