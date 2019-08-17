//
//  ZJMUpgrading.m
//  llifeRobot
//
//  Created by 张佳满 on 2019/3/29.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMUpgradingVC.h"
#import "ZJMSettingVC.h"
#import "ACOTAManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ZJMMyDeviceVC.h"

@interface ZJMUpgradingVC ()

#define PROGRESS_LINE_WIDTH 4 //弧线的宽度


@property (weak, nonatomic) IBOutlet UILabel *updatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *comfirmBtn;
@property(nonatomic,strong)CAShapeLayer *backgroundLayer;
@property (nonatomic,strong)CAShapeLayer *progressLayer;
@property(nonatomic,assign)NSInteger progress;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIView *installView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *installIndicatorView;
@property (nonatomic,strong)NSTimer *proTimer;
@property (nonatomic,assign) NSInteger count;


@end

@implementation ZJMUpgradingVC
{
     CGFloat centerX;
     CGFloat centerY;
}
-(void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:animated];
     _proTimer.fireDate = [NSDate distantFuture];
     [_proTimer invalidate];
     _proTimer = nil;
}
- (void)viewDidLayoutSubviews
{
     [super viewDidLayoutSubviews];
     NSLog(@"%f",_progressView.frame.origin.x);
}
- (void)viewDidLoad {
     [super viewDidLoad];
     // Do any additional setup after loading the view from its nib.
     if (self.type==0) {
          if ([self.sudDomain isEqualToString:X790SubDomain]) {
               [self listenStautusWithSubDomain:_sudDomain DeviceId:_deviceId];
          }else{
               [self timerAction];
          }
          _updatingLabel.text=[NSString stringWithFormat:@"%@...",NSLocalizedString(@"Updating", nil)];
          _tipsLabel.text=NSLocalizedString(@"During the upgrade, do not power off, wait for the upgrade to complete before using", nil);
          _comfirmBtn.hidden=YES;
     }else if (self.type==1){
          _updatingLabel.text=NSLocalizedString(@"Update unsuccessful", nil);
          _tipsLabel.text=NSLocalizedString(@"Update failed, click to try again", nil);
          _comfirmBtn.hidden=NO;
          [_comfirmBtn setTitle:NSLocalizedString(@"Click Retry", nil) forState:UIControlStateNormal];
     }
     _progressLabel = [[UILabel alloc]init];
     _progressLabel.frame = CGRectMake(_progressView.mj_w/2-(50/2), 0, 50, 30);
     _progressLabel.text=@"0%";
     _progressLabel.font=[UIFont systemFontOfSize:21];
     _progressLabel.textColor=HexColor(0x00BDB5);
     NSLog(@"%f",_progressView.frame.origin.x);
     [self.progressView addSubview:_progressLabel];
     CGFloat radius = _progressView.mj_w/2;
     //圆形路径
     UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(SCREENWEIGHT/2,SCREENHEIGHT*0.2)
                                                         radius:radius
                                                     startAngle:0
                                                       endAngle:M_PI*2
                                                      clockwise:YES];
     _backgroundLayer = [CAShapeLayer layer];
     _backgroundLayer.path = path.CGPath;
     _backgroundLayer.fillColor = [UIColor clearColor].CGColor;
     _backgroundLayer.strokeColor =HexColor(0xefefef).CGColor;
     _progressLayer= [CAShapeLayer layer];
     _progressLayer.path=path.CGPath;
     _progressLayer.strokeColor=HexColor(0x00BDB5).CGColor;
     _progressLayer.fillColor = [UIColor clearColor].CGColor;
     _progressLayer.strokeStart=0;
     _progressLayer.strokeEnd=0;
     [self.view.layer addSublayer:_backgroundLayer];
     [self.view.layer addSublayer:_progressLayer];
     [self.view.layer insertSublayer:_progressLayer above:_backgroundLayer];
     _progressLabel.text=@"0%";
     _installView.hidden=YES;
     CGAffineTransform transform = CGAffineTransformMakeScale(2,2);
     _installIndicatorView.transform = transform;
}
-(void)viewWillAppear:(BOOL)animated{
     self.navigationItem.leftBarButtonItem.customView.hidden = YES;
}
#pragma mark - 状态属性监听
-(void)listenStautusWithSubDomain:(NSString *)subDomain DeviceId:(NSInteger)deviceId{
     [ACDeviceDataManager subscribePropDataWithSubDomain:subDomain deviceId:deviceId callback:^(NSError *error) {
          
          if (!error) {
               [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                    _progress=[[properties get:@"update_progress"]integerValue];
                    [self getUpdateProgress];
               }];
          }else{
               
          }
          
     }];
}
-(void)timerAction{
     Byte content[] = {0};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:84 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:self.sudDomain physicalDeviceId: self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (error) {
               if ([_updatingLabel.text isEqualToString:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"Updating", nil)]]){
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                         if ([vc isKindOfClass:[ZJMMyDeviceVC class]]) {
                              [self.navigationController popToViewController:vc animated:YES];
                         }
                    }
               }else{
                    if (_count++>1) {
                         _proTimer.fireDate = [NSDate distantFuture];
                         [_proTimer invalidate];
                         _proTimer = nil;
                         [_installIndicatorView stopAnimating];
                         [_installIndicatorView removeFromSuperview];
                         _updatingLabel.text=NSLocalizedString(@"Update unsuccessful", nil);
                         _tipsLabel.text = @"";
                         _comfirmBtn.hidden=NO;
                         [_comfirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
                    }
                    _proTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
               }
               
          }else{
               if (_proTimer.isValid) {
                    _proTimer.fireDate = [NSDate distantFuture];
                    [_proTimer invalidate];
                    _proTimer = nil;
               }
               NSData * statuData = [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(0, 1)];
               NSString * statuStr = [self convertDataToHexStr:statuData];
               if ([statuStr isEqualToString:@"02"]) {
                    _proTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(getUpdateProgress) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_proTimer forMode:NSRunLoopCommonModes];
               }else if ([statuStr isEqualToString:@"03"] || [statuStr isEqualToString:@"00"]){
                    [self robotUpdateFinished];
               }else if ([statuStr isEqualToString:@"04"]){
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                         if ([vc isKindOfClass:[ZJMMyDeviceVC class]]) {
                              [self.navigationController popToViewController:vc animated:YES];
                         }
                    }
               }
               
          }
          
     }];
}



