//
//  ZJMDrawView.h
//  llifeRobot
//
//  Created by 魏青青 on 2018/12/5.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJMDrawView : UIView
@property (nonatomic,copy)NSString *subDomain;
@property (assign)CGFloat scale;
@property (nonatomic,strong)NSMutableArray *containArr;
@property (nonatomic,strong)NSMutableData *mapData;//禁区虚拟墙总数据
@property (nonatomic,strong)NSString *editModel;
@property (nonatomic,assign)CGPoint robotPoint;//主机坐标位置
@property (nonatomic,assign)CGPoint chargPoint;//充电座坐标
@property (nonatomic,assign)NSInteger vtlCount;
@property (nonatomic,assign)NSInteger fbdCount;

//清屏
- (void)clear;

//功能图标的隐藏
-(void)hiddenByStatus:(NSInteger)status;

/**
 初始化

 @param frame 大小
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame;



/**
 画虚拟墙、禁区
 */
-(void)createLayerWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andPoint4:(CGPoint)point4 andType:(NSInteger)type;

//虚拟墙、禁区数据的同步
-(void)didWallOrFbdAreaDataSame:(NSMutableData *)data;


-(void)virlineDidTransformWithScale:(CGFloat)scale;

/**
主机位置

 @param position 主机位置
 */
-(void)createArrWithPoint:(CGPoint)position;


@end

NS_ASSUME_NONNULL_END
