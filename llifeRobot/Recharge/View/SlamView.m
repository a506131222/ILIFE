//
//  SlamView.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/5/8.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "SlamView.h"
#import "PreHeader.h"
#import "ZJMDrawView.h"
#import "AppDelegate.h"
#import "PointModel.h"
#import "ZJMRechargeVC.h"


#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)
#define RECTWIDTH 0.1
#define LINEWIDTH 3




@interface SlamView ()<UIGestureRecognizerDelegate>
@property (assign, nonatomic) CGFloat scale;//记录上次手势结束的放大倍数
@property (assign, nonatomic) CGFloat realScale;//当前手势应该放大的倍数
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic,assign) CGContextRef bitmapContext;
@property (nonatomic)CGColorSpaceRef colorSpace;
@property (nonatomic) NSUInteger bytesPerPixel;
@property (nonatomic)NSUInteger bitsPerComponent;
@property (nonatomic)NSUInteger inputBytesPerRow;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic)CGPoint center1;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property (nonatomic)NSInteger lineByteIndex;
@property (nonatomic,strong)UIView *pathView;
@property (nonatomic,strong)NSTimer * timer;


@property (strong,nonatomic)UIImageView *imageView;
@property (strong,nonatomic)NSMutableArray *pathArrM;
@property (nonatomic,strong)CAShapeLayer *pathLayer;
@property (nonatomic,strong)NSMutableArray<CAShapeLayer *> *pathLayers;

@end
@implementation SlamView
{
    CGFloat Tx;
    CGFloat Ty;
    CGImageRef inputCGImage;
    PointModel * point;
    CGContextRef context;
    unsigned char * datadd;
    unsigned char *mapData;
}

-(NSMutableArray<CAShapeLayer *> *)pathLayers{
    if (!_pathLayers) {
        _pathLayers=[NSMutableArray array];
    }
    return _pathLayers;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }    return self;
}

-(void)setUI{
    _scale = 8.0;
    self.backgroundColor = [UIColor clearColor];
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENWEIGHT)];
    _imageView.backgroundColor = [UIColor clearColor];
    CALayer * layer = _imageView.layer;
    layer.magnificationFilter = kCAFilterNearest;
    _imageView.center = self.center;
    _center1 = self.center;
    _pathView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENWEIGHT)];
    _pathView.backgroundColor = [UIColor clearColor];
    _pathView.center = self.center;
    _colorSpace = CGColorSpaceCreateDeviceRGB();
    _bytesPerPixel = 4;
    _bitsPerComponent = 8;
    //每行字节数
    _inputBytesPerRow = _bytesPerPixel * MAPWIDTH;
    [self addSubview:_imageView];
    [self addSubview:_pathView];
    [self setEvent];
}

- (void)setEvent {
    self.transform = CGAffineTransformMakeScale(_scale,_scale);
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    _pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_pan];
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:_pinch];
    
}
- (void)panAction :(UIPanGestureRecognizer *)pan {
    NSLog(@"移动");
    _isPanAction=YES;
    [self didGestureRecognizer];
    UIView *piece = [pan view];
    //注意这个方法获取到的偏移量是相对于开始识别到时候手指的位置并不会实时更新需要再调用setTranslation: inView:
    CGPoint translation = [pan translationInView:[piece superview]];
    piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:[piece superview]];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    NSLog(@"缩放事件");
    _isPanAction = YES;
    [self didGestureRecognizer];
    if (pinch.velocity>0.5) {
        if (self.scale<self.scale+(pinch.scale-1.5)) {
            self.realScale = self.scale +(pinch.scale - 1.5);
        }else{
            self.realScale = self.scale +(pinch.scale - 1);
        }
    }else{
        if (self.scale<self.scale+(pinch.scale-0.85)) {
            self.realScale = self.scale +(pinch.scale - 1);
        }else{
            self.realScale = self.scale +(pinch.scale - 0.85);
        }
    }
    if (self.realScale > 13) {//设置最大放大倍数
        self.realScale = 13;
    }else if (self.realScale <3){//最小放大倍数
        self.realScale = 3;
    }
    for (CAShapeLayer *layer in _pathLayers) {
        layer.lineWidth=1.0/self.realScale;
    }
    self.transform = CGAffineTransformMakeScale(self.realScale, self.realScale);
    self.transform= CGAffineTransformTranslate(self.transform,-Tx,-Ty);
    self.scale = self.realScale;
    [_drawView virlineDidTransformWithScale:_realScale];
    
}

