//
//  SlamView.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/5/8.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "SlamView.h"
#import "PreHeader.h"
#define Mask8(x) ( (x) & 0xFF)
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@interface SlamView ()
@property (nonatomic)CGImageRef imageRef;
@property (nonatomic,strong)UIImage *iiiimage;
@property (assign,atomic) CGPoint converPoint;

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*pathArr;
@end
@implementation SlamView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self = [[[NSBundle mainBundle]loadNibNamed:@"SlamView"owner:self options:nil] firstObject];
//        [self setDefault];
    }
    return self;
    
}
#pragma mark - 实时添加网格
- (void)addGridByPoint:(CGPoint)point model:(NSInteger)model{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = [self convertLineToFrameByPoint:point];
    if (model==1) {
         layer.backgroundColor = [UIColor grayColor].CGColor;
    }else if (model==2){
        layer.backgroundColor = [UIColor blackColor].CGColor;
    }
//    }else if (model==3){
//         layer.backgroundColor = [UIColor yellowColor].CGColor;
//    }

    [self.layer addSublayer:layer];
    [self.pathArr addObject:layer];
    //    NSLog(@"111---%f,%f",self.circleView.center.x,self.circleView.center.y);
    
}
#pragma mark - 网格坐标
- (CGRect )convertLineToFrameByPoint:(CGPoint )point{
//    NSLog(@"%f  %f",_converPoint.x+self.center.x, _converPoint.y+self.center.y);
    _converPoint = CGPointMake(point.x+SCREENWEIGHT/2, point.y+SCREENHEIGHT/2);
    return CGRectMake(_converPoint.x+self.center.x, _converPoint.y+self.center.y,1,1);
    
    
}

//-(void)drawRect:(CGRect)rect{
//    CGPoint point;
//    CGContextRef contextGef = UIGraphicsGetCurrentContext();
//    for (int i = 0; i < 200; i++) {
//        for (int j = 0; j<300; j++) {
//
//            CGContextAddRect(contextGef, CGRectMake(i, j, 9, 9));
//        }
//    }
//    CGContextSetStrokeColorWithColor(contextGef, [UIColor blueColor].CGColor);
//    CGContextStrokePath(contextGef);
//    CGContextRelease(contextGef);
//
//}
//-(void)setDefault{
//     _imageRef = [_imageVIew.image CGImage];
//}
//-(void)addSlamByModelPoint:(CGPoint)point{
//    CGFloat red=52;
//    CGFloat green=56;
//    CGFloat blue=200;
////    if(model==0){
////        red=65;
////        green=41;
////        blue=215;
////    }else if (model==1){
////        red=0;
////        green=0;
////        blue=0;
////    }else if (model==2){
////        red=52;
////        green=41;
////        blue=100;
////    }
//    _imageRef = _imageVIew.image.CGImage;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    NSUInteger bytesPerPixel = 4;//一个像素四个分量，即ARGB
//    NSUInteger bytesPerRow = bytesPerPixel * SCREENWEIGHT;
//    unsigned char *rawData = (unsigned char *)calloc(SCREENHEIGHT*SCREENWEIGHT*bytesPerPixel, sizeof(unsigned char));
//    NSUInteger bitsPerComponent = 8;//每个分量8个字节
//    CGContextRef context = CGBitmapContextCreate(rawData, SCREENWEIGHT, SCREENHEIGHT, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGContextDrawImage(context, CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT), _imageRef);
//    int len = strlen((char*)rawData);
//    for (int i = 0; i < SCREENHEIGHT; i++) {
//        for (int j = 0; j < SCREENWEIGHT; j++) {
//            NSUInteger byteIndex = bytesPerRow*i + bytesPerPixel*j;
////            if (byteIndex<len) {
////                rawData[byteIndex]=red;
////                rawData[byteIndex+1]=green;
////                rawData[byteIndex+2]=blue;
////            }
//
////            NSLog(@"%d",byteIndex);
//
//
//            if (byteIndex<len) {
//                rawData[byteIndex]=red;
//                rawData[byteIndex+1]=green;
//                rawData[byteIndex+2]=blue;
//            }
//                if (byteIndex<100510)
//                {
//                    rawData[byteIndex]=100;
//                    rawData[byteIndex+1]=200;
//                    rawData[byteIndex+2]=100;
//                }else if (byteIndex<200709 &&byteIndex>100510){
//                    rawData[byteIndex]=54;
//                    rawData[byteIndex+1]=60;
//                    rawData[byteIndex+2]=100;
//                }else{
//                    rawData[byteIndex]=213;
//                    rawData[byteIndex+1]=60;
//                    rawData[byteIndex+2]=100;
//                }
//
//        }
//
//    }
////}
//
//    _imageRef = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:_imageRef];
//    _imageVIew.image=newImage;
//    free(rawData);
//    CGImageRelease(_imageRef);
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//
//
//}


@end
