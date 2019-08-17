///  ZJMQRCodeScanningVC.m
//  ZJMQRCodeExample
//
//  Created by kingsic on 17/3/20.
//  Copyright © 2017年 kingsic. All rights reserved.
//


#import "ZJMRCodeAlbumManager.h"
#import "ZJMQRCodeScanningView.h"
#import "ZJMQRCodeHelperTool.h"
#import "ZJMPersonalVC.h"

@interface ZJMQRCodeScanningVC () <ZJMQRCodeScanManagerDelegate, ZJMRCodeAlbumManagerDelegate>
@property (nonatomic, strong) ZJMQRCodeScanManager *manager;
@property (nonatomic, strong) ZJMQRCodeScanningView *scanningView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation ZJMQRCodeScanningVC
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanningView addTimer];
    [_manager resetSampleBufferDelegate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView removeTimer];
    [self removeFlashlightBtn];
    [_manager cancelSampleBufferDelegate];
}

- (void)dealloc {
 
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];

    
    [self.view addSubview:self.scanningView];
    [self setupNavigationBar];
    [self setupQRCodeScanning];
    [self.view addSubview:self.promptLabel];
    
    [self.view addSubview:self.bottomView];
}

- (void)setupNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"Scan QR Code", nil);
    NSLocalizedString(@"", nil);
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Album", nil) style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
    NSLocalizedString(@"", nil);
}

- (ZJMQRCodeScanningView *)scanningView {
    if (!_scanningView) {
        _scanningView = [[ZJMQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanningView;
}
- (void)removeScanningView {
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

//- (void)rightBarButtonItenAction {
//    ZJMQRCodeAlbumManager *manager = [ZJMQRCodeAlbumManager sharedManager];
//    [manager readQRCodeFromAlbumWithCurrentController:self];
//    manager.delegate = self;
//
//    if (manager.isPHAuthorization == YES) {
//        [self.scanningView removeTimer];
//    }
//}

- (void)setupQRCodeScanning {
    self.manager = [ZJMQRCodeScanManager sharedManager];
    NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
   
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
//    [manager cancelSampleBufferDelegate];
    _manager.delegate = self;
}

#pragma mark - - - ZJMQRCodeAlbumManagerDelegate
- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(ZJMQRCodeAlbumManager *)albumManager {
    [self.view addSubview:self.scanningView];
}


#pragma mark - - - ZJMQRCodeScanManagerDelegate
- (void)QRCodeScanManager:(ZJMQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
    AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
    
    [scanManager stopRunning];
    [scanManager videoPreviewLayerRemoveFromSuperlayer];

      [scanManager palySoundName:@"QRCodeSound.mp3"];
    [ACBindManager bindDeviceWithShareCode:obj.stringValue callback:^(ACUserDevice *userDevice, NSError *error) {
        if (!error) {
            [self showHudWithString:NSLocalizedString(@"Binding Done", nil)];

          
        }else{
            [self showHudWithString:NSLocalizedString(@"Binding Failed", nil)];
        }
       
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    
    
       
  
}
- (void)QRCodeScanManager:(ZJMQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue {
    if (brightnessValue < - 1) {
        [self.view addSubview:self.flashlightBtn];
    } else {
        if (self.isSelectedFlashlightBtn == NO) {
            [self removeFlashlightBtn];
        }
    }
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
         _promptLabel.numberOfLines = 0;
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 20;
        CGFloat promptLabelY = 0.70 * self.view.frame.size.height;
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanningView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanningView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnW = 30;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"手电筒"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"手电筒-选中"] forState:(UIControlStateSelected)];

        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [ZJMQRCodeHelperTool SG_openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
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


@end