-(void)setScale:(CGFloat)scale withTranslateByX:(CGFloat)X andY:(CGFloat)Y{
    Tx = X;
    Ty = Y;
    self.scale = scale;
    self.center = _center1;
    self.transform = CGAffineTransformMakeScale(self.scale,self.scale);
    self.transform= CGAffineTransformTranslate(self.transform,-X,-Y);
    [_drawView virlineDidTransformWithScale:scale];
    for (CAShapeLayer *layer in _pathLayers) {
        layer.lineWidth=1.0/scale;
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
    self.isPanAction = NO;
    [_timer invalidate];
    _timer = nil;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (![self.type isEqualToString:NSLocalizedString(@"Record Detail", nil)]){
        _pan.state = UIGestureRecognizerStateBegan;
//    }
    
    
}

#pragma mark - 获取slame地图
- (void)modifyAlphaData:(NSData *)data{
    @autoreleasepool {
        mapData = calloc(MAPWIDTH * MAPWIDTH * 4 , sizeof(unsigned char));
        Byte *mapByte = (Byte *)[data bytes];
        NSInteger lenth = MAPWIDTH;
        NSInteger temp=0;
        NSInteger index=0;
        for (int i=0; i<[data length]; i+=3) {
            NSInteger  mapCount=(mapByte[i+1]<<8)+mapByte[i+2];
            NSInteger  count = mapByte[i];
            for (int j=0; j<mapCount; j++) {
                NSUInteger byteIndex = _inputBytesPerRow*(MAPWIDTH-index) + _bytesPerPixel*temp;
                if(mapData!=NULL) {
                    if (count==1) {
                        //障碍物
                        mapData[byteIndex]=57;
                        mapData[byteIndex+1]=171;
                        mapData[byteIndex+2]=167;
                        mapData[byteIndex+3]=255;
                    }else if (count==2){
                        mapData[byteIndex]=87;
                        mapData[byteIndex+1]=214;
                        mapData[byteIndex+2]=210;
                        mapData[byteIndex+3]=255;
                    }
                    
                }
                temp++;
                if (temp>=lenth) {
                    index++;
                    temp=0;
                }
            }
        }
        CGContextRef context =
        CGBitmapContextCreate(mapData,
                              MAPWIDTH,
                              MAPWIDTH,
                              _bitsPerComponent,
                              _inputBytesPerRow,
                              _colorSpace,
                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextDrawImage(context, CGRectMake(0, 0, MAPWIDTH, MAPWIDTH), NULL);
        CGContextSetShouldAntialias(context,YES);
        inputCGImage = CGBitmapContextCreateImage(context);
        self.imageView.image = [UIImage imageWithCGImage:inputCGImage];
        CGImageRelease(inputCGImage);
        CGContextRelease(context);
        if (mapData!=NULL) {
            free(mapData);
        }
        
    }
}

#pragma mark - 清扫路径
-(void)drawLineByPathArr:(NSMutableArray *)pathArr type:(NSInteger)type{
    _pathArrM =[NSMutableArray arrayWithArray:pathArr];
    [self drawLayerWithScale:self.scale Type:type];
}

#pragma mark - 画路径
-(void)drawLayerWithScale:(CGFloat)scale Type:(NSInteger)type{
    _pathLayer=[CAShapeLayer layer];
    UIBezierPath *path=[UIBezierPath bezierPath];
    for (int i = 2; i<_pathArrM.count; i+=2) {
        if (type==1) {
            [self.drawView createArrWithPoint:CGPointMake([_pathArrM[i] integerValue],[_pathArrM[i+1] integerValue])];
        }
        [path moveToPoint:CGPointMake([_pathArrM[i-2] floatValue]*SCREENWEIGHT/MAPWIDTH,(MAPWIDTH-[_pathArrM[i-1] floatValue])*SCREENWEIGHT/MAPWIDTH)];
        [path addLineToPoint:CGPointMake([_pathArrM[i] floatValue]*SCREENWEIGHT/MAPWIDTH, (MAPWIDTH-[_pathArrM[i+1] floatValue])*SCREENWEIGHT/MAPWIDTH)];
        _pathLayer.strokeColor = [UIColor whiteColor].CGColor;
        _pathLayer.fillColor = [UIColor whiteColor].CGColor;
        _pathLayer.path = path.CGPath;
        _pathLayer.lineCap = kCALineJoinRound;
        _pathLayer.lineWidth=1/self.scale;
        [self.pathLayers addObject:_pathLayer];
        [self.pathView.layer addSublayer:_pathLayer];
    }
}

#pragma mark - 清除APP端已显示的地图
-(void)clearMapData{
    _imageView.image = nil;
    inputCGImage = nil;
    for (CAShapeLayer *layer in _pathLayers) {
        [layer removeFromSuperlayer];
    }
    
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
      _pinch.delaysTouchesBegan = YES;
    if (![self.type isEqualToString:NSLocalizedString(@"Record Detail", nil)]){
        if (![_drawView.editModel isEqualToString:@""]){
            _pinch.state = UIGestureRecognizerStateFailed;
            _pan.state = UIGestureRecognizerStateFailed;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
