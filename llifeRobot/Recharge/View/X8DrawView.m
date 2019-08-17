//
//  X8DrawView.m
//  llifeRobot
//
//  Created by 魏青青 on 2019/5/16.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "X8DrawView.h"
#import "PreHeader.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#define  columnwidth  [UIScreen mainScreen].bounds.size.width*5

@interface X8DrawView ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,strong)UIPanGestureRecognizer *pan;
@property (nonatomic,assign)BOOL isPan;

@end
@implementation X8DrawView{
    CGPoint beginPoint;
    Byte wallByte[82];
}
-(NSMutableArray *)imagesViews{
    if (!_imagesViews) {
        _imagesViews=[NSMutableArray array];
    }
    return _imagesViews;
}

-(NSMutableArray *)layers{
    if (!_layers) {
        _layers=[NSMutableArray array];
    }
    return _layers;
}
- (NSMutableArray *)paths
{
    if (_paths == nil) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}



-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.path = [UIBezierPath bezierPath];
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDidAction:)];
        _pan.cancelsTouchesInView = NO;
        _pan.delegate = self;
        [self addGestureRecognizer:_pan];
        self.isPan = NO;
        _count=1;
    }
    
    return self;
}
//平移手势
-(void)panDidAction:(UIPanGestureRecognizer *)pan{
    self.isPan = YES;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            if (wallByte[1]!=10 && [self.editStyle isEqualToString:@"1"]){
                _shapeLayer=[CAShapeLayer layer];
                [self.layers addObject:_shapeLayer];
                [self.paths addObject:_path];
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (wallByte[1]!=10 && [self.editStyle isEqualToString:@"1"]){
                CGPoint curP = [pan locationInView:self];
                [_path removeAllPoints];
                [_path moveToPoint:beginPoint];
                [_path addLineToPoint:curP];
                [self drawVirtalWall];
            }
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:{
             if (wallByte[1]!=10 && [self.editStyle isEqualToString:@"1"]){
                 CGPoint curP = [pan locationInView:self];
                 NSLog(@"结束curP == %@",NSStringFromCGPoint(curP));
                 NSLog(@"结束X == %f",(curP.x-self.center.x-0.5)/2.5);
                 NSLog(@"结束Y == %f",(curP.y-self.center.y-0.5)/2.5);
                 [_path removeAllPoints];
                 [_path moveToPoint:beginPoint];
                 [_path addLineToPoint:curP];
                 // 重绘
                 [self drawVirtalWall];
                 [self addWallData:(beginPoint.x-self.center.x-0.5)/2.5 startPiontY:(beginPoint.y-self.center.y-0.5)/2.5 endPiontX:(curP.x-self.center.x-0.5)/2.5 endPiontY:(curP.y-self.center.y-0.5)/2.5];
                 
             }else  if (wallByte[1] == 10 && ![self.editStyle isEqualToString:@"0"]){
                 [self showHudWithString:NSLocalizedString(@"Up to 10 virtual walls can be set!", nil)];
             }
           
        }
            
            break;
            
        default:
            break;
    }
    
    
}

// 当手指点击view,就需要记录下起始点
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (wallByte[1]!=10 && [self.editStyle isEqualToString:@"1"]){
        // 获取起始点
        beginPoint = [self touchPoint:touches];
        //    NSLog(@"触摸点beginPoint == %@",NSStringFromCGPoint(beginPoint));
        //    NSLog(@"初始X == %f",(beginPoint.x-self.center.x-0.5)/2.5);
        //    NSLog(@"初始Y == %f",(beginPoint.y-self.center.y-0.5)/2.5);
    }else  if (wallByte[1] == 10 && ![self.editStyle isEqualToString:@"0"]){
        [self showHudWithString:NSLocalizedString(@"Up to 10 virtual walls can be set!", nil)];
    }
   

}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (wallByte[1]!=10 && [self.editStyle isEqualToString:@"1"]){
        // 获取当前触摸点
        CGPoint curP = [self touchPoint:touches];
        CGFloat distance = [self getDistanceFromPoint1:beginPoint andPoint2:curP];
        if ( distance<2 || self.isPan == YES) {
            self.isPan = NO;
            return;
        }
        //    NSLog(@"endPoint == %@",NSStringFromCGPoint(curP));
        //    NSLog(@"终点X == %f",(curP.x-self.center.x-0.5)/2.5);
        //    NSLog(@"终点Y == %f",(curP.y-self.center.y-0.5)/2.5);
        _shapeLayer=[CAShapeLayer layer];
        [self.layers addObject:_shapeLayer];
        [_path removeAllPoints];
        [_path moveToPoint:beginPoint];
        [_path addLineToPoint:curP];
        [self.paths addObject:_path];
        [self drawVirtalWall];
      
        [self addWallData:(beginPoint.x-self.center.x-0.5)/2.5 startPiontY:(beginPoint.y-self.center.y-0.5)/2.5 endPiontX:(curP.x-self.center.x-0.5)/2.5 endPiontY:(curP.y-self.center.y-0.5)/2.5];
        
    }
    
   
    
}
#pragma mark - 画虚拟墙
-(void)addWallData :(NSInteger)startPiontX startPiontY:(NSInteger)startPiontY endPiontX:(NSInteger)endPiontX endPiontY:(NSInteger)endPiontY{
    Byte startPiontX_H = [self getByteHFromPoint:startPiontX];
    Byte startPiontX_L = [self getByteLFromPoint:startPiontX];
    Byte startPiontY_H = [self getByteHFromPoint:startPiontY];
    Byte startPiontY_L = [self getByteLFromPoint:startPiontY];
    
    Byte endPiontX_H = [self getByteHFromPoint:endPiontX];
    Byte endPiontX_L = [self getByteLFromPoint:endPiontX];
    Byte endPiontY_H = [self getByteHFromPoint:endPiontY];
    Byte endPiontY_L = [self getByteLFromPoint:endPiontY];
    
    if (wallByte[1] < 10)
    {
        wallByte[wallByte[1]*8 + 2] = startPiontX_H;
        wallByte[wallByte[1]*8 + 3] = startPiontX_L;
        wallByte[wallByte[1]*8 + 4] = startPiontY_H;
        wallByte[wallByte[1]*8 + 5] = startPiontY_L;
        wallByte[wallByte[1]*8 + 6] = endPiontX_H;
        wallByte[wallByte[1]*8 + 7] = endPiontX_L;
        wallByte[wallByte[1]*8 + 8] = endPiontY_H;
        wallByte[wallByte[1]*8 + 9] = endPiontY_L;
        wallByte[1] = wallByte[1] + 1;
        self.data = [NSMutableData dataWithBytes:wallByte length:sizeof(wallByte)];
        NSLog(@"%@",self.data);
        
    }else{
        
    }
}
-(Byte )getByteHFromPoint:(NSInteger)point{
    if (point<0) {
        point = 65536 + point;
    }
    Byte first = (Byte)((point & 0xff00) >> 8);
    return first;
}
-(Byte )getByteLFromPoint:(NSInteger)point{
    if (point<0) {
        point = 65536 + point;
    }
    Byte Second  = (Byte)(point & 0x00ff);
    return Second;
}




