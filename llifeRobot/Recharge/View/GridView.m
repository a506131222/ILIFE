//
//  GridView.m
//  GridDemo
//
//  Created by Joey on 2017/12/19.
//  Copyright © 2017年 F_jiang. All rights reserved.
//



#define CircleWidth 8


#import "GridView.h"
#import "PreHeader.h"

@interface GridView ()<CALayerDelegate>

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*pathArr;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;


@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (assign, nonatomic) CGFloat realScale;
@property (assign,atomic) CGPoint converPoint;
@property (nonatomic,strong)CALayer *circleLayer;
@property (nonatomic)CGPoint currentPoint;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic)BOOL isGestureRecognizer;
@property (nonatomic)BOOL isEntry;
@property (assign,atomic) CGPoint blockPoint;
@property (assign,atomic) CGPoint cleanPoint;
@property (nonatomic,strong) UIView *mapView;
@property (nonatomic,strong)NSString *subDomain;

@end
@implementation GridView
{
    NSInteger count;
}
-(CALayer *)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.masksToBounds=YES;
        _circleLayer.cornerRadius=4;
        _circleLayer.backgroundColor = HexColor(0xFFD700).CGColor;
        [self.layer addSublayer:_circleLayer];
        
    }
    return _circleLayer;
}
-(instancetype)initWithFrame:(CGRect)frame andSubDomain:(NSString *)subDomain{
    if (self = [super initWithFrame:frame]) {
        [self setDefault];
        if ([subDomain isEqualToString:X800SubDomain]) {
            _mapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gridViewWidth, gridViewHegith)];
            _mapView.backgroundColor = [UIColor clearColor];
            self.subDomain = subDomain;
            [self addSubview:_mapView];
        }

    }
    return self;
}
//设置默认值
- (void)setDefault {
    count=1;
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:_pinch];
    //拖动手势
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_pan];
    _realScale=1.0;
    _isGestureRecognizer=YES;
    
}

#pragma mark - 手势事件
- (void)panAction :(UIPanGestureRecognizer *)pan {
    _isGestureRecognizer=YES;
    [self didGestureRecognizer];
    CGPoint point = [pan translationInView:self];
    NSLog(@"%f",_realScale);
    pan.view.center = CGPointMake(pan.view.center.x + point.x , pan.view.center.y + point.y );
    _currentPoint = CGPointMake(_currentPoint.x + point.x /_realScale, _currentPoint.y + point.y  /_realScale);
    [pan setTranslation:CGPointMake(0, 0) inView:self];
    
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    _isGestureRecognizer=YES;
    [self didGestureRecognizer];
    CGFloat scale = pinch.scale;
    if (pinch.state == UIGestureRecognizerStateBegan || pinch.state == UIGestureRecognizerStateChanged) {
        if(scale > 1.0){
            if(self.realScale > 3.0)
                return;
        }
        if (scale < 1.0) {
            if (self.realScale < 0.5)
                return;
        }
        self.superview.transform = CGAffineTransformScale(self.superview.transform, pinch.scale, pinch.scale);
        pinch.scale = 1;
        self.realScale *=scale;
    }
    if (_drawView) {
        [_drawView virlineDidTransformWithScale:_realScale];
    }
}


