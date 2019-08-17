//
//  GridView.h
//  GridDemo
//
//  Created by Joey on 2017/12/19.
//  Copyright © 2017年 F_jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView


@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign, readonly) NSInteger scaleLevel;

@property (nonatomic, strong) UIColor *gridColor;


- (void)clear;

@property (nonatomic,strong) UIView *view;

- (instancetype )initWithFrame:(CGRect)frame column:(NSInteger )column row:(NSInteger )row;

- (void)addGridByPoint:(CGPoint )point;


@end
