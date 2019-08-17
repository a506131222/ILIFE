//
//  ZJMShareCodeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/8.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMShareCodeVC.h"
#import <CoreImage/CoreImage.h>


@interface ZJMShareCodeVC ()
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet UILabel *bindDeviceLab;
@property (nonatomic,copy)NSString *subDomain;
@property (nonatomic,copy)NSString *shareCode;
@end

@implementation ZJMShareCodeVC


-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    self.subDomain=delegate.subDomain;
    
    [ACBindManager fetchShareCodeWithSubDomain:_subDomain deviceId:_receiveDeviceId timeout:60 * 60 callback:^(NSString *shareCode, NSError *error) {
      
        if (!error) {
            _shareCode = shareCode;
            [self creatFilter];
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.bindDeviceLab.text = NSLocalizedString(@"Scan QR Code To Bind The Robot", nil);
    self.bindDeviceLab.font = [UIFont systemFontOfSize:16];
    // Do any additional setup after loading the view from its nib.
    self.definesPresentationContext = YES;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.window addGestureRecognizer:tapGesture];
   }
-(void)creatFilter{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据
    NSString *dataString = _shareCode;
    
    NSData *data  = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 4.通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    
    // 4.获取输出的二维码
    CIImage *outputImage = filter.outputImage;
    _codeImage.image = [self creatNonInterpolatedUIImageFormCIImage:outputImage withSize:self.view.bounds.size.width*0.7];
   

}
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    //设置比例
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap（位图）;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}

-(void)handletapPressGesture:(UITapGestureRecognizer*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if (sender.view.tag ==3) {
//                [self dismissViewControllerAnimated:YES
//                                         completion:^{
//                                             //一定要移除手势 否则下次 没有子视图的时候 点击 会崩溃拉
//                                             AppDelegate *app = [[UIApplication sharedApplication] delegate];
//                                             [app.window removeGestureRecognizer:sender];
//                                         }];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.window removeGestureRecognizer:sender];
    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//    CGPoint point = [sender. locationInView:self.view];
//    
//    
//    if (point.x<self.view.frame.origin.x || point.x >self.view.frame.origin.x+self.view.frame.size.width) {
//        [self dismissViewControllerAnimated:YES
//                                 completion:^{
//                                     //一定要移除手势 否则下次 没有子视图的时候 点击 会崩溃拉

//                                 }];
//    }
    


/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 *
 *  @return 生成高清的UIImage
 */
- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1. 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
