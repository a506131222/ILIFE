//
//  ZJMDrawView.m
//  llifeRobot
//
//  Created by 魏青青 on 2018/12/5.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMDrawView.h"
#import "AppDelegate.h"
#import "PreHeader.h"
#import "MBProgressHUD.h"
#import "ZJMDrawView.h"
#import "SlamView.h"

#define LINEDASHWIDTH 4.0

@interface ZJMDrawView ()
@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,strong)NSMutableArray <CAShapeLayer *>*layers;
@property (nonatomic,strong)NSMutableArray <UIImageView *>*imagesViews;
@property (nonatomic,strong)NSMutableArray <UIImageView *>*moveImageViews;
@property (nonatomic,strong)NSMutableArray <UIImageView *> *rotationImageViews;
@property (nonatomic, strong)NSMutableArray <UIBezierPath *>*paths;
@property (nonatomic,strong)NSMutableArray *lastPointArray;
@property (nonatomic,strong)UIImageView *numberImageView;


@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic,assign)NSInteger selectCount;
@property (nonatomic,assign)BOOL Selected;
@property (nonatomic,assign) CGPoint lastCtrlPoint; //上一次的控制点
@property (nonatomic,assign) NSInteger nextStep;
@property (nonatomic,strong)CAShapeLayer *robotLayer;
@property (nonatomic,strong)UIPanGestureRecognizer *pan;
@property (nonatomic,strong)UIPinchGestureRecognizer *pinch;


@end

@implementation ZJMDrawView{
    CGPoint beginPoint;
    MBProgressHUD *mbpHud;
    Byte mapByte[254];
}

-(NSMutableArray<UIImageView *> *)imagesViews{
    if (!_imagesViews) {
        _imagesViews=[NSMutableArray array];
    }
    return _imagesViews;
}
-(NSMutableArray<UIImageView *>*)moveImageViews{
    if (!_moveImageViews) {
        _moveImageViews = [NSMutableArray array];
    }
    return _moveImageViews;
}
-(NSMutableArray<UIImageView *>*)rotationImageViews{
    if (!_rotationImageViews) {
        _rotationImageViews = [NSMutableArray array];
    }
    return _rotationImageViews;
}

-(NSMutableArray<CAShapeLayer *> *)layers{
    if (!_layers) {
        _layers=[NSMutableArray array];
    }
    return _layers;
}
- (NSMutableArray<UIBezierPath *> *)paths
{
    if (_paths == nil) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
- (NSMutableArray *)lastPointArray
{
    if (_lastPointArray == nil) {
        _lastPointArray = [NSMutableArray array];
    }
    return _lastPointArray;
}
-(NSMutableArray *)containArr{
    if (!_containArr) {
        _containArr = [NSMutableArray array];
    }
    return _containArr;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.editModel = @"";
        _robotLayer = [CAShapeLayer layer];
        _robotLayer.backgroundColor = HexColor(0xFEF60D).CGColor;
        [self.layer addSublayer:_robotLayer];
        self.userInteractionEnabled = NO;
        _scale = 8.0;
        _nextStep = 0;
    }
    
    return self;
}

#pragma mark -  当手指点击view,就需要记录下起始点
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _Selected = NO;
    _nextStep = 0;
    beginPoint = [self touchPoint:touches];
    NSLog(@"开始点 == %@",NSStringFromCGPoint(beginPoint));
//    NSLog(@"对应的初X == %f",(beginPoint.x*(1500/self.bounds.size.width)));
//    NSLog(@"对应的初Y == %f",(beginPoint.y*(1500/self.bounds.size.height)));
    if (self.paths.count>0){
        _nextStep = [self imageViewsContainsPoint:beginPoint];
        if (_nextStep != 0) {
            [self clearGestureRecognizerEffect:YES];
            if (_nextStep==2) {
                self.lastCtrlPoint = [self convertPoint:self.rotationImageViews[_selectCount].center toView:self];
            }
            return;
        }else{
            _Selected = [self virlineSelectenByPoint:beginPoint];
            if (_Selected == YES) {
                [self clearGestureRecognizerEffect:YES];
                return;
            }
        }
    }
    if (!CGPointEqualToPoint(beginPoint, CGPointMake(-1, -1))) {
        if ([self.editModel isEqualToString:@"1"]) {
            if (mapByte[1] < 10) {
                _shapeLayer=[CAShapeLayer layer];
                _path = [UIBezierPath bezierPath];
            }else{
                [self showHudWithString:NSLocalizedString(@"10 electronic walls can be set up at most!", nil)];
            }
        }else if ([self.editModel isEqualToString:@"0"]){
            if (mapByte[83] < 10) {
                _shapeLayer=[CAShapeLayer layer];
                _path = [UIBezierPath bezierPath];
            }else{
                [self showHudWithString:NSLocalizedString(@"10 forbidden Area can be set up at most!", nil)];
            }
        }
    }
    
}
#pragma mark - 触摸移动
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint curP = [self touchPoint:touches];
    NSLog(@"触摸移动");
    //    NSLog(@"移动的点 == %@",NSStringFromCGPoint(curP));
    if (self.paths.count>0 && (_nextStep != 0 || _Selected == YES) ) {
        if (_nextStep == 1) {
            [self virlineDidTransformWithBeginPoint:[self touchPreviousPoint:touches] andEndPoint:curP andType:@"0"];
        }else if (_nextStep == 2){
            [self rotateCtrlWithEndPoint:curP andType:@"0"];
        }else{
            [self virlineDidMoveWidthBeginPoint:[self touchPreviousPoint:touches] andEndPoint:curP andType:@"0"];
        }
    }else if (!CGPointEqualToPoint(beginPoint, CGPointMake(-1, -1))){
        if ([self.editModel isEqualToString:@"1"]) {
            if (mapByte[1] < 10) {
                [self drawVirtalWallWidthCurPoint:curP andEditModel:@"1"];
            }
        }else if ([self.editModel isEqualToString:@"0"]){
            if (mapByte[83] < 10) {
                [self drawVirtalWallWidthCurPoint:curP andEditModel:@"0"];
            }
        }
    }
}
#pragma mark - 触摸结束
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint curP = [self touchPoint:touches];
    NSLog(@"结束点 == %@",NSStringFromCGPoint(curP));
