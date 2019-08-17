//
//  RHScanViewController.m
//  RHScan
//
//  Created by river on 2018/2/1.
//  Copyright © 2018年 richinfo. All rights reserved.
//

#import "RHScanViewController.h"
#import "RHScanPermissions.h"
#import "RHScanNative.h"
#import "RHScanView.h"
#import "ZJMQRCodeHelperTool.h"
#import "ZJMQRCodeScanManager.h"

@interface RHScanViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) ZJMQRCodeScanManager *manager;

#pragma mark -----  扫码使用的库对象 -------


@property (nonatomic,strong) RHScanNative* scanObj;


/// 扫码区域视图,二维码一般都是框
@property (nonatomic,strong) RHScanView* qRScanView;


///记录开始的缩放比例
@property(nonatomic,assign)CGFloat beginGestureScale;
@property (nonatomic, strong) UILabel *promptLabel;
///最后的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;

@end

@implementation RHScanViewController

#pragma mark - life

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
     _effectiveScale = 1;
     self.isVideoZoom = YES;
    [self cameraInitOver];
    [self.view addSubview:self.promptLabel];
     [self drawScanView];
    CGFloat flashlightBtnW = 40;
    CGFloat flashlightBtnH = 42;
    CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
    CGFloat flashlightBtnY = 0.48 * self.view.frame.size.height;
    CGRect frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
    _flashlightBtn = [[UIButton alloc] initWithFrame:frame];
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"手电筒"] forState:UIControlStateNormal];
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"手电筒-选中"] forState:UIControlStateSelected];
    [_flashlightBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashlightBtn];
    self.isOpenInterestRect = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    [RHScanPermissions requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            //不延时，可能会导致界面黑屏并卡住一会
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.1];

        }else{
            [_qRScanView stopDeviceReadying];
            [self showError:NSLocalizedString(@"Allow \"ILIFE Robot\" to Access Camera", nil) withReset:NO];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopScan];
    [_qRScanView stopScanAnimation];
      [self removeFlashlightBtn];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)setupQRCodeScanning {
//    self.manager = [ZJMQRCodeScanManager sharedManager];
//    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code];
//
////    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
//    //    [manager cancelSampleBufferDelegate];
//    _manager.delegate = self;
//}

//绘制扫描区域
- (void)drawScanView
{
    if (!_qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        if (_style == nil) {
            _style = [RHScanViewStyle new];
        }
        self.qRScanView = [[RHScanView alloc]initWithFrame:rect style:_style];
        
        [self.view addSubview:_qRScanView];

    }
    [_qRScanView startDeviceReadyingWithText:_cameraInvokeMsg];
    
}

#pragma mark 增加拉近/远视频界面
- (void)cameraInitOver
{
    if (self.isVideoZoom) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
        pinch.delegate = self;
        [self.view addGestureRecognizer:pinch];
    }
}
//- (void)QRCodeScanManager:(ZJMQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue {
//    if (brightnessValue < - 1) {
//        [self.view addSubview:self.flashlightBtn];
//    } else {
//        if (self.isSelectedFlashlightBtn == NO) {
//            [self removeFlashlightBtn];
//        }
//    }
//}

- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser
{
    self.effectiveScale = self.beginGestureScale * recogniser.scale;
    if (self.effectiveScale < 1.0){
        self.effectiveScale =1.0 ;
    }
    [self.scanObj setVideoScale:self.effectiveScale];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)reStartDevice
{
     [_scanObj startScan];
}

//启动设备
- (void)startScan
{
    if ( ![RHScanPermissions cameraPemission] )
    {
        [_qRScanView stopDeviceReadying];
        [self showError:NSLocalizedString(@"Allow \"ILIFE Robot\" to Access Camera", nil) withReset:NO];
        return;
    }
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    if (!_scanObj )
    {
        CGRect cropRect = CGRectZero;
        
        if (_isOpenInterestRect) {
            
            //设置只识别框内区域
            cropRect = [RHScanView getScanRectWithPreView:self.view style:_style];
        }
        //AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
        self.scanObj = [[RHScanNative alloc]initWithPreView:videoView ObjectType:nil cropRect:cropRect success:^(NSArray<NSString *> *array) {
            
            [weakSelf scanResultWithArray:array];
        }];
        
        [_scanObj setNeedCaptureImage:NO];
        [_scanObj setNeedAutoVideoZoom:YES];
    }
    [_scanObj startScan];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)stopScan
{
    [_scanObj stopScan];
}

#pragma mark - 扫码结果处理

- (void)scanResultWithArray:(NSArray<NSString*>*)array
{
  
    NSString *scanResult = array[0];
    if (self.type==1) {
//        self.lineCode = scanResult;
//        ZJMIIDCodeVC *idCodeVC= [[ZJMIIDCodeVC alloc]init];
//        idCodeVC.title = NSLocalizedString(@"AP Networking Mode", nil);
//        if (self.backLineCode) {
//            self.backLineCode(scanResult);
//        };
//        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [ACBindManager bindDeviceWithShareCode:scanResult callback:^(ACUserDevice *userDevice, NSError *error) {
            if (!error) {
                [self showHudWithString:NSLocalizedString(@"Binding Done", nil)];
                
            }else{
                [self showHudWithString:NSLocalizedString(@"Binding Failed", nil)];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.numberOfLines = 0;
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 20;
        CGFloat promptLabelY = 0.60 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width*0.9;
        CGFloat promptLabelH = 50;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = NSLocalizedString(@"Put the QR Code/Bar Code Into Frame to Scan", nil);
        
        
    }
    return _promptLabel;
}
#pragma mark - 
- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [ZJMQRCodeHelperTool SG_openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
         [ZJMQRCodeHelperTool SG_CloseFlashlight];
        button.selected = NO;

    }
}

- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZJMQRCodeHelperTool SG_CloseFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn removeFromSuperview];
    });
}

#pragma mark - 提示语
- (void)showError:(NSString*)str withReset:(BOOL)isRest
{
    if (str==nil || [str isEqualToString:@""]) {
        str =NSLocalizedString(@"扫码失败，请重新扫一扫", nil);
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:str preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self startScan];
        NSLog(@"重新扫一扫");
        
        [self.qRScanView stopDeviceReadying];
        
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

@end

