//
//  ZJMWeekChoiceCell.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/12.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMWeekChoiceCell.h"
#import "AppDelegate.h"
#import "PreHeader.h"
@interface ZJMWeekChoiceCell()

@property (weak, nonatomic) IBOutlet UILabel *monText;
@property (weak, nonatomic) IBOutlet UILabel *tueText;
@property (weak, nonatomic) IBOutlet UILabel *wedText;
@property (weak, nonatomic) IBOutlet UILabel *thurText;
@property (weak, nonatomic) IBOutlet UILabel *friText;
@property (weak, nonatomic) IBOutlet UILabel *satText;
@property (weak, nonatomic) IBOutlet UILabel *weekText;
@property (weak, nonatomic) IBOutlet UILabel *onceText;

@end
@implementation ZJMWeekChoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if ([delegate.subDomain isEqualToString:X430SubDomain] || [delegate.subDomain isEqualToString:X420SubDomain] || [delegate.subDomain isEqualToString:X620SubDomain] || [delegate.subDomain isEqualToString:X610SubDomain]) {
        self.monText.text = NSLocalizedString(@"MON", nil);
        self.tueText.text = NSLocalizedString(@"TUE", nil);
        self.wedText.text = NSLocalizedString(@"WED", nil);
        self.thurText.text = NSLocalizedString(@"THUR", nil);
        self.friText.text = NSLocalizedString(@"Fri", nil);
        self.satText.text = NSLocalizedString(@"Sat", nil);
        self.weekText.text = NSLocalizedString(@"Sun", nil);
        self.onceText.text = NSLocalizedString(@"Once", nil);
    }
    else{
        self.monText.text = NSLocalizedString(@"Every MON", nil);
        self.tueText.text = NSLocalizedString(@"Every TUE", nil);
        self.wedText.text = NSLocalizedString(@"Every WED", nil);
        self.thurText.text = NSLocalizedString(@"Every THUR", nil);
        self.friText.text = NSLocalizedString(@"Every FRI", nil);
        self.satText.text = NSLocalizedString(@"Every SAT", nil);
        self.weekText.text = NSLocalizedString(@"Every SUN", nil);
        self.onceText.hidden=YES;
        self.OnceBtn.hidden=YES;
    }
    self.monText.font = [UIFont systemFontOfSize:18];
    self.tueText.font = [UIFont systemFontOfSize:18];
    self.wedText.font = [UIFont systemFontOfSize:18];
    self.thurText.font = [UIFont systemFontOfSize:18];
    self.friText.font = [UIFont systemFontOfSize:18];
    self.satText.font = [UIFont systemFontOfSize:18];
    self.weekText.font = [UIFont systemFontOfSize:18];
    self.onceText.font = [UIFont systemFontOfSize:18];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