//    NSLog(@"对应的末X == %f",curP.x*(1500.0/self.bounds.size.width));
//    NSLog(@"对应的末Y == %f",((curP.y)*(1500.0/self.bounds.size.height)));
    if (self.paths.count>0 && (_nextStep != 0 || _Selected == YES)) {
        if (_nextStep == 1) {
            [self virlineDidTransformWithBeginPoint:[self touchPreviousPoint:touches] andEndPoint:curP andType:@"1"];
        }else if (_nextStep == 2){
            [self rotateCtrlWithEndPoint:curP andType:@"1"];
        }else{
            [self virlineDidMoveWidthBeginPoint:[self touchPreviousPoint:touches] andEndPoint:curP andType:@"1"];
        }
    }else if (!CGPointEqualToPoint(beginPoint, CGPointMake(-1, -1))){
        if ([self.editModel isEqualToString:@"1"]) {
            if (mapByte[1] < 10) {
                CGFloat distance = [self getDistanceFromPoint1:[self getBitMapPointFromPoint:beginPoint] andPoint2:[self getBitMapPointFromPoint:curP]];;
                if ( distance<5 ) {
                    [_path removeAllPoints];
                    _shapeLayer.path = _path.CGPath;
                    [_shapeLayer displayIfNeeded];
                    return;
                }
                [self drawVirtalWallWidthCurPoint:curP andEditModel:@"1"];
                [self.layers addObject:_shapeLayer];
                [self.paths addObject:_path];
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:beginPoint] andPoint1:[self getBitMapPointFromPoint:curP] andPoint2:CGPointZero andEndPoint:CGPointZero andType:1];
                [self createNumImageViewByPoint1:beginPoint andPoint2:curP andPoint3:CGPointZero andPoint4:CGPointZero angType:1 fromRobot:NO];
                [self.containArr addObject:@([self containsRobotPositionByNum:self.layers.count-1])];
            }
        }else if ([self.editModel isEqualToString:@"0"]){
            if (mapByte[83] < 10) {
                CGFloat distance1 = [self getDistanceFromPoint1:[self getBitMapPointFromPoint:beginPoint] andPoint2:[self getBitMapPointFromPoint:CGPointMake(curP.x, beginPoint.y)]] ;
                CGFloat distance2 =[self getDistanceFromPoint1:[self getBitMapPointFromPoint:CGPointMake(curP.x, beginPoint.y)] andPoint2:[self getBitMapPointFromPoint:curP]];
                if (distance1 < 5 || distance2 <5) {
                    [_path removeAllPoints];
                    _shapeLayer.path = _path.CGPath;
                    [_shapeLayer displayIfNeeded];
                    return;
                }
                [self drawVirtalWallWidthCurPoint:curP andEditModel:@"0"];
                [self.layers addObject:_shapeLayer];
                [self.paths addObject:_path];
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:beginPoint] andPoint1:[self getBitMapPointFromPoint:CGPointMake(curP.x, beginPoint.y)] andPoint2:[self getBitMapPointFromPoint:curP] andEndPoint:[self getBitMapPointFromPoint:CGPointMake(beginPoint.x, curP.y)] andType:0];
                [self createNumImageViewByPoint1:beginPoint andPoint2:CGPointMake(curP.x, beginPoint.y) andPoint3:curP andPoint4:CGPointMake(beginPoint.x, curP.y) angType:0  fromRobot:NO];
                [self.containArr addObject:@([self containsRobotPositionByNum:self.layers.count-1])];
            }
        }else{
            [self clearGestureRecognizerEffect:NO];
        }
    }
}
#pragma mark - 修改虚拟墙、禁区数据
-(void)addWallDataOrFbdDataWithStartPoint:(CGPoint)startPoint andPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andEndPoint:(CGPoint)endPoint andType:(NSInteger)type{
    Byte startPiontX_H = [self getByteHFromPoint:startPoint.x];
    Byte startPiontX_L = [self getByteLFromPoint:startPoint.x];
    Byte startPiontY_H = [self getByteHFromPoint:startPoint.y];
    Byte startPiontY_L = [self getByteLFromPoint:startPoint.y];
    
    Byte point1X_H = [self getByteHFromPoint:point1.x];
    Byte point1X_L = [self getByteLFromPoint:point1.x];
    Byte point1Y_H = [self getByteHFromPoint:point1.y];
    Byte point1Y_L = [self getByteLFromPoint:point1.y];
    if (type == 1) {
        if (_nextStep==0 && _Selected == NO) {
            mapByte[mapByte[1]*8 + 2] = startPiontX_H;
            mapByte[mapByte[1]*8 + 3] = startPiontX_L;
            mapByte[mapByte[1]*8 + 4] = startPiontY_H;
            mapByte[mapByte[1]*8 + 5] = startPiontY_L;
            mapByte[mapByte[1]*8 + 6] = point1X_H;
            mapByte[mapByte[1]*8 + 7] = point1X_L;
            mapByte[mapByte[1]*8 + 8] = point1Y_H;
            mapByte[mapByte[1]*8 + 9] = point1Y_L;
            mapByte[1] = mapByte[1] + 1;
            _mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
            NSLog(@"虚拟墙数据%@",_mapData);
            return;
        }
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 2] = startPiontX_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 3] = startPiontX_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 4] = startPiontY_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 5] = startPiontY_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 6] = point1X_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 7] = point1X_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 8] = point1Y_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*8 + 9] = point1Y_L;
        _mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
        NSLog(@"虚拟墙数据的修改 == %@",_mapData);
    }else{
        Byte point2X_H = [self getByteHFromPoint:point2.x];
        Byte point2X_L = [self getByteLFromPoint:point2.x];
        Byte point2Y_H = [self getByteHFromPoint:point2.y];
        Byte point2Y_L = [self getByteLFromPoint:point2.y];
        
        Byte endPiontX_H = [self getByteHFromPoint:endPoint.x];
        Byte endPiontX_L = [self getByteLFromPoint:endPoint.x];
        Byte endPiontY_H = [self getByteHFromPoint:endPoint.y];
        Byte endPiontY_L = [self getByteLFromPoint:endPoint.y];
        if (_nextStep==0 && _Selected == NO) {
            mapByte[mapByte[83]*17 + 84] = 4;
            mapByte[mapByte[83]*17 + 85] = startPiontX_H;
            mapByte[mapByte[83]*17 + 86] = startPiontX_L;
            mapByte[mapByte[83]*17 + 87] = startPiontY_H;
            mapByte[mapByte[83]*17 + 88] = startPiontY_L ;
            mapByte[mapByte[83]*17 + 89] = point1X_H;
            mapByte[mapByte[83]*17 + 90] = point1X_L;
            mapByte[mapByte[83]*17 + 91] = point1Y_H;
            mapByte[mapByte[83]*17 + 92] = point1Y_L;
            mapByte[mapByte[83]*17 + 93] = point2X_H;
            mapByte[mapByte[83]*17 + 94] = point2X_L;
            mapByte[mapByte[83]*17 + 95] = point2Y_H;
            mapByte[mapByte[83]*17 + 96] = point2Y_L;
            mapByte[mapByte[83]*17 + 97] = endPiontX_H ;
            mapByte[mapByte[83]*17 + 98] = endPiontX_L;
            mapByte[mapByte[83]*17 + 99] = endPiontY_H;
            mapByte[mapByte[83]*17 + 100] = endPiontY_L;
            mapByte[83] = mapByte[83] + 1;
            self.mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
            NSLog(@"禁区数据%@",self.mapData);
            return;
        }
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 85] = startPiontX_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 86] = startPiontX_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 87] = startPiontY_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 88] = startPiontY_L ;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 89] = point1X_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 90] = point1X_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 91] = point1Y_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 92] = point1Y_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 93] = point2X_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 94] = point2X_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 95] = point2Y_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 96] = point2Y_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 97] = endPiontX_H ;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 98] = endPiontX_L;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 99] = endPiontY_H;
        mapByte[(_moveImageViews[_selectCount].tag-1)*17 + 100] = endPiontY_L;
        self.mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
        NSLog(@"禁区数据的修改 == %@",_mapData);
    }
}

