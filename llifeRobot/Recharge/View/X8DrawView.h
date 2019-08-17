//
//  X8DrawView.h
//  llifeRobot
//
//  Created by 魏青青 on 2019/5/16.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface X8DrawView : UIView
@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,strong)NSMutableArray *layers;
@property (nonatomic,strong)NSMutableArray *imagesViews;
@property (nonatomic, strong) NSMutableArray *paths;
@property (assign)CGFloat scale;
@property (nonatomic,strong)UIImageView *numberImageView;
@property (nonatomic,strong)NSMutableData *data;
@property (nonatomic,strong)NSString *editStyle;
@property (nonatomic,strong)UIScrollView * scrollView;


/**
 初始化
 
 @param frame 大小
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame;

// 清屏
- (void)clear;

/**
 画虚拟墙线
 
 @param point1 开始坐标
 @param Point2 结束坐标
 */
-(void)createLayerWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)Point2;

//虚拟墙数据的同步
-(void)didWallDataSame:(NSMutableData *)data;



@end

NS_ASSUME_NONNULL_END
