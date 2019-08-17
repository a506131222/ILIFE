//
//  ZJMWaterModelCell.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/4/6.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJMWaterModelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *waterBtn;
@property (weak, nonatomic) IBOutlet UILabel *waterModeLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@end