-(Byte )getByteHFromPoint:(NSInteger)point{
    NSInteger temp;
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
        temp = point-MAPWIDTH/2;
    }else{
        temp = point;
    }
    if ((temp)<0) {
        temp = 65536 + temp;
    }
    Byte first = (Byte)((temp & 0xff00) >> 8);
    return first;
}
-(Byte )getByteLFromPoint:(NSInteger)point{
    NSInteger temp;
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
        temp = point-MAPWIDTH/2;
    }else{
        temp = point;
    }
    if ((temp)<0) {
        temp = 65536 + temp;
    }
    Byte Second  = (Byte)(temp & 0x00ff);
    return Second;
}

- (void)showHudWithString:(NSString *)string{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:dele.window];
        [dele.window addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = string;
        hud.labelFont = [UIFont fontWithName:@"PingFangSC-Light" size:15];
        [hud show:YES];
        [hud hide:YES afterDelay:0.8];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
        });
        
    });}


#pragma mark - 绘制虚拟墙、禁区
-(void)drawVirtalWallWidthCurPoint:(CGPoint)curP andEditModel:(NSString *)editModel{
    [_path removeAllPoints];
    if ([self.editModel isEqualToString:@"0"]) {
        _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _shapeLayer.fillColor = [UIColor colorWithRed:240.0/255.0 green:147.0/255.0 blue:159.0/255.0 alpha:0.6].CGColor;
        _path = [UIBezierPath bezierPathWithRect:CGRectMake(beginPoint.x, beginPoint.y,curP.x-beginPoint.x, curP.y-beginPoint.y) ];
        _shapeLayer.path = _path.CGPath;
        _shapeLayer.lineCap = @"square";
        _shapeLayer.lineWidth=FORBiDDENWIDTH/self.scale;
        _shapeLayer.lineDashPattern = @[@(LINEDASHWIDTH/_scale),@(LINEDASHWIDTH/_scale)];
        [self.layer addSublayer:_shapeLayer];
    }else{
        [_path moveToPoint:beginPoint];
        [_path addLineToPoint:curP];
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.path = _path.CGPath;
        _shapeLayer.lineWidth=LINEWIDTH/self.scale;
        [self.layer addSublayer:_shapeLayer];
    }
}
#pragma mark -获取主机上的虚拟墙、禁区
-(void)createLayerWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andPoint4:(CGPoint)point4 andType:(NSInteger)type{
    if (type == 1) {
        _path = [UIBezierPath bezierPath];
        [_path removeAllPoints];
        [_path moveToPoint:point1];
        [_path addLineToPoint:point2];
        _shapeLayer=[CAShapeLayer layer];
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.path = _path.CGPath;
        _shapeLayer.lineWidth=LINEWIDTH/self.scale;
    }else{
        _path = [UIBezierPath bezierPath];
        [_path removeAllPoints];
        [_path moveToPoint:point1];
        [_path addLineToPoint:point2];
        [_path addLineToPoint:point3];
        [_path addLineToPoint:point4];
        [_path closePath];
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _shapeLayer.fillColor = [UIColor colorWithRed:240.0/255.0 green:147.0/255.0 blue:159.0/255.0 alpha:0.6].CGColor;
        _shapeLayer.path = _path.CGPath;
        _shapeLayer.lineCap = @"square";
        _shapeLayer.lineWidth=FORBiDDENWIDTH/self.scale;
        _shapeLayer.lineDashPattern = @[@(LINEDASHWIDTH/_scale),@(LINEDASHWIDTH/_scale)];
    }
    [self.paths addObject:_path];
    [self.layers addObject:_shapeLayer];
    [self.layer addSublayer:_shapeLayer];
    [self.containArr addObject:@(0)];
    [self createNumImageViewByPoint1:point1 andPoint2:point2 andPoint3:point3 andPoint4:point4 angType:type  fromRobot:YES];
    
}

