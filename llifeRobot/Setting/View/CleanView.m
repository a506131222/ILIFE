//
//  CleanView.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/1/2.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "CleanView.h"
#import "PreHeader.h"

@interface CleanView ()
/** 列高*/
@property (nonatomic, assign) CGFloat columnSpace;
/** 行高*/
@property (nonatomic, assign) CGFloat rowSpace;
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*pathArr;

@property (nonatomic,strong)UIPinchGestureRecognizer *pinch;

@property (assign, nonatomic) CGFloat scale;//记录上次手势结束的放大倍数
@property (assign, nonatomic) CGFloat realScale;//当前手势应该放大的倍数
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@end
@implementation CleanView



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setDefault];
        [self setEvent];
    }
    return self;
}
- (void)setDefault {
    _columnSpace=2;
    _rowSpace=2;
    self.scaleLevel = 4;
    _gridColor = HexColor(0x00BDB5);
    
}


- (NSMutableArray<CAShapeLayer *> *)pathArr {
    if (!_pathArr) {
        _pathArr = [NSMutableArray array];
    }
    return _pathArr;
}

-(void)setBeginScale:(CGFloat)beginScale{
    if (beginScale<1.0) {
        self.transform = CGAffineTransformMakeScale(beginScale, beginScale);
        self.scale = beginScale;
    }
}

- (void)setEvent {
    //放缩
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:_pinch];
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:_pan];
    //拖动手势
    self.realScale = 1;
    
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
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
        self.transform = CGAffineTransformScale(self.transform, pinch.scale, pinch.scale);
        pinch.scale = 1;
        self.realScale *=scale;
    }
}
- (void)panAction :(UIPanGestureRecognizer *)pan {
    
    UIView *piece = [pan view];
    if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:[piece superview]];
        piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
        [pan setTranslation:CGPointZero inView:[piece superview]];
    }
    
}

#pragma mark - X790实时添加网格
- (void)addMapByPoint:(CGPoint)point Type:(NSInteger)type ColumnSpace:(CGFloat)columnSpace  {
    CAShapeLayer *layer = [CAShapeLayer layer];
    NSLog(@"%f %f",self.center.y,self.bounds.size.height/2);
    layer.frame = CGRectMake(point.x * columnSpace+self.center.x , point.y * columnSpace+self.center.y, columnSpace-(columnSpace*0.1),  columnSpace-columnSpace*0.1);
    layer.drawsAsynchronously=YES;
    layer.allowsEdgeAntialiasing =YES;
    layer.opaque=YES;
    [self.pathArr addObject:layer];
    
    if (type==0) {
        _gridColor = HexColor(0xffffff);
    }
    else if (type==1) {
        _gridColor = HexColor(0x9F5948);
        layer.backgroundColor = _gridColor.CGColor;
        
    }else if (type==2){
        _gridColor = HexColor(0x00BDB5);
        layer.backgroundColor = _gridColor.CGColor;
        
    }
    
    [self.layer addSublayer:layer];
    [self.pathArr addObject:layer];
    
    if (point.x ==-32767 ||point.y==32767) {
        [self clear];
    }
}


- (void)clear {
    for (CAShapeLayer *layer in self.pathArr) {
        [layer removeFromSuperlayer];
    }
    [self.pathArr removeAllObjects];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */



@end