#pragma mark - 两点之间的距离
-(CGFloat)getDistanceFromPoint1:(CGPoint)point1 andPoint2:(CGPoint)Point2{
    CGFloat distance = sqrt(pow((point1.x - Point2.x), 2) + pow((point1.y - Point2.y), 2));
    return distance;
}

#pragma mark - 绘制相关
-(void)drawVirtalWall{
    for (UIBezierPath *path in self.paths) {
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.strokeColor = [UIColor redColor].CGColor;
        _shapeLayer.path = path.CGPath;
        _shapeLayer.lineWidth=1.0;
        [self.layer addSublayer:_shapeLayer];
        
    }
}
#pragma mark -创建layer
-(void)createLayerWithPoint1:(CGPoint)point1 andPoint2:(CGPoint)Point2{
    [_path removeAllPoints];
    [_path moveToPoint:point1];
    [_path addLineToPoint:Point2];
    _shapeLayer=[CAShapeLayer layer];
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    _shapeLayer.path = _path.CGPath;
    _shapeLayer.lineWidth=LINEWIDTH/self.scale;
    [self.paths addObject:_path];
    [self.layers addObject:_shapeLayer];
    [self.layer addSublayer:_shapeLayer];
    [self createNumImageViewByPoint:Point2 withType:@"0"];
}

#pragma mark - 添加编号
-(void)createNumImageViewByPoint:(CGPoint)curP withType:(NSString *)type{
    _numberImageView= [[UIImageView alloc]initWithFrame:CGRectMake(curP.x-(NUMBERIMARIWDTH/2), curP.y-CONSTANTS,NUMBERIMARIWDTH,NUMBERIMARIWDTH)];
    _numberImageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%ld",_count++]];
    _numberImageView.userInteractionEnabled = YES;
    [self.imagesViews addObject:_numberImageView];
    [self addSubview:_numberImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numberImageViewDidTap:)];
    [_numberImageView addGestureRecognizer:tap];
    tap.view.tag = self.imagesViews.count;
    _numberImageView.transform=CGAffineTransformMakeScale(1/self.scale,1/self.scale);
    
    
}


#pragma mark - 删除虚拟墙
-(void)numberImageViewDidTap:(UITapGestureRecognizer *)tap{

    if ([self.editStyle isEqualToString:@"0"]) {
        NSInteger tag = tap.view.tag;
        _count = 1;
        [self.layers[tag-1] removeFromSuperlayer];
        [self.paths removeObjectAtIndex:tag-1];
        [self.layers removeObjectAtIndex:tag-1];
        [self.imagesViews[tag-1] removeFromSuperview];
        [self.imagesViews removeObjectAtIndex:tag-1];
        NSMutableData *tempData = [[NSMutableData alloc] initWithData:_data];
        [tempData replaceBytesInRange:NSMakeRange((tag-1)*8 + 2, 8) withBytes:NULL length:0];
        Byte *byte= (Byte *)[tempData bytes];
        for(int i=0;i<82;i++){
            if (i<[tempData length]) {
                wallByte[i]=byte[i];
            }else{
                wallByte[i] = 0;
            }
            
        }
        wallByte[1] = wallByte[1] - 1;
        self.data = [NSMutableData dataWithBytes:wallByte length:sizeof(wallByte)];
        for (_numberImageView in self.imagesViews) {
            for (UIGestureRecognizer * gesture in _numberImageView.gestureRecognizers) {
                if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                    gesture.view.tag = _count;
                }
            }
            _numberImageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%ld",_count++]];
            
        }
    }
}

#pragma mark - 虚拟墙数据的同步
-(void)didWallDataSame:(NSMutableData *)data{
    for(int i=0;i<[data length];i++){
        Byte *byte= (Byte *)[data bytes];
        wallByte[i] = byte[i];
    }
    _data = data;
}
//清屏
- (void)clear
{
    // 清除画板view所有的路径,并且重绘
    if (!self.layers.count) return;
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.paths removeAllObjects];
    [self.layers removeAllObjects];
    [self.imagesViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imagesViews removeAllObjects];
    _count = 1;
    
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
        
    });
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
    }
    else {
        return CGPointMake(-1, -1);
    }
}



@end
