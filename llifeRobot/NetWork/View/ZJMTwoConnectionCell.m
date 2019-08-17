//
//  ZJMTwoConnectionCell.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/9/18.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMTwoConnectionCell.h"
#import "ZJMConnectionVC.h"
#import "PreHeader.h"

@implementation ZJMTwoConnectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.stepLabel.text = NSLocalizedString(@"Step Two", nil);
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