#pragma mark - 手势30秒后重新自动缩放
-(void)didGestureRecognizer{
    if (_timer.isValid){
        [_timer invalidate];
    }
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(restartZooming) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}
-(void)restartZooming{
    _isGestureRecognizer=NO;
    [_timer invalidate];
    _timer = nil;
}
#pragma mark - 实时添加网格
- (void)addGridByPoint:(CGPoint)point DataType:(NSInteger)type Realtime:(BOOL)realtime SubDomain:(NSString *)subDomain{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.allowsEdgeAntialiasing=YES;
    UIColor *gridColor= HexColor(0x00BDB5);
    layer.frame = [self convertLineToFrameByPoint:point];
    if ([subDomain isEqualToString:X790SubDomain]) {
        if (realtime==YES) {
            if (type==0) {
                self.circleLayer.frame= [self convertCircleToFrameByPoint:point];
                self.circleLayer.cornerRadius = self.circleLayer.frame.size.width/2;
                self.circleLayer.masksToBounds=YES;
                if (point.x!=32767||point.y!=32767) {
                    if (_isGestureRecognizer==NO) {
                        _isGestureRecognizer=YES;
                        //                        回到原来状态
                        self.center = CGPointMake(self.center.x - self.currentPoint.x, self.center.y - self.currentPoint.y);
                        self.currentPoint = CGPointZero;
                        self.superview.transform=CGAffineTransformMakeScale(1, 1);
                    }else{
                        if (fabs(point.x)>=(self.superview.frame.size.width/2/PointSize *count-(CircleWidth/2))||(fabs(point.y)>=(self.superview.frame.size.height/2/PointSize*count-(CircleWidth/2)))) {
                            //                            自动偏移
                            NSLog(@"%@",NSStringFromCGPoint(self.center));
                            if (_isEntry==YES&&count==1) {
                                self.center=CGPointMake((-point.x*PointSize)+self.center.x, (-point.y*PointSize)+self.center.y) ;
                                count++;
                                
                            }else if (_isEntry==NO){
                                self.center=CGPointMake((-point.x*PointSize*count)+self.center.x, (-point.y*PointSize*count)+self.center.y) ;
                                count++;
                            }
                        }
                    }
                }
            } else if (type==1) {
                gridColor = HexColor(0x9F5948);
            }else if (type==2){
                gridColor = HexColor(0x00BDB5);
                
            }else if (type==6){
                gridColor = [UIColor clearColor];
            }else if (type==4){
                [self clear];
            }
        }else{
            if (type==1) {
                gridColor = HexColor(0x9F5948);
                
            }else if (type==2){
                gridColor = HexColor(0x00BDB5);
                
            }else if (type==6){
                gridColor = [UIColor clearColor];
                
            }else if (type==4){
                [self clear];
            }
        }
        
        if (realtime==YES) {
            _isEntry=YES;
        }
        
    }else{
        self.circleLayer.frame = [self convertCircleToFrameByPoint:point];
        self.circleLayer.cornerRadius = self.circleLayer.frame.size.width/2;
        self.circleLayer.masksToBounds=YES;
        
    }
    layer.backgroundColor = gridColor.CGColor;
    [self.pathArr addObject:layer];
    if ([self.subDomain isEqualToString:X800SubDomain]) {
        [_mapView.layer addSublayer:layer];
        [_mapView.layer insertSublayer:self.circleLayer above:layer];
    }else{
        [self.layer addSublayer:layer];
        [self.layer insertSublayer:self.circleLayer above:layer];
    }
    
    
    if (point.x ==-32767 ||point.y==32767) {
        [self clear];
    }
}




#pragma mark - 地图坐标点
- (CGRect )convertLineToFrameByPoint:(CGPoint )point {
    _converPoint = CGPointMake(point.x * PointSize +self.bounds.size.width/2, point.y *PointSize +self.bounds.size.height/2);
    return CGRectMake(_converPoint.x, _converPoint.y,PointSize-PointSize*0.1,PointSize-PointSize*0.1);
    
}

#pragma mark - 当前点清扫
- (CGRect )convertCircleToFrameByPoint:(CGPoint )point {
    _converPoint = CGPointMake(point.x *PointSize + self.bounds.size.width/2, point.y * PointSize + self.bounds.size.height/2);
    return CGRectMake(_converPoint.x, _converPoint.y,CircleWidth/_realScale,CircleWidth/_realScale);
    
}
- (void)clear {
    for (CAShapeLayer *layer in self.pathArr) {
        [layer removeFromSuperlayer];
    }
    [self.pathArr removeAllObjects];
    self.circleLayer.frame = CGRectZero;
}


- (NSMutableArray<CAShapeLayer *> *)pathArr {
    if (!_pathArr) {
        _pathArr = [NSMutableArray array];
    }
    return _pathArr;
}


@end