#pragma mark - 添加编号、移动图标、旋转图标
-(void)createNumImageViewByPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andPoint4:(CGPoint)point4 angType:(NSInteger)type fromRobot:(BOOL)isYes {
    [self.lastPointArray addObject:NSStringFromCGPoint(point4)];
    _numberImageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,NUMBERIMARIWDTH/self.scale,NUMBERIMARIWDTH/self.scale)];
    _numberImageView.center = point1;
    _numberImageView.image = [UIImage imageNamed:@"image_btn_remove"];
    _numberImageView.userInteractionEnabled = YES;
    [self.imagesViews addObject:_numberImageView];
    [self addSubview:_numberImageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberImageViewDidTap:)];
    [_numberImageView addGestureRecognizer:tap];
    tap.view.tag = self.imagesViews.count;
    if (type == 0) {
        _numberImageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,NUMBERIMARIWDTH/self.scale,NUMBERIMARIWDTH/self.scale)];
        _numberImageView.center = point2;
        _numberImageView.image = [UIImage imageNamed:@"image_btn_rotate"];
        [self.rotationImageViews addObject:_numberImageView];
        [self addSubview:_numberImageView];
        
        _numberImageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,NUMBERIMARIWDTH/self.scale,NUMBERIMARIWDTH/self.scale)];
        _numberImageView.center = point3;
        _numberImageView.image = [UIImage imageNamed:@"image_btn_resize"];
        [self.moveImageViews addObject:_numberImageView];
        [self addSubview:_numberImageView];
        if (isYes) {
            _numberImageView.tag = _fbdCount++;
        }else{
            _numberImageView.tag = mapByte[83];
        }
    }else{
        _numberImageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,NUMBERIMARIWDTH/self.scale,NUMBERIMARIWDTH/self.scale)];
        _numberImageView.center = point2;
        _numberImageView.image = [UIImage imageNamed:@"image_btn_resize"];
        [self.moveImageViews addObject:_numberImageView];
        [self addSubview:_numberImageView];
        if (isYes) {
            _numberImageView.tag = _vtlCount++;
        }else{
            _numberImageView.tag = mapByte[1];
        }
        [self.rotationImageViews addObject:[[UIImageView alloc]initWithFrame:CGRectZero] ];
        
    }
}
#pragma mark - 点击手势删除
-(void)numberImageViewDidTap:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    NSInteger index = self.moveImageViews[tag-1].tag;
    NSInteger kind;
    if (self.layers[tag-1].lineDashPattern.count == 0) {
        kind = 1;
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:_mapData];
        [tempData replaceBytesInRange:NSMakeRange((index-1)*8 + 2, 8) withBytes:NULL length:0];
        Byte *byte= (Byte *)[tempData bytes];
        for(int i=0;i<82;i++){
            if (i<74) {
                mapByte[i] = byte[i];
            }else{
                mapByte[i]=0;
            }
        }
        mapByte[1] = mapByte[1] - 1;
        _mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
    }else{
        kind = 2;
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:_mapData];
        [tempData replaceBytesInRange:NSMakeRange((index-1)*17 + 84, 17) withBytes:NULL length:17];
        Byte * byte = (Byte *)[tempData bytes];
        for(int i=82;i<254;i++){
            if (i<237) {
                mapByte[i]=byte[i];
            }else{
                mapByte[i]=0;
            }
            
        }
        mapByte[83] = mapByte[83] - 1;
        _mapData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
    }
    [self.paths removeObjectAtIndex:tag-1];
    [self.layers[tag-1] removeFromSuperlayer];
    [self.layers removeObjectAtIndex:tag-1];
    [self.imagesViews[tag-1] removeFromSuperview];
    [self.imagesViews removeObjectAtIndex:tag-1];
    [self.moveImageViews[tag-1] removeFromSuperview];
    [self.moveImageViews removeObjectAtIndex:tag-1];
    [self.rotationImageViews[tag-1] removeFromSuperview];
    [self.rotationImageViews removeObjectAtIndex:tag-1];
    [self.lastPointArray removeObjectAtIndex:tag-1];
    [self.containArr removeObjectAtIndex:tag-1];
    
    for (int i = 0; i < self.imagesViews.count; i++) {
        _numberImageView = self.moveImageViews[i];
        NSInteger num = _numberImageView.tag;
        if (i >= (tag-1)) {
            if (kind == 1) {
                if (self.layers[i].lineDashPattern.count == 0) {
                    _numberImageView.tag = num-1;
                }
            }else if (kind == 2){
                if (self.layers[i].lineDashPattern.count>0) {
                    _numberImageView.tag = num-1;
                }
            }
        }
        _numberImageView = self.imagesViews[i];
        for (UIGestureRecognizer * gesture in _numberImageView.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                gesture.view.tag = i+1;
                
            }
        }
        
        
    }
}
#pragma mark - 虚拟墙的宽度随着放缩系数的变化而变化
-(void)virlineDidTransformWithScale:(CGFloat)scale{
    self.scale = scale;
    for (CAShapeLayer *layer in self.layers) {
        if (layer.lineDashPattern.count>0) {
            layer.lineDashPattern = @[@(LINEDASHWIDTH/scale),@(LINEDASHWIDTH/scale)];
        }else{
            layer.lineWidth=LINEWIDTH/scale;
        }
    }
    for (int i = 0; i < self.imagesViews.count; i++) {
        UIImageView * imageView = self.imagesViews[i];
        CGPoint center = imageView.center;
        imageView.mj_w = NUMBERIMARIWDTH/scale;
        imageView.mj_h = NUMBERIMARIWDTH/scale;
        UIImageView * moveImageView = self.moveImageViews[i];
        CGPoint center1 = moveImageView.center;
        moveImageView.mj_w = NUMBERIMARIWDTH/scale;
        moveImageView.mj_h = NUMBERIMARIWDTH/scale;
        imageView.center = center;
        moveImageView.center = center1;
        if (self.layers[i].lineDashPattern.count!=0) {
            UIImageView * rotImageView = self.rotationImageViews[i];
            CGPoint center2 = rotImageView.center;
            rotImageView.mj_w = NUMBERIMARIWDTH/scale;
            rotImageView.mj_h = NUMBERIMARIWDTH/scale;
            rotImageView.center = center2;
        }
    }
    
}

