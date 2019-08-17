//
//  SlamView.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/5/8.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJMDrawView.h"

@interface SlamView : UIView
@property (nonatomic,strong)NSString*type;
@property (atomic,assign)    CGPoint originPoint;
@property (atomic,assign)    CGPoint endPoint;
@property (nonatomic,strong)ZJMDrawView *drawView;


/**
 slam X最大值
 */
@property (nonatomic,assign)CGFloat slam_x_max;

/**
 slam X最小值
 */
@property (nonatomic,assign)CGFloat slam_x_min;

/**
 slam Y最大值
 */
@property (nonatomic,assign)CGFloat slam_y_max;

/**
 slam Y最小值
 */
@property (nonatomic,assign)CGFloat slam_y_min;
@property (nonatomic)BOOL isPanAction;


/**
 *  data转图片
 *  @param data   图片数据
 */
- (void)modifyAlphaData:(NSData *)data;


/**
 清扫路径

 @param pathArr 路径数组
 */
-(void)drawLineByPathArr:(NSMutableArray *)pathArr type:(NSInteger)type;



/**
 清除地图
 */
-(void)clearMapData;


-(instancetype)initWithFrame:(CGRect)frame;

/**
 设置放大比例

 @param scale 比例
 @param X X
 @param Y Y
 */
-(void)setScale:(CGFloat)scale withTranslateByX:(CGFloat)X andY:(CGFloat)Y;

//虚拟墙相关
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic,strong)NSMutableArray *pointArrM;
@end
