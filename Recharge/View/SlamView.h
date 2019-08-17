//
//  SlamView.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/5/8.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlamView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageVIew;


- (void)addGridByPoint:(CGPoint)point model:(NSInteger)model;

@end