#pragma mark - 虚拟墙、禁区数据的同步
-(void)didWallOrFbdAreaDataSame:(NSMutableData *)data{
    Byte *byte= (Byte *)[data bytes];
    for(int i=0;i<[data length];i++){
        mapByte[i] = byte[i];
    }
    _mapData = data;
}

#pragma mark - 判断触摸点是否移动图标上
-(NSInteger)imageViewsContainsPoint:(CGPoint)point{
    for (int i = 0; i<_moveImageViews.count; i++) {
        UIImageView * moveImageView = _moveImageViews[i];
        if (CGRectContainsPoint(moveImageView.frame, point)) {
            _selectCount = i;
            beginPoint = self.imagesViews[i].center;
            NSLog(@"要移动的虚拟墙编号 == %d",i);
            return 1;
        }
        
    }
    for (int i = 0; i<_rotationImageViews.count; i++) {
        UIImageView * rotationImageView = _rotationImageViews[i];
        if (CGRectContainsPoint(rotationImageView.frame, point)) {
            _selectCount = i;
            NSLog(@"要旋转的禁区编号 == %d",i);
            return 2;
        }
        
    }
    return  0;
}


#pragma mark - 判断触摸点在那条虚拟墙上
-(BOOL)virlineSelectenByPoint:(CGPoint)point{
    if (!CGPointEqualToPoint(point, CGPointMake(-1, -1))) {
        CGFloat minDistance = 10.0/self.scale;
        for (int i = 0; i < self.paths.count; i++){
            if (_layers[i].lineDashPattern.count>0) {
                if ([self.paths[i] containsPoint:point]) {
                    _selectCount = i;
                    return YES;
                }
            }else{
                UIBezierPath * path = self.paths[i];
                CGPoint beginPoint = self.imagesViews[i].center;
                CGFloat A = path.currentPoint.y -  beginPoint.y;
                CGFloat B = beginPoint.x - path.currentPoint.x;
                CGFloat C = path.currentPoint.x*beginPoint.y - beginPoint.x*path.currentPoint.y;
                CGFloat dis = fabs((A * point.x + B * point.y + C) / sqrt(pow(A, 2) + pow(B, 2)));
                
                if (dis<minDistance && !isnan(dis)) {
                    //进一步判断，投影点是否在线段上，根据公式求出投影点的X坐标jiaoX
                    CGFloat D = (A * point.y - B * point.x);
                    CGFloat jiaoX = -(A * C + B *D) / (pow(B, 2) + pow(A, 2));
                    CGFloat jiaoY = (A*D-B*C)/ (pow(B, 2) + pow(A, 2));
                    if (path.currentPoint.x == beginPoint.x) {
                         //判断jiaoX是否在线段上，t如果在0~1之间说明在线段上，大于1则说明不在线段且靠近端点p1，小于0则不在线段上且靠近端点p0
                        CGFloat t = (jiaoY - beginPoint.y) / (path.currentPoint.y - beginPoint.y);
                        if (t > 1) {
                            dis = [self getDistanceFromPoint1:path.currentPoint andPoint2:point];
                        }else if (t < 0){
                            dis = [self getDistanceFromPoint1:beginPoint andPoint2:point];
                        }
                    }else{
                        CGFloat t = (jiaoX - beginPoint.x) / (path.currentPoint.x - beginPoint.x);
                        if (t > 1) {
                            dis = [self getDistanceFromPoint1:path.currentPoint andPoint2:point];
                        }else if (t < 0){
                            dis = [self getDistanceFromPoint1:beginPoint andPoint2:point];
                        }
                    }
                    //再次判断真正的最小距离是否小于允许值，小于则该点在直线上，反之则不在
                    if (dis <= minDistance) {
                        minDistance = dis;
                        _selectCount = i;
                        NSLog(@"选中的虚拟墙编号 == %d",i);
                         return YES;
                    }
                }
            }
        }
    }
    return NO;
}
#pragma mark - 虚拟墙、禁区的移动
-(void)virlineDidMoveWidthBeginPoint:(CGPoint)point andEndPoint:(CGPoint)endPoint andType:(NSString *)type{
    _path = self.paths[_selectCount];
    [_path applyTransform:CGAffineTransformTranslate(self.transform,endPoint.x-point.x, endPoint.y-point.y)];
    _shapeLayer = _layers[_selectCount];
    _shapeLayer.path = _path.CGPath;
    [_shapeLayer displayIfNeeded];
    UIImageView * numImageView = self.imagesViews[_selectCount];
    UIImageView * moveImageView = self.moveImageViews[_selectCount];
    numImageView.center = CGPointApplyAffineTransform(numImageView.center, CGAffineTransformTranslate(self.transform, (endPoint.x-point.x), (endPoint.y-point.y)));
    moveImageView.center = CGPointApplyAffineTransform(moveImageView.center, CGAffineTransformTranslate(self.transform, (endPoint.x-point.x), (endPoint.y-point.y)));
    if (_layers[_selectCount].lineDashPattern.count>0) {
        self.rotationImageViews[_selectCount].center = CGPointApplyAffineTransform(self.rotationImageViews[_selectCount].center, CGAffineTransformTranslate(self.transform, endPoint.x-point.x, endPoint.y-point.y));
        self.lastPointArray[_selectCount] = NSStringFromCGPoint(CGPointApplyAffineTransform(CGPointFromString(self.lastPointArray[_selectCount]), CGAffineTransformTranslate(self.transform, endPoint.x-point.x, endPoint.y - point.y)));
        if ([type isEqualToString:@"1"]) {
            NSInteger isContain = [self containsRobotPositionByNum:_selectCount];
            [self.containArr replaceObjectAtIndex:_selectCount withObject:@(isContain)];
            if (isContain == 0) {
                //更改禁区数据
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:numImageView.center] andPoint1:[self getBitMapPointFromPoint:self.rotationImageViews[_selectCount].center] andPoint2:[self getBitMapPointFromPoint:moveImageView.center] andEndPoint:[self getBitMapPointFromPoint:CGPointFromString(_lastPointArray[_selectCount])] andType:0];
                
            }
        }
    }else{
        CGPoint beginPoint = numImageView.center;
        if ([type isEqualToString:@"1"]) {
             NSInteger isContain = [self containsRobotPositionByNum:_selectCount];
            [self.containArr replaceObjectAtIndex:_selectCount withObject:@(isContain)];
            if (isContain == 0) {
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:beginPoint] andPoint1:[self getBitMapPointFromPoint:_path.currentPoint] andPoint2:CGPointZero andEndPoint:CGPointZero andType:1];
            }
            
        }
    }
    
}
#pragma mark - 虚拟墙、禁区的拉伸
-(void)virlineDidTransformWithBeginPoint:(CGPoint)point andEndPoint:(CGPoint)endPoint andType:(NSString *)type{
    _path = self.paths[self.selectCount];
    [_path removeAllPoints];
    if (self.layers[_selectCount].lineDashPattern.count>0) {
        CGPoint point1 = [self obtainPointOfProjectionFromPoint1:self.imagesViews[_selectCount].center andPoint2:self.rotationImageViews[_selectCount].center andPoint3:endPoint];
        CGPoint lastPoint = [self obtainPointOfProjectionFromPoint1:self.imagesViews[_selectCount].center andPoint2:CGPointFromString(self.lastPointArray[_selectCount]) andPoint3:endPoint];
        [_path moveToPoint:self.imagesViews[_selectCount].center];
        [_path addLineToPoint:point1];
        [_path addLineToPoint:endPoint];
        [_path addLineToPoint:lastPoint];
        [_path closePath];
        CGFloat distance1 = [self getDistanceFromPoint1:[self getBitMapPointFromPoint:self.imagesViews[_selectCount].center] andPoint2:[self getBitMapPointFromPoint:point1]];
        CGFloat distance2 = [self getDistanceFromPoint1:[self getBitMapPointFromPoint:point1] andPoint2:[self getBitMapPointFromPoint:endPoint]];
        if ( distance1< 5 || distance2<5 ) {
            return;
        }
        self.paths[self.selectCount] = _path;
        _shapeLayer = self.layers[_selectCount];
        _shapeLayer.path = _path.CGPath;
        [_shapeLayer displayIfNeeded];
        self.moveImageViews[_selectCount].center = endPoint;
        self.rotationImageViews[_selectCount].center = point1;
        _lastPointArray[_selectCount] = NSStringFromCGPoint(lastPoint);
        if ([type isEqualToString:@"1"]) {
            NSInteger isContain = [self containsRobotPositionByNum:_selectCount];
            [self.containArr replaceObjectAtIndex:_selectCount withObject:@(isContain)];
            if (isContain == 0) {
                //更新禁区数据
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:_imagesViews[_selectCount].center] andPoint1:[self getBitMapPointFromPoint:point1] andPoint2:[self getBitMapPointFromPoint:endPoint] andEndPoint:[self getBitMapPointFromPoint:lastPoint] andType:0];
            }
            
        }
    }else{
        if ([self getDistanceFromPoint1:[self getBitMapPointFromPoint:beginPoint] andPoint2:[self getBitMapPointFromPoint:endPoint]] < 5 ) {
            return;
        }
        [_path moveToPoint:beginPoint];
        [_path addLineToPoint:endPoint];
        _shapeLayer = self.layers[_selectCount];
        _shapeLayer.path = _path.CGPath;
        [_shapeLayer displayIfNeeded];
        UIImageView * moveImageView = self.moveImageViews[_selectCount];
        moveImageView.center = endPoint;
        
        if ([type isEqualToString:@"1"]) {
            NSInteger isContain = [self containsRobotPositionByNum:_selectCount];
            [self.containArr replaceObjectAtIndex:_selectCount withObject:@(isContain)];
            if (isContain==0) {
                [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:beginPoint] andPoint1:[self getBitMapPointFromPoint:_path.currentPoint] andPoint2:CGPointZero andEndPoint:CGPointZero andType:1];
            }
            
        }
    }
    
}
#pragma mark - 禁区的旋转
-(void)rotateCtrlWithEndPoint:(CGPoint)endPoint andType:(NSString *)type{
    CGPoint ctrlPoint = endPoint;
    _path = self.paths[_selectCount];
    CGRect rect = CGPathGetBoundingBox(_path.CGPath);
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    //把路径的起始点偏移到路径的中心点
    [_path applyTransform:CGAffineTransformTranslate(self.transform, center.x-rect.origin.x, center.y-rect.origin.y)];
    self.imagesViews[_selectCount].center = CGPointApplyAffineTransform(self.imagesViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-rect.origin.x, center.y-rect.origin.y));
    self.moveImageViews[_selectCount].center = CGPointApplyAffineTransform(self.moveImageViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-rect.origin.x, center.y-rect.origin.y));
    self.rotationImageViews[_selectCount].center = CGPointApplyAffineTransform(self.rotationImageViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-rect.origin.x, center.y-rect.origin.y));
    self.lastPointArray[_selectCount] = NSStringFromCGPoint(CGPointApplyAffineTransform(CGPointFromString(self.lastPointArray[_selectCount]), CGAffineTransformTranslate(self.transform, center.x-rect.origin.x, center.y-rect.origin.y)));
    float angle = atan2(center.y - ctrlPoint.y, ctrlPoint.x - center.x);
    float lastAngle = atan2(center.y - self.lastCtrlPoint.y, self.lastCtrlPoint.x - center.x);
    angle =  -angle + lastAngle;
    [_path applyTransform: CGAffineTransformRotate(self.transform, angle)];
    self.imagesViews[_selectCount].center = CGPointApplyAffineTransform(self.imagesViews[_selectCount].center, CGAffineTransformRotate(self.transform, angle));
    self.moveImageViews[_selectCount].center = CGPointApplyAffineTransform(self.moveImageViews[_selectCount].center, CGAffineTransformRotate(self.transform, angle));
    self.rotationImageViews[_selectCount].center = CGPointApplyAffineTransform(self.rotationImageViews[_selectCount].center, CGAffineTransformRotate(self.transform, angle));
    self.lastPointArray[_selectCount] = NSStringFromCGPoint(CGPointApplyAffineTransform(CGPointFromString(self.lastPointArray[_selectCount]), CGAffineTransformRotate(self.transform, angle)));
    CGRect rect1 = CGPathGetBoundingBox(_path.CGPath);
    CGPoint center1 = CGPointMake(CGRectGetMidX(rect1), CGRectGetMidY(rect1));
    [_path applyTransform:CGAffineTransformTranslate(self.transform, center.x-center1.x, center.y-center1.y)];
    self.imagesViews[_selectCount].center = CGPointApplyAffineTransform(self.imagesViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-center1.x, center.y-center1.y));
    self.moveImageViews[_selectCount].center = CGPointApplyAffineTransform(self.moveImageViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-center1.x, center.y-center1.y));
    self.rotationImageViews[_selectCount].center = CGPointApplyAffineTransform(self.rotationImageViews[_selectCount].center, CGAffineTransformTranslate(self.transform, center.x-center1.x, center.y-center1.y));
    self.lastPointArray[_selectCount] = NSStringFromCGPoint(CGPointApplyAffineTransform(CGPointFromString(self.lastPointArray[_selectCount]), CGAffineTransformTranslate(self.transform, center.x-center1.x, center.y-center1.y)));
    _shapeLayer = self.layers[_selectCount];
    _shapeLayer.path = _path.CGPath;
    [_shapeLayer displayIfNeeded];
    self.lastCtrlPoint = ctrlPoint;
    if ([type isEqualToString:@"1"]) {
        NSInteger isContain = [self containsRobotPositionByNum:_selectCount];
        [self.containArr replaceObjectAtIndex:_selectCount withObject:@(isContain)];
        if (isContain == 0) {
            //更新禁区数据
            [self addWallDataOrFbdDataWithStartPoint:[self getBitMapPointFromPoint:_imagesViews[_selectCount].center] andPoint1:[self getBitMapPointFromPoint:_rotationImageViews[_selectCount].center] andPoint2:[self getBitMapPointFromPoint:_moveImageViews[_selectCount].center] andEndPoint:[self getBitMapPointFromPoint:CGPointFromString(_lastPointArray[_selectCount])] andType:0];
        }
    }
}


