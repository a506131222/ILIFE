//
//  ZJMWaterModelCell.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/4/6.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMWaterModelCell.h"

@implementation ZJMWaterModelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    NSArray *languages = [NSLocale preferredLanguages]; //系统偏好语言
    NSString *language = languages.firstObject;
    if ([language containsString:@"Han"]==YES) {
        _width.constant+=10;
    }else{
        _width.constant+=35;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
