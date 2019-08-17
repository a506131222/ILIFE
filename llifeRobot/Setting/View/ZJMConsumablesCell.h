//
//  ZJMConsumablesCell.h
//  llifeRobot
//
//  Created by Yannis on 24/10/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJMConsumablesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lifeImage;
@property (weak, nonatomic) IBOutlet UILabel *lifeLab;

@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UIProgressView *pregressView;

@end