#pragma mark - 返回点到某条直线的投影点
-(CGPoint)obtainPointOfProjectionFromPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3{
    CGFloat A = point2.y -  point1.y;
    CGFloat B = point1.x - point2.x;
    CGFloat C = point2.x*point1.y - point1.x*point2.y;
    CGFloat D = (A * point3.y - B * point3.x);
    CGFloat jiaoX = -(A * C + B *D) / (pow(B, 2) + pow(A, 2));
    CGFloat jiaoY = (A*D-B*C)/ (pow(B, 2) + pow(A, 2));
    
    return CGPointMake(jiaoX, jiaoY);
}

#pragma mark - 判断禁区、虚拟墙是否与主机、充电座位置相交
-(NSInteger)containsRobotPositionByNum:(NSInteger)num{
    if (self.layers[num].lineDashPattern.count>0) {
        if ([self.paths[num] containsPoint:[self getPointFromBitMapPoint:_robotPoint]]) {
            [self showHudWithString:NSLocalizedString(@"The forbidden area contains the location of the robot, please adjust the position of the forbodden area", nil)];
            return 1;
        }else{
            CGPoint point1 = [self getBitMapPointFromPoint:_imagesViews[num].center];
            CGPoint point2 = [self getBitMapPointFromPoint:_rotationImageViews[num].center];
            CGPoint point3 = [self getBitMapPointFromPoint:_moveImageViews[num].center];
            CGPoint point4 = [self getBitMapPointFromPoint:CGPointFromString(_lastPointArray[num])];
            
            if ([self getMinDisWithPoint1:point1 withPoint2:point2 andPoint3:_robotPoint andNumOfPath:num]<=10) {
                [self showHudWithString:NSLocalizedString(@"The forbidden area contains the location of the robot, please adjust the position of the forbodden area", nil)];
                return 1;
            }else if ([self getMinDisWithPoint1:point2 withPoint2:point3 andPoint3:_robotPoint andNumOfPath:num]<=10){
                [self showHudWithString:NSLocalizedString(@"The forbidden area contains the location of the robot, please adjust the position of the forbodden area", nil)];
                return 1;
            }else if ([self getMinDisWithPoint1:point3 withPoint2:point4 andPoint3:_robotPoint andNumOfPath:num]<=10){
                [self showHudWithString:NSLocalizedString(@"The forbidden area contains the location of the robot, please adjust the position of the forbodden area", nil)];
                return 1;
            }else if ([self getMinDisWithPoint1:point4 withPoint2:point1 andPoint3:_robotPoint andNumOfPath:num]<=10){
                [self showHudWithString:NSLocalizedString(@"The forbidden area contains the location of the robot, please adjust the position of the forbodden area", nil)];
                return 1;
            }
            
        }
    }else{
        CGFloat dist = [self getMinDisWithPoint1:[self getBitMapPointFromPoint:self.imagesViews[num].center] withPoint2:[self getBitMapPointFromPoint:self.paths[num].currentPoint] andPoint3:_robotPoint andNumOfPath:num];
        if (dist <= 10 ) {
            [self showHudWithString:NSLocalizedString(@"The electronic wall is too close to the robot, please readjust", nil)];
            return 1;
        }
    }
    return 0;
}
#pragma mark - 绘制机器所在位置
-(void)createArrWithPoint:(CGPoint)position{
    self.robotPoint = position;
    _robotLayer.frame = CGRectMake(position.x*SCREENWEIGHT/MAPWIDTH-5/_scale,(MAPWIDTH- position.y)*SCREENWEIGHT/MAPWIDTH, 10/_scale, 10/_scale);
    _robotLayer.cornerRadius = _robotLayer.frame.size.width/2;
}
#pragma mark - X800、X900--手机屏幕上的坐标转换为实际位图上的坐标
-(CGPoint)getBitMapPointFromPoint:(CGPoint)point{
    if ([self.subDomain isEqualToString:X800SubDomain]) {
        return CGPointMake((int)((point.x-self.frame.size.width/2)/PointSize), (int)((point.y-self.frame.size.height/2)/PointSize));
    }else{
        return CGPointMake((int)(point.x*MAPWIDTH/self.bounds.size.width), (int)(MAPWIDTH - (point.y*MAPWIDTH/self.bounds.size.height)));
    }
}
#pragma mark - X800、X900---实际位图上的坐标转换成手机屏幕上的坐标
-(CGPoint)getPointFromBitMapPoint:(CGPoint)point{
    if ([self.subDomain isEqualToString:X800SubDomain]) {
        return CGPointMake(point.x*PointSize+self.frame.size.width/2, point.y*PointSize+self.frame.size.height/2);
    }else{
        return CGPointMake(point.x*self.bounds.size.width/MAPWIDTH, (MAPWIDTH - point.y)* self.bounds.size.height/MAPWIDTH);
    }
}

