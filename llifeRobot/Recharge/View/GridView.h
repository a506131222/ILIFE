//
//  GridView.h
//  GridDemo
//
//  Created by Joey on 2017/12/19.
//  Copyright © 2017年 F_jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJMDrawView.h"

@interface GridView : UIView
@property (nonatomic,strong)ZJMDrawView *drawView;//绘制虚拟墙View
@property (assign, nonatomic) CGFloat scale;

@property (nonatomic,assign)NSInteger pointSize;

- (void)clear;

-(instancetype)initWithFrame:(CGRect)frame andSubDomain:(NSString *)subDomain;

/**
 坐标点类型描点

 @param point 坐标点
 @param type  类型:障碍物？已清扫？（备用）
 @param subDomain 产品子域
 */
- (void)addGridByPoint:(CGPoint)point DataType:(NSInteger)type Realtime:(BOOL)realtime SubDomain:(NSString *)subDomain;


@end
