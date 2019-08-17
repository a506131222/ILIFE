//
//  GridView.m
//  GridDemo
//
//  Created by Joey on 2017/12/19.
//  Copyright © 2017年 F_jiang. All rights reserved.
//

#import "GridView.h"
#import "PreHeader.h"

@interface GridView ()<CALayerDelegate>

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*pathArr;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;

@property (nonatomic, strong) UIRotationGestureRecognizer *rotation;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
/** 列数*/
@property (nonatomic, assign) NSInteger column;
/** 行数*/
@property (nonatomic, assign) NSInteger row;
/** 列高*/
@property (nonatomic, assign) CGFloat columnSpace;
/** 行高*/
@property (nonatomic, assign) CGFloat rowSpace;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) CGFloat realScale;
@property (nonatomic,strong)CAShapeLayer *circleLayer;

@property (nonatomic,strong)UIView *circleView;
@property (assign,atomic) CGPoint converPoint;
@property (assign,nonatomic) NSInteger count;
@end
@implementation GridView

-(UIView *)circleView{
    if (!_circleView) {
        _circleView = [[UIView alloc]init];
        _circleView.frame = CGRectMake(0,0 ,10, 10);
        _circleView.backgroundColor = HexColor(0x64B8FF);
        _circleView.layer.shouldRasterize = YES;
        _circleView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _circleView.layer.cornerRadius = 5;
          [self addSubview:_circleView];
        [_circleView bringSubviewToFront:self];
     
    }
    return _circleView;
}
- (void)setEvent {

     self.scale = 1;
}


//设置默认值
- (void)setDefault {
    _lineColor = HexColor(0xEFEFEF);
    _gridColor = HexColor(0x00BDB5);
    _scaleLevel = 1;
    _count=5;
}

- (instancetype)initWithFrame:(CGRect)frame column:(NSInteger)column row:(NSInteger)row {
    if (self = [super initWithFrame:frame]) {
        [self setDefault];
        [self drawGridByColumn:column row:row];
        [self setEvent];
        
    }
    return self;
}

//画出网格
- (void)drawGridByColumn:(NSInteger)column row:(NSInteger)row {
    _column = column;
    _row = row;
    _columnSpace = self.bounds.size.width / column ;
    _rowSpace = self.bounds.size.height / row;
    CGRect rowFrame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
    CGRect columnFrame = CGRectMake(0, 0, 0.5, self.bounds.size.height);
    for (int i = 0; i < row+1; i++) {
        CAShapeLayer *lay = [CAShapeLayer layer];
        rowFrame.origin.y = i * _rowSpace;
        lay.frame = rowFrame;
        lay.backgroundColor = _lineColor.CGColor;
        [self.layer addSublayer:lay];
    }
    for (int j = 0; j < column; j++) {
        CAShapeLayer *lay = [CAShapeLayer layer];
        columnFrame.origin.x = j * _columnSpace;
        lay.frame = columnFrame;
        lay.backgroundColor = _lineColor.CGColor;
        [self.layer addSublayer:lay];
    }
}

#pragma mark - 实时添加网格
- (void)addGridByPoint:(CGPoint)point {
        CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = [self convertLineToFrameByPoint:point];
        layer.backgroundColor = _gridColor.CGColor;
        [self.layer addSublayer:layer];
        [self.pathArr addObject:layer];
    self.circleView.center = CGPointMake(layer.frame.origin.x, layer.frame.origin.y);
    if (point.x ==-32767 ||point.y==32767) {
            [self clear];
        }
}

#pragma mark - 网格坐标
- (CGRect )convertLineToFrameByPoint:(CGPoint )point {
    
     _converPoint = CGPointMake(point.x * _columnSpace + _columnSpace *(_column / 2/_count ?_column / 2/_count :_column / 2/_count +1), point.y * _rowSpace +  _rowSpace * (_row / 2/_count? _row / 2/_count : _row / 2/_count+1));
    return CGRectMake(_converPoint.x+self.center.x, _converPoint.y+self.center.y, _columnSpace-1, _rowSpace-1);
 
}

- (void)clear {
    for (CAShapeLayer *layer in self.pathArr) {
        [layer removeFromSuperlayer];
    }
    [self.pathArr removeAllObjects];
}


- (NSMutableArray<CAShapeLayer *> *)pathArr {
    if (!_pathArr) {
        _pathArr = [NSMutableArray array];
    }
    return _pathArr;
}



@end