#pragma mark - 是否取消手势
-(void)clearGestureRecognizerEffect:(BOOL)clear{
    if (clear) {
        _pan.state = UIGestureRecognizerStateFailed;
    }else{
        _pan.state = UIGestureRecognizerStateBegan;
    }
    
    
}
#pragma mark - 求两点的距离
-(CGFloat)getDistanceFromPoint1:(CGPoint)point1 andPoint2:(CGPoint)Point2{
    CGFloat distance = sqrt(pow((point1.x - Point2.x), 2) + pow((point1.y - Point2.y), 2));
    NSLog(@"两点之间的距离 == %f",distance);
    if (isnan(distance) || isinf(distance)) {
        distance = 0.0;
    }
    return distance;
}

#pragma mark - 点到线的最短距离
-(CGFloat)getMinDisWithPoint1:(CGPoint)point1 withPoint2:(CGPoint)point2 andPoint3:(CGPoint)point3 andNumOfPath:(NSInteger)num{
    CGFloat A = point2.y -point1.y;
    CGFloat B = point1.x - point2.x;
    CGFloat C = point2.x*point1.y - point1.x * point2.y;
    CGFloat dis = fabs((A * point3.x + B * point3.y + C) / sqrt(pow(A, 2) + pow(B, 2)));
    
    if (dis<=10 && !isnan(dis)) {
        //进一步判断，投影点是否在线段上，根据公式求出投影点的X坐标jiaoX
        CGFloat D = (A * point3.y - B * point3.x);
        CGFloat jiaoX = -(A * C + B *D) / (pow(B, 2) + pow(A, 2));
        CGFloat jiaoY = (A*D-B*C)/ (pow(B, 2) + pow(A, 2));
        if (point2.x == point1.x) {
            CGFloat t = (jiaoY - point1.y) / (point2.y - point1.y);
            if (t > 1) {
                dis = [self getDistanceFromPoint1:point2 andPoint2:point3];
            }else if (t < 0){
                dis = [self getDistanceFromPoint1:point1 andPoint2:point3];
            }
        }else{
            CGFloat t = (jiaoX - point1.x) / (point2.x - point1.x);
            if (t > 1) {
                dis = [self getDistanceFromPoint1:point2 andPoint2:point3];
            }else if (t < 0){
                dis = [self getDistanceFromPoint1:point1 andPoint2:point3];
            }
        }
    }
    return dis;
}