-(void)getUpdateProgress{
     if ([self.sudDomain isEqualToString:X790SubDomain]) {
          _progressLayer.strokeEnd=_progress/100.0f;
          _progressLabel.text=[NSString stringWithFormat:@"%ld%%",_progress];
          if (_progress>=99) {
               [self robotUpdateFinished];
          }
     }else{
          _progress = _progress+1;
          if (_progress>=99) {
               _proTimer.fireDate = [NSDate distantFuture];
               [_proTimer invalidate];
               _proTimer = nil;
               _progressView.hidden=YES;
               _installView.hidden=NO;
               [_backgroundLayer removeFromSuperlayer];
               [_progressLayer removeFromSuperlayer];
               _updatingLabel.text=[NSString stringWithFormat:@"%@...",NSLocalizedString(@"Installing update", nil)];
               _tipsLabel.text=NSLocalizedString(@"The installation process needs to restart the device, which may take a long time, please be patient.", nil);
               [_installIndicatorView startAnimating];
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self timerAction];
               });
               
          }else{
               _progressLayer.strokeEnd=_progress/100.0f;
               _progressLabel.text=[NSString stringWithFormat:@"%ld%%",_progress];
          }
     }
   
}
#pragma mark - 更新完成
-(void)robotUpdateFinished{
     if ([self.sudDomain isEqualToString:X790SubDomain]) {
          _progressView.hidden=YES;
          _installView.hidden=NO;
          [_backgroundLayer removeFromSuperlayer];
          [_progressLayer removeFromSuperlayer];
          _updatingLabel.text=[NSString stringWithFormat:@"%@...",NSLocalizedString(@"Installing update", nil)];
          _tipsLabel.text=NSLocalizedString(@"The installation process needs to restart the device, which may take a long time, please be patient.", nil);
          [_installIndicatorView startAnimating];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [_installIndicatorView stopAnimating];
               [_installIndicatorView removeFromSuperview];
               _updatingLabel.text=NSLocalizedString(@"Update completed", nil);
               ACOTACheckInfo * checkInfo = [ACOTACheckInfo checkInfoWithDeviceId:self.deviceId otaType:ACOTACheckInfoTypeSystem];
               [ACOTAManager checkUpdateWithSubDomain:_sudDomain OTACheckInfo:checkInfo callback:^(ACOTAUpgradeInfo *checkInfo, NSError *error) {
                    [self hideHud];
                    if (!error) {
                         _tipsLabel.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"The Current Version", nil), checkInfo.targetVersion];
                         _tipsLabel.textColor=HexColor(0x333333);
                         self.type=2;
                         _comfirmBtn.hidden=NO;
                         [_comfirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
                    }
                    else{
                         
                    }
               }];
          });
          
     }else{
          [_installIndicatorView stopAnimating];
          [_installIndicatorView removeFromSuperview];
          _updatingLabel.text=NSLocalizedString(@"Update completed", nil);
          _tipsLabel.text = _lastVersion;
          _tipsLabel.textColor=HexColor(0x333333);
          self.type=2;
          _comfirmBtn.hidden=NO;
          [_comfirmBtn setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
     }
}

- (IBAction)conmfirm:(UIButton *)sender {
     if (self.type==0) {
          [self.navigationController popToRootViewControllerAnimated:YES];
     }else if (self.type==2){
          for (UIViewController *vc in self.navigationController.viewControllers) {
               if ([vc isKindOfClass:[ZJMSettingVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
               }
          }
     }
     else{
          if ([self.sudDomain isEqualToString:X790SubDomain]) {
               [self showHudWithRound];
               [ACOTAManager confirmUpdateWithSubDomain:_sudDomain deviceId:_deviceId newVersion:_lastVersion otaType:ACOTACheckInfoTypeSystem callback:^(NSError *error) {
                    [self hideHud];
                    if (!error) {
                         _type=0;
                    }else{
                         _type=1;
                    }
                    ZJMUpgradingVC *upgragdingVc=[[ZJMUpgradingVC alloc]init];
                    upgragdingVc.type=self.type;
                    upgragdingVc.sudDomain=self.sudDomain;
                    upgragdingVc.title=NSLocalizedString(@"Firmware Update", nil);
                    [self.navigationController pushViewController:upgragdingVc animated:YES];
               }];
          }else{
               for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[ZJMMyDeviceVC class]]) {
                         [self.navigationController popToViewController:vc animated:YES];
                    }
               }
          }
     }
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
