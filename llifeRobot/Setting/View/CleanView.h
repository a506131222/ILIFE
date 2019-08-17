//
//  CleanView.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/1/2.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CleanView : UIView


@property (nonatomic, strong) UIColor *lineColor;


@property (nonatomic, strong) UIColor *gridColor;

@property (nonatomic, assign) CGFloat gridSpace;

@property (nonatomic, assign) CGFloat scaleLevel;


- (void)addMapByPoint:(CGPoint)point Type:(NSInteger)type ColumnSpace:(CGFloat)columnSpace;
-(void)setBeginScale:(CGFloat)beginScale;
@end