#pragma mark - 清除禁区或者虚拟墙
- (void)clear
{
    // 清除画板view所有的路径,并且重绘
    if (!self.layers.count) return;
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.paths removeAllObjects];
    [self.layers removeAllObjects];
    [self.imagesViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imagesViews removeAllObjects];
    [self.moveImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.moveImageViews removeAllObjects];
    [self.rotationImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.rotationImageViews removeAllObjects];
    [self.lastPointArray removeAllObjects];
    [self.containArr removeAllObjects];
    self.editModel = @"";
    
    
}
#pragma mark - 删除、拉伸、旋转按钮的隐藏
-(void)hiddenByStatus:(NSInteger)status{
    if (!self.layers.count) return;
    if (status == 7) {
        for (int i = 0; i < self.imagesViews.count; i++) {
            self.imagesViews[i].hidden = NO;
            self.moveImageViews[i].hidden = NO;
            self.rotationImageViews[i].hidden = NO;
        }
    }else{
        for (int i = 0; i < self.imagesViews.count; i++) {
            self.imagesViews[i].hidden = YES;
            self.moveImageViews[i].hidden = YES;
            self.rotationImageViews[i].hidden = YES;
        }
    }
}

- (CGPoint)touchPreviousPoint:(NSSet<UITouch *> *)touches
{
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    if (validTouch) {
        return [validTouch previousLocationInView:self];
    }
    else {
        return CGPointMake(-1, -1);
    }
}

- (CGPoint)touchPoint:(NSSet<UITouch *> *)touches
{
    UITouch *validTouch = nil;
    for (UITouch *touch in touches) {
        if ([touch.view isEqual:self]) {
            validTouch = touch;
            break;
        }
    }
    
    if (validTouch) {
        return [validTouch locationInView:self];
    }else {
        return CGPointMake(-1, -1);
    }
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!_pinch || !_pan) {
        if ( [self.superview isKindOfClass:[SlamView class]]) {
            for (UIGestureRecognizer * ges in self.superview.gestureRecognizers) {
                if ([ges isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    _pinch = (UIPinchGestureRecognizer *)ges;
                }else if ([ges isKindOfClass:[UIPanGestureRecognizer class]]){
                    _pan = (UIPanGestureRecognizer *)ges;
                }
            }
        }
    }
    if (_paths.count>0 && self.userInteractionEnabled == YES) {
        _pinch.delaysTouchesBegan = NO;
    }
    return [super hitTest:point withEvent:event];
}
#pragma mark - NSData转字符串
-(NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}


@end
