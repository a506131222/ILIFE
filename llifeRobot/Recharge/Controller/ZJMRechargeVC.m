
//  ZJMRechargeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/7.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMRechargeVC.h"
#import "ZJMSettingVC.h"
#import "ZJMAddReserVC.h"
#import "ZJMX785SettingVC.h"
#import "GridView.h"
#import "SlamView.h"
#import "CleanDataModel.h"
#import "ZJMOTAUpateVC.h"
#import "UIAlertController+ZJMTapGesAlertVC.h"


@interface ZJMRechargeVC ()<SettingDelegate,X785SettingDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIView *gifView;
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *startCleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyCleanBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *cleanAreaLab;
@property (weak, nonatomic) IBOutlet UILabel *cleanTimeLab;
@property (strong,nonatomic) FLAnimatedImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomStatusLab;
@property (weak, nonatomic) IBOutlet UILabel *bottomAreaLab;
@property (weak, nonatomic) IBOutlet UILabel *bottomTimeLab;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIButton *remoteBtn;
@property (weak, nonatomic) IBOutlet UIButton *reserBtn;
@property (weak, nonatomic) IBOutlet UIButton *batteryBtn;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;

@property (weak, nonatomic) IBOutlet UIButton *upBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorLab;
@property (nonatomic)NSInteger errorMessage;
@property (strong,nonatomic)NSDictionary *info;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *areaView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *mapEditBtn;
@property (weak, nonatomic) IBOutlet UIStackView *editView;
@property (weak, nonatomic) IBOutlet UIButton *wallBtn;
@property (weak, nonatomic) IBOutlet UIButton *forbidBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (nonatomic,strong)ACObject *object;
@property (nonatomic,strong)NSMutableArray *dataArrM;
@property (nonatomic, strong)GridView *gridView;
@property (nonatomic,strong)SlamView *slamView;
@property (nonatomic,strong)ZJMDrawView *drawView;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSURL *randomUrl;
@property (nonatomic,strong)NSURL *rechargeUrl;
@property (nonatomic,strong)NSURL *spotUrl;
@property (nonatomic,strong)NSURL *staybyUrl;
@property (nonatomic,strong)NSURL *cleanUrl;
@property (nonatomic,strong)NSURL *alongWallUrl;
@property (nonatomic,assign)BOOL mode;
@property (nonatomic)NSInteger  batteryPower;
@property (weak, nonatomic) IBOutlet UIButton *alongWallBtn;
@property (nonatomic,copy)NSData *backdata;
@property (nonatomic,strong)NSMutableData *mapData;
@property (nonatomic,strong)NSData *data;
@property (nonatomic,strong)ACDeviceMsg *deviceMsg;
@property (nonatomic)NSInteger status;
@property (nonatomic)BOOL pop;
@property (nonatomic,strong) UIButton *selectedBtn;
@property (nonatomic,strong)NSMutableArray *pathArr;
@property (nonatomic, strong) NSTimer *Histimer;
@property (nonatomic,copy)NSString *serviceName;
@property (nonatomic,assign)NSInteger tempStr;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel1;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic,assign)CGPoint currentPoint;
@property (nonatomic)BOOL isGestureRecognizer;

@end

@implementation ZJMRechargeVC
{
     NSData *backData;
     Byte cleanContent[1];
     Byte dataByte[50]; //预约条数
     Byte mapByte[254];
     NSInteger batteryText;
     NSString *cleanModel;
     NSData *payloadData;
     BOOL canStop;//X800是否可以进入暂停状态
     CGFloat cleanArea;
     CGFloat cleanTime;
     int select;
     int click;
     NSInteger temp;
     NSString *sta;
     NSMutableData * fucData;
     
}


- (void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:animated];
     _gifView.hidden=YES;
     _mapView.hidden = YES;
     if (_Histimer != nil) {
          [_Histimer setFireDate:[NSDate distantFuture]];
          [_Histimer invalidate];
          _Histimer=nil;
     }
     [self cancelUpdateRealTime];
     [ACClassDataManager unSubscribeAllClassData];
     [ACDeviceDataManager unSubscribeAllDevicePropData];
}

-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
     self.navigationItem.rightBarButtonItem.enabled = YES;
     Byte content[] = {0};
     _data = [NSData dataWithBytes:content length:sizeof(content)];
     [self demandStatusWithCode:65 dinaryData:_data];
     if (![self.subDomain isEqualToString:X790SubDomain]) {
          [self getSlamRealMap];
     }else{
          [self getHistoryCleanRecord];
     }
     _mode = [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
     if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
          _Histimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getSlamRealMap)userInfo:nil repeats:YES];
          [self getHistoryCleanRecord];
     }else{
          [self queryReser];
          [self sendCleanData:backData];
     }
     [self listenStautusWithSubDomain:_subDomain DeviceId:_deviceID];
     [self listenMapValueChange];
}


- (void)viewDidLoad {
     [super viewDidLoad];
     self.statusLab.adjustsFontSizeToFitWidth = YES;
     [self setRightBtn];
     NSDictionary *serviceDict=[self backServiceNameDict];
     _serviceName = serviceDict[_subDomain];
     _pathArr = [[NSMutableArray alloc] init];
     if ([self.subDomain isEqualToString:@"ziyitest"]) {
          _statusView.hidden=YES;
          _areaView.hidden=YES;
          _timeView.hidden=YES;
     }if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X660SubDomain]||[self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
          [_downBtn setImage:[UIImage imageNamed:@"X800方向盘回转"] forState:UIControlStateNormal];
          _alongWallBtn.hidden=NO;
     }else{
          _alongWallBtn.hidden=YES;
          [_downBtn setImage:[UIImage imageNamed:@"map_aty_down"] forState:UIControlStateNormal];
          [_downBtn setImage:[UIImage imageNamed:@"map_aty_down_press"] forState:UIControlStateHighlighted];
     }
     _remoteView.hidden=YES;
     _errorView.hidden=YES;
     [self.view becomeFirstResponder];
     self.bottomStatusLab.text = NSLocalizedString(@"Current Status", nil);
     self.bottomTimeLab.text = NSLocalizedString(@"Cleaning Time", nil);
     self.bottomAreaLab.text = NSLocalizedString(@"Cleaning Area", nil);
     [self.rechargeBtn setTitle:NSLocalizedString(@"Recharge", nil) forState:UIControlStateNormal];
     [self.rechargeBtn setTitle:NSLocalizedString(@"Recharge", nil) forState:UIControlStateSelected];
     [self.startCleanBtn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
     [self.startCleanBtn setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateSelected];
     [self.keyCleanBtn setTitle:NSLocalizedString(@"Spot Cleaning", nil) forState:UIControlStateNormal];
     [self.keyCleanBtn setTitle:NSLocalizedString(@"Spot Cleaning", nil) forState:UIControlStateSelected];
     if ([self.subDomain isEqualToString:X430SubDomain]||[self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
          [self.upBtn addTarget:self action:@selector(goStraight) forControlEvents:UIControlEventTouchUpInside];
          [self.downBtn addTarget:self action:@selector(retreatDown) forControlEvents:UIControlEventTouchUpInside];
          [self.leftBtn addTarget:self action:@selector(goLeft) forControlEvents:UIControlEventTouchUpInside];
          [self.rightBtn addTarget:self action:@selector(goRight) forControlEvents:UIControlEventTouchUpInside];
     }else{
          [self.upBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
          [self.upBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
          [self.downBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
          [self.downBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
          [self.leftBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
          [self.leftBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
          [self.rightBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
          [self.rightBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
     }
     CGAffineTransform transform = CGAffineTransformMakeRotation(-45 * M_PI/180.0);
     [self.remoteView setTransform:transform];
     [self.view sendSubviewToBack:_mapView];
     [self.view sendSubviewToBack:_gifView];
     _gridView.userInteractionEnabled=YES;
     if (isIphoneX_Series==1) {
          _mapView.center = CGPointMake(SCREENWEIGHT/2, (SCREENHEIGHT-_statusView.height-_bottomView.height-NavBar_Height-Status_Height-Bottom_Safe_Height)/2+_statusView.height);
     }else{
          _mapView.center = CGPointMake(SCREENWEIGHT/2, (SCREENHEIGHT-_statusView.height-_bottomView.height-NavBar_Height-Status_Height)/2+_statusView.height);
     }
     if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
          [self.alongWallBtn setImage:[UIImage imageNamed:@"X9沿墙-选中"] forState:UIControlStateSelected];
          [self.remoteBtn setImage:[UIImage imageNamed:@"X9遥控器-选中"] forState:UIControlStateSelected];
          [self.reserBtn setImage:[UIImage imageNamed:@"X9闹钟-选中"] forState:UIControlStateSelected];
          [self.mapEditBtn setImage:[UIImage imageNamed:@"X9地图编辑-选中"] forState:UIControlStateSelected];
          [self.forbidBtn setImage:[UIImage imageNamed:@"X9禁区-选中"] forState:UIControlStateSelected];
          [self.saveBtn setImage:[UIImage imageNamed:@"X9打钩"] forState:UIControlStateNormal];
          [self.wallBtn setImage:[UIImage imageNamed:@"X9虚拟墙-选中"] forState:UIControlStateSelected];
          [_batteryBtn setImage:[UIImage imageNamed:@"X9电量满格"] forState:UIControlStateNormal];
          self.areaView.backgroundColor = HexColor(0x00BDB5);
          self.timeView.backgroundColor = HexColor(0x00BDB5);
          self.statusView.backgroundColor = HexColor(0x00BDB5);
          self.statusLab.textColor = [UIColor whiteColor];
          self.bottomStatusLab.textColor = [UIColor whiteColor];
          self.cleanAreaLab.textColor = [UIColor whiteColor];
          self.bottomAreaLab.textColor = [UIColor whiteColor];
          self.cleanTimeLab.textColor = [UIColor whiteColor];
          self.bottomTimeLab.textColor = [UIColor whiteColor];
          self.lineLabel.backgroundColor = [UIColor clearColor];
          self.lineLabel1.backgroundColor = [UIColor clearColor];
          _mapView.bounds = CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT);
          _slamView =[[SlamView alloc]initWithFrame:CGRectMake(0, 0,SCREENWEIGHT, SCREENHEIGHT)];
          [_mapView addSubview:_slamView];
          _drawView = [[ZJMDrawView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENWEIGHT)];
          _drawView.backgroundColor = [UIColor clearColor];
          _drawView.center = _slamView.center ;
          [_slamView addSubview:_drawView];
          [_slamView bringSubviewToFront:_drawView];
          _slamView.drawView = _drawView;
          
     }else{
          if ([self.subDomain isEqualToString:X800SubDomain]) {
               _mapView.bounds = CGRectMake(0, 0, gridViewWidth, gridViewHegith);
               _gridView = [[GridView alloc]initWithFrame:CGRectMake(0, 0, gridViewWidth, gridViewHegith)];
               [_mapView addSubview:_gridView];
               _drawView = [[ZJMDrawView alloc]initWithFrame:CGRectMake(0, 0,gridViewWidth, gridViewHegith)];
               _drawView.subDomain = self.subDomain;
               [_mapView addSubview:_drawView];
               _gridView.drawView = _drawView;
          }else{
               _mapView.bounds = CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT);
               _gridView = [[GridView alloc]initWithFrame:CGRectMake(0, 0,_mapView.frame.size.width, _mapView.frame.size.height)];
               _gridView.center=_mapView.center;;
               [_mapView addSubview:_gridView];
          }
     }
     _drawView.subDomain = self.subDomain;
     self.randomUrl = [[NSBundle mainBundle] URLForResource:@"随机清扫动态" withExtension:@"gif"];
     self.rechargeUrl = [[NSBundle mainBundle] URLForResource:@"回充动态" withExtension:@"gif"];
     self.spotUrl = [[NSBundle mainBundle] URLForResource:@"重点清扫动态" withExtension:@"gif"];
     self.staybyUrl = [[NSBundle mainBundle] URLForResource:@"待机动态" withExtension:@"gif"];
     self.cleanUrl = [[NSBundle mainBundle] URLForResource:@"规划清扫动态" withExtension:@"gif"];
     self.alongWallUrl = [[NSBundle mainBundle] URLForResource:@"沿墙动态" withExtension:@"gif"];
     select=1;
     click = 1;
     [self adjustButtonImageViewUPTitleDownWithButton:self.rechargeBtn];
     [self adjustButtonImageViewUPTitleDownWithButton:self.startCleanBtn];
     [self adjustButtonImageViewUPTitleDownWithButton:self.keyCleanBtn];
     temp=0;
     if ([self.subDomain isEqualToString:X790SubDomain]) {
          _batteryLabel.hidden=NO;
     }else{
          _batteryLabel.hidden=YES;
     }
     if ([self.subDomain isEqualToString:X900SubDomain] ||[self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
          self.mapEditBtn.hidden = NO;
          [self getRobotCurrentPosition];
     }else{
          [self updateRealTime];
     }
}


#pragma mark - 默认规划/随机模式
-(void)sendCleanData:(NSData *)data{
     if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
          cleanContent[0] = 6;
     }else{
          if ([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]) {
               if (_mode ==1) {
                    cleanContent[0]= 3;
               }else{
                    cleanContent[0] = 6;
               }
          }else{
               cleanContent[0] = 6;
          }
     }
}
#pragma mark - 查询预约
-(void)queryReser{
     Weakself;
     AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
     Byte content[] = {0};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:66 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               NSData *data = responseMsg.payload;
               for(int i=0;i<[data length];i++){
                    Byte *byte= (Byte *)[data bytes];
                    dataByte[i]=byte[i];
               }
               for (int i = 0; i <50; i++) {
                    if (i%5==0){
                         if (dataByte[i+1]==1&&dataByte[i+2]!=0) {
                              weakSelf.reserBtn.selected=YES;
                              break;
                         }else{
                              weakSelf.reserBtn.selected=NO;
                              
                         }
                    }
               }
          }
     }];
     
}

#pragma mark - 长按遥控按钮
-(void)buttonTouchBegin:(UIButton *)sender{
     if (click == 1) {
          click = 2;
          NSInteger btnTag = [sender tag];
          switch (btnTag) {
               case 10:{
                    [self goStraight];
                    self.upBtn.highlighted=YES;
                    _timer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goStraight) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
               }
                    break;
               case 11:{
                    [self goLeft];
                    self.leftBtn.highlighted=YES;
                    _timer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goLeft) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
               }
                    break;
               case 12:{
                    [self retreatDown];
               }
                    break;
               case 13:{
                    [self goRight];
                    self.rightBtn.highlighted=YES;
                    _timer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goRight) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
               }
                    break;
               default:
                    break;
          }
     }
     
     
}


-(void)buttonTouchEnd:(UIButton *)sender{
     [_timer invalidate];
     [_timer setFireDate:[NSDate distantFuture]];
     _timer=nil;
     [NSObject cancelPreviousPerformRequestsWithTarget:self];
     [self performSelector:@selector(pauseAction) withObject:nil afterDelay:0.3];
     click = 1;
     
}

-(void)cancelAction{
     self.upBtn.enabled = YES;
     self.downBtn.enabled=YES;
     self.rightBtn.enabled=YES;
     self.leftBtn.enabled=YES;
}
#pragma mark - 右边按钮
-(void)setRightBtn{
     UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
     [rightButton setImage:[UIImage imageNamed:@"设置"]forState:UIControlStateNormal];
     [rightButton setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateSelected];
     [rightButton addTarget:self action:@selector(pushSettingVC:)forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
     self.navigationItem.rightBarButtonItem= rightItem;
}
#pragma mark - 按钮文字条调整
- (void)adjustButtonImageViewUPTitleDownWithButton:(UIButton *)button {
     [button.superview layoutIfNeeded];
     //使图片和文字居左上角
     button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
     button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
     
     CGFloat buttonHeight = CGRectGetHeight(button.frame);
     CGFloat buttonWidth = CGRectGetWidth(button.frame);
     
     CGFloat ivHeight = CGRectGetHeight(button.imageView.frame);
     CGFloat ivWidth = CGRectGetWidth(button.imageView.frame);
     
     CGFloat titleHeight = CGRectGetHeight(button.titleLabel.frame);
     CGFloat titleWidth = CGRectGetWidth(button.titleLabel.frame);
     //调整图片
     float iVOffsetY = buttonHeight / 2.0 - (ivHeight + titleHeight) / 2.0;
     float iVOffsetX = buttonWidth / 2.0 - ivWidth / 2.0;
     [button setImageEdgeInsets:UIEdgeInsetsMake(iVOffsetY, iVOffsetX, 0, 0)];
     
     //调整文字
     float titleOffsetY = iVOffsetY + CGRectGetHeight(button.imageView.frame);
     float titleOffsetX = 0;
     if (CGRectGetWidth(button.imageView.frame) >= (CGRectGetWidth(button.frame) / 2.0)) {
          //如果图片的宽度超过或等于button宽度的一半
          titleOffsetX = -(ivWidth + titleWidth - buttonWidth / 2.0 - titleWidth / 2.0);
     }else {
          titleOffsetX = buttonWidth / 2.0 - ivWidth - titleWidth / 2.0;
     }
     [button setTitleEdgeInsets:UIEdgeInsetsMake(titleOffsetY , titleOffsetX, 0, 0)];
}

#pragma mark - 下发工作模式
-(void)sendWorkModelWithBinaryData:(NSData *)data Button:(UIButton *)sender{
     NSLog(@"下发工作数据 == %@",data);
     _selectedBtn = sender;
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:_deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ACDeviceDataManager fetchCurrentPropDataWithSubDomain:self.subDomain deviceId:self.deviceID callback:^(ACDevicePropertyMessage *result, NSError *error) {
                         if (!error) {
                              self.status = [result.properties getInteger:@"work_pattern"];
                              self.statusLab.text = [self backStatusMessage:self.status];
                              NSLog(@"返回的工作模式status == %d",self.status);
                              
                         }
                    }];
               });
               
               
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
          
          select=1;
     }];
}
#pragma mark - 回充
- (IBAction)recharge:(UIButton *)sender{
     Weakself;
     if (self.status==5 ||self.status==4 || self.status == 7){
          if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]|| [self.subDomain isEqualToString:X660SubDomain]) {
               [weakSelf showHudWithString:NSLocalizedString(@"Invalid operation", nil)];
               return;
          }
     }
     if ([self.statusLab.text isEqualToString:NSLocalizedString(@"Charging", nil)]) {
          [weakSelf showHudWithString:NSLocalizedString(@"Charging", nil)];
     }
     else{
          if (self.remoteView.hidden==NO) {
               [weakSelf touchClickBtn];
          }else{
               if (self.status!=8)
               {
                    Byte content [] = {8};
                    _data = [NSData dataWithBytes:content length:sizeof(content)];
                    _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                    [self sendWorkModelWithBinaryData:_data Button:sender];
               }else
               {
                    Byte byte[] = {2};
                    _data = [NSData dataWithBytes:byte length:sizeof(byte)];
                    _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                    [self sendWorkModelWithBinaryData:_data Button:sender];
               }
          }
     }
}


#pragma mark - 开始清扫
- (IBAction)startClean:(UIButton *)sender {
     
     if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
          if (self.status == 7 || self.status == 8 || self.status ==5 ) {
               [self showHudWithString:NSLocalizedString(@"Invalid operation", nil)];
               return;
          }
     }
     if (self.status == 2  && self.batteryPower<=6) {
          [self showHudWithString:NSLocalizedString(@"Low battery", nil)];
     }
     if (self.remoteView.hidden==NO) {
          [self touchClickBtn];
     }else{
          
          if (!(self.status==6||self.status==3 || self.status == 4))
          {
               if ([self.subDomain isEqualToString:X430SubDomain]||[self.subDomain isEqualToString:X782SubDomain]||[self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]){
                    if (_mode==YES) {
                         Byte content [] = {3};
                         _data = [NSData dataWithBytes:content length:sizeof(content)];
                         _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                         [self sendWorkModelWithBinaryData:_data Button:sender];
                         
                    }else{
                         Byte content [] = {6};
                         _data = [NSData dataWithBytes:content length:sizeof(content)];
                         _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                         [self sendWorkModelWithBinaryData:_data Button:sender];
                    }
               }
               else{
                    Byte content [] = {6};
                    _data = [NSData dataWithBytes:content length:sizeof(content)];
                    _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                    [self sendWorkModelWithBinaryData:_data Button:sender];
               }
               
               
          }else if (self.status==6){
               if ([self.subDomain isEqualToString:X790SubDomain] || [self.subDomain isEqualToString:X660SubDomain]){
                    [self showSelectAlertVCWithButton:sender];
                    
               }else if ([self.subDomain isEqualToString:X800SubDomain] && canStop == YES){
                    [self showSelectAlertVCWithButton:sender];
               }else{
                    Byte byte[] = {2};
                    _data = [NSData dataWithBytes:byte length:sizeof(byte)];
                    _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                    [self sendWorkModelWithBinaryData:_data Button:sender];
               }
          }
          else
          {
               Byte byte[] = {2};
               _data = [NSData dataWithBytes:byte length:sizeof(byte)];
               _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
               [self sendWorkModelWithBinaryData:_data Button:sender];
          }
     }
}
-(void)showSelectAlertVCWithButton:(UIButton *)sender{
     UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please choose your operation", nil) message:NSLocalizedString(@"Please set the current task for your robot", nil) preferredStyle:UIAlertControllerStyleAlert];
     [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Suspend", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          Byte byte[] = {12};
          _data = [NSData dataWithBytes:byte length:sizeof(byte)];
          _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
          [self sendWorkModelWithBinaryData:_data Button:sender];
     }]];
     [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Finish", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
          Byte byte[] = {2};
          _data = [NSData dataWithBytes:byte length:sizeof(byte)];
          _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
          [self sendWorkModelWithBinaryData:_data Button:sender];
     }]];
     [self presentViewController:alertVC animated:YES completion:^{
          [alertVC tapGesAlert];
     }];
     
}


-(void)changeCleanBtn{
     if (_startCleanBtn.selected==YES) {
          _startCleanBtn.enabled = YES;
     }else if (_rechargeBtn.selected==YES){
          _rechargeBtn.enabled = YES;
     }else{
          _keyCleanBtn.enabled = YES;
     }
     
}
#pragma mark - 重点清扫

- (IBAction)keyClean:(UIButton *)sender {
     Weakself;
     if (self.status==8 || self.status == 4 || self.status == 7){
          if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]|| [self.subDomain isEqualToString:X660SubDomain]) {
               [weakSelf showHudWithString:NSLocalizedString(@"Invalid operation", nil)];
               return;
          }
     }
     if (self.status == 2 && self.batteryPower<=6) {
          [self showHudWithString:NSLocalizedString(@"Low battery", nil)];
     }
     if ([self.statusLab.text isEqualToString:NSLocalizedString(@"Charging", nil)]) {
          
          [weakSelf showHudWithString:NSLocalizedString(@"Charging", nil)];
     }
     else{
          
          if (self.remoteView.hidden==NO) {
               [self touchClickBtn];
          }else{
               if (select==0) {
                    return;
               }
               select=0;
               if (self.status!=5 && self.status != 13)
               {
                    Byte content [] = {5};
                    _data = [NSData dataWithBytes:content length:sizeof(content)];
                    _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                    [self sendWorkModelWithBinaryData:_data Button:sender];
               }else
               {
                    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                         if (self.status == 13) {
                              Byte byte[] = {6};
                              _data = [NSData dataWithBytes:byte length:sizeof(byte)];
                              _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                              [self sendWorkModelWithBinaryData:_data Button:sender];
                         }else{
                              Byte byte[] = {2};
                              _data = [NSData dataWithBytes:byte length:sizeof(byte)];
                              _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                              [self sendWorkModelWithBinaryData:_data Button:sender];
                         }
                    }else{
                         Byte byte[] = {2};
                         _data = [NSData dataWithBytes:byte length:sizeof(byte)];
                         _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
                         [self sendWorkModelWithBinaryData:_data Button:sender];
                    }
                    
                    
               }
          }
     }
}
#pragma mark - 是否可以进入地图编辑模式
-(void)mapEditBtnYesOrNoSelect:(NSInteger)status{
     if (status == 1) {
          self.mapEditBtn.selected = YES;
          self.mapEditBtn.enabled = YES;
     }else{
          self.mapEditBtn.selected = NO;
          self.mapEditBtn.enabled = NO;
     }
     
}

#pragma mark - 进入地图编辑模式
- (IBAction)mapEditBtnDidClick:(UIButton *)sender {
     if (self.remoteView.hidden == NO) {
          [self touchClickBtn];
     }else{
          if (sender.selected == YES) {
               [self showAlertVCWithTitle:NSLocalizedString(@"Whether to enter map edit mode?", nil) withMessage:NSLocalizedString(@"This operation will pause the host cleaning", nil) andBtn:sender];
          }
     }
}

#pragma mark - 虚拟墙编辑模式
-(void)queryVirtualWallStatus:(NSInteger)status{
     
     if (self.status == 7) {
          _drawView.userInteractionEnabled = YES;
          self.mapView.hidden = NO;
          self.gifView.hidden = YES;
          self.editView.hidden = NO;
          self.mapEditBtn.selected = NO;
          self.mapEditBtn.enabled = NO;
          self.startCleanBtn.selected = NO;
     }else{
          _drawView.userInteractionEnabled = NO;
          self.editView.hidden = YES;
          _drawView.editModel = @"";
     }
     
     if (_tempStr == 7 && status != 7) {
          [self getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:_subDomain PhysicalDeviceId:_physicalDeviceId];
     }
     _tempStr = status;
}

#pragma mark - 按钮点击事件：撤销、虚拟墙、禁区、保存
- (IBAction)editBtnDidClick:(UIButton *)sender {
     if (sender.tag == 0) {
          [self showAlertVCWithTitle:NSLocalizedString(@"Whether to exit the electronic wall setup?", nil) withMessage:NSLocalizedString(@"This operation will repeal all current setting changes.", nil) andBtn:sender];
     }else if (sender.tag == 1){
          if (sender.selected == NO) {
               [self showAlertVCWithTitle:NSLocalizedString(@"Enter new electronic wall setting mode!", nil) withMessage:NSLocalizedString(@"With the finger in the map corresponding position line can be added", nil) andBtn:sender];
          }else{
               sender.selected = NO;
               _drawView.editModel = @"";
          }
          
     }else if (sender.tag == 2){
          if (sender.selected == NO) {
               if ([self.subDomain isEqualToString:X900SubDomain]) {
                    [self showHudWithString:NSLocalizedString(@"The robot does not support the  function of set forbidden area", nil)];
               }else{
                    [self showAlertVCWithTitle:NSLocalizedString(@"Enter add forbidden area mode!", nil) withMessage:NSLocalizedString(@"With the finger in the map corresponding position forbidden area can be added", nil) andBtn:sender];
               }
          }else{
               sender.selected = NO;
               _drawView.editModel = @"";
          }
     }else{
          [self showAlertVCWithTitle:NSLocalizedString(@"Whether to apply all electronic wall Settings?", nil) withMessage:NSLocalizedString(@"Manually move the host or reopen the opportunity to clear the electronic wall settings", nil) andBtn:sender];
     }
     
}
#pragma mark - 提示弹窗
-(void)showAlertVCWithTitle:(NSString *)title withMessage:(NSString *)message andBtn:(UIButton *)sender{
     UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
     for (UIView * view in alertController.view.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews) {
          if ([view isKindOfClass:[UILabel class]]) {
               UILabel * label = (UILabel *) view;
               if ([label.text isEqualToString:NSLocalizedString(@"With the finger in the map corresponding position line can be added", nil)] || [label.text isEqualToString:NSLocalizedString(@"Manually move the host or reopen the opportunity to clear the electronic wall settings", nil)]) {
                    label.textAlignment = NSTextAlignmentLeft;
               }
          }
     }
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          if (sender.tag == 4) {
               Byte byte[] = {1};
               NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
               ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:90 binaryData:data];
               [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    if (!error) {
                         self.wallBtn.selected = NO;
                         self.forbidBtn.selected = NO;
                         [self getRobotCurrentPosition];
                    }else{
                         
                         [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    }
                    
               }];
          }else if (sender.tag == 0){
               if ([self.subDomain isEqualToString:X900SubDomain]) {
                    [self sendVirWallOrFbdAreaWithBinaryData:[[NSMutableData alloc] initWithData:[fucData subdataWithRange:NSMakeRange(0, 82)]] withBtn:sender];
               }else{
                    [self sendVirWallOrFbdAreaWithBinaryData:fucData withBtn:sender];
               }
          }else if (sender.tag == 1){
               if (sender.selected == NO) {
                    sender.selected = YES;
                    _forbidBtn.selected = NO;
                    _drawView.editModel = @"1";
               }
               
          }else if (sender.tag == 2){
               if (sender.selected == NO) {
                    sender.selected = YES;
                    _wallBtn.selected = NO;
                    _drawView.editModel = @"0";
               }
          }else{
               //下发
               for (int i =0; i<_drawView.containArr.count; i++) {
                    if ([_drawView.containArr[i]  isEqual: @(1)]) {
                         [self showHudWithString:NSLocalizedString(@"Please adjust the position of the electronic wall and forbidden area first", nil)];
                         return ;
                    }
               }
               if (_drawView.mapData == nil) {
                    Byte content[254] = {0};
                    _drawView.mapData = [NSMutableData dataWithBytes:content length:sizeof(content)];
               }
               Byte byte[] = {1};
               [_drawView.mapData replaceBytesInRange:NSMakeRange(0, 1) withBytes:byte];
               [_drawView.mapData replaceBytesInRange:NSMakeRange(82, 1) withBytes:byte];
               if ([self.subDomain isEqualToString:X900SubDomain]) {
                    [self sendVirWallOrFbdAreaWithBinaryData:[[NSMutableData alloc] initWithData:[_drawView.mapData subdataWithRange:NSMakeRange(0, 82)]] withBtn:sender];
                    
               }else{
                    [self sendVirWallOrFbdAreaWithBinaryData:_drawView.mapData withBtn:sender];
               }
               
               
               
          }
     }];
     UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
          
     }];
     
     [alertController addAction:cancleAction];
     [alertController addAction:okAction];
     [self presentViewController:alertController animated:YES completion:^{
          [alertController tapGesAlert];
     }];
     
}


#pragma mark - 下发虚拟墙、禁区
-(void)sendVirWallOrFbdAreaWithBinaryData:(NSMutableData *)tempData withBtn:(UIButton *)btn{
     ACDeviceMsg * deviceMsg ;
     if ([self.subDomain isEqualToString:X900SubDomain]) {
          deviceMsg = [[ACDeviceMsg alloc] initWithCode:83 binaryData:tempData];
     }else{
          deviceMsg = [[ACDeviceMsg alloc] initWithCode:89 binaryData:tempData];
     }
     [self showHudWithRound];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:self.subDomain physicalDeviceId:self.physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          [self hideHud];
          if (!error) {
               if (btn.tag == 3) {
                    [self showHudWithString:NSLocalizedString(@"Setting Succeed", nil)];
               }
               _drawView.editModel = @"";
          }else{
               //下发失败显示已存在的虚拟墙
               [self getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:_subDomain PhysicalDeviceId:_physicalDeviceId];
               [self showHudWithString:NSLocalizedString(@"Setting Failed", nil)];
          }
     }];
}

#pragma mark - 查询虚拟墙、禁区
-(void)getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:(NSString *)subDomain PhysicalDeviceId:(NSString *)physicalDeviceId{
     Byte searchByte[] = {0};
     NSData *data = [NSData dataWithBytes:searchByte length:sizeof(searchByte)];
     ACDeviceMsg * msg ;
     if ([self.subDomain isEqualToString:X900SubDomain]) {
          msg = [[ACDeviceMsg alloc] initWithCode:69 binaryData:data];
     }else{
          msg = [[ACDeviceMsg alloc] initWithCode:87 binaryData:data];
     }
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               [_drawView clear];
               if (responseMsg) {
                    NSMutableData *tempData = [[NSMutableData alloc] initWithData:[responseMsg getBinaryData]];
                    NSInteger wallNum = [[NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr:[tempData subdataWithRange:NSMakeRange(1, 1)]] UTF8String],0,16)] integerValue];
                    Byte *byte= (Byte *)[tempData bytes];
                    for(int i=0;i<[tempData length];i++){
                         mapByte[i]=byte[i];
                    }
                    fucData = [NSMutableData dataWithBytes:mapByte length:sizeof(mapByte)];
                    [_drawView didWallOrFbdAreaDataSame:fucData];
                    _drawView.vtlCount = 1;
                    _drawView.fbdCount = 1;
                    NSMutableArray *virtulArr = [NSMutableArray array];
                    NSMutableArray * fbdArr = [NSMutableArray array];
                    for (int i = 2; i<wallNum*8+2; i +=2) {
                         int16_t originX =((byte[i]<<8)+byte[i+1]);
                         if (![self.subDomain isEqualToString:X800SubDomain]) {
                              originX=originX+MAPWIDTH/2;
                         }
                         [virtulArr addObject:[NSString stringWithFormat:@"%d",originX]];
                    }
                    if ([tempData length]>82) {
                         NSInteger fbdNum = [[NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr:[tempData subdataWithRange:NSMakeRange(83, 1)]] UTF8String],0,16)] integerValue];
                         for (int i = 84; i<fbdNum*17+84; i +=17) {
                              for (int j = i+1; j< i+17; j+=2) {
                                   int16_t originX =((byte[j]<<8)+byte[j+1]);
                                   if (![self.subDomain isEqualToString:X800SubDomain]) {
                                        originX=originX+MAPWIDTH/2;
                                   }
                                   [fbdArr addObject:[NSString stringWithFormat:@"%d",originX]];
                              }
                         }
                    }
                    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                         for (int i = 0; i<virtulArr.count; i+=4) {
                              [_drawView createLayerWithPoint1:[self getPointFromBitMapPoint:CGPointMake([virtulArr[i] integerValue], [virtulArr[i+1] integerValue])]
                                                     andPoint2:[self getPointFromBitMapPoint: CGPointMake([virtulArr[i+2] integerValue] ,[virtulArr[i+3] integerValue])]
                                                     andPoint3:CGPointZero
                                                     andPoint4:CGPointZero andType:1];
                              
                         }
                         
                         if ([self.subDomain isEqualToString:X910SubDomain]) {
                              for (int i = 0; i<fbdArr.count; i+=8) {
                                   [_drawView createLayerWithPoint1:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i] integerValue],[fbdArr[i+1] integerValue])] andPoint2:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+2] integerValue],[fbdArr[i+3] integerValue])] andPoint3:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+4] integerValue],[fbdArr[i+5] integerValue])] andPoint4:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+6] integerValue],[fbdArr[i+7] integerValue])] andType:0];
                              }
                         }
                    }else{
                         for (int i = 0; i<virtulArr.count; i+=4) {
                              [_drawView createLayerWithPoint1:[self getPointFromBitMapPoint:CGPointMake([virtulArr[i] integerValue], [virtulArr[i+1] integerValue])] andPoint2:[self getPointFromBitMapPoint:CGPointMake([virtulArr[i+2] integerValue],[virtulArr[i+3] integerValue])]  andPoint3:CGPointZero andPoint4:CGPointZero andType:1];
                              
                         }
                         for (int i = 0; i<fbdArr.count; i+=8) {
                              [_drawView createLayerWithPoint1:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i] integerValue], [fbdArr[i+1] integerValue])]
                                                     andPoint2:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+2] integerValue],[fbdArr[i+3] integerValue])]
                                                     andPoint3:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+4] integerValue],[fbdArr[i+5] integerValue])]
                                                     andPoint4:[self getPointFromBitMapPoint:CGPointMake([fbdArr[i+6] integerValue],[fbdArr[i+7] integerValue])] andType:0];
                         }
                    }
                    [_drawView hiddenByStatus:_status];
               }
          }
     }];
}

#pragma mark - 状态信息
-(NSString *)backStatusMessage:(NSInteger)message{
     NSString *status;
     switch (message) {
          case 0:
               status = NSLocalizedString(@"Offline", nil);
               break;
          case 1:
               status = NSLocalizedString(@"Sleep", nil);
               break;
          case 2:
               status = NSLocalizedString(@"Standby", nil);
               break;
          case 3:
               status = NSLocalizedString(@"Random", nil);
               break;
          case 4:
               status = NSLocalizedString(@"Edge", nil);
               break;
          case 5:
               status = NSLocalizedString(@"Spot Cleaning", nil);
               break;
          case 6:
               status = NSLocalizedString(@"Nav", nil);
               break;
          case 7:
               status = NSLocalizedString(@"Edit Mode", nil);
               break;
          case 8:
               status =NSLocalizedString(@"Recharge", nil);
               break;
          case 9:
               status =NSLocalizedString(@"Charging", nil);
               break;
          case 10:
               status = NSLocalizedString(@"Remote", nil);
               break;
          case 11:
               status =NSLocalizedString(@"Charging", nil);
               break;
          case 12:
               status=NSLocalizedString(@"Pause", nil);
               break;
          case 13:
               status=NSLocalizedString(@"Temporary spot", nil);
               break;
          case 14:
               status=NSLocalizedString(@"Updating", nil);
               break;
     }
     _mapView.hidden=YES;
     _gifView.hidden=YES;
     if (message==1||message==2 || message==12) {
          self.startCleanBtn.selected=NO;
          self.keyCleanBtn.selected=NO;
          self.rechargeBtn.selected=NO;
          if (self.remoteView.hidden==YES) {
               self.remoteBtn.selected=YES;
               self.alongWallBtn.selected=YES;
          }else{
               self.alongWallBtn.selected = NO;
               self.mapEditBtn.selected = NO;
               self.mapEditBtn.enabled = NO;
          }
     }
     if (message==6||message==12){
          _mapView.hidden=NO;
          _gifView.hidden=YES;
          if (message==6) {
               self.startCleanBtn.selected=YES;
          }
          self.remoteView.hidden=YES;
     }else{
          self.startCleanBtn.selected=NO;
          if (message != 7) {
               self.cleanAreaLab.text =@"— —";
               self.cleanTimeLab.text = @"— —";
          }
     }
     if (message==2||message==9||message==11 || message == 1 || message == 10) {
          if (self.mapEditBtn.hidden == YES || self.mapEditBtn.selected == NO) {
               _mapView.hidden = YES;
               _gifView.hidden = NO;
               [self loadGifImageUrl:self.staybyUrl];
          }else{
               _mapView.hidden = NO;
               _gifView.hidden = YES;
          }
     }
     if (message==3) {
          [self loadGifImageUrl:self.randomUrl];
          self.startCleanBtn.selected=YES;
     }
     if ((message!=2 || !self.errorView.hidden)) {
          self.alongWallBtn.selected = NO;
          self.alongWallBtn.enabled=NO;
     }else{
          self.alongWallBtn.enabled=YES;
          self.alongWallBtn.selected = YES;
     }
     if (message==4){
          self.alongWallBtn.selected=NO;
          self.startCleanBtn.selected=YES;
          if (self.mapEditBtn.hidden == YES || self.mapEditBtn.selected == NO) {
               _mapView.hidden=YES;
               _gifView.hidden=NO;
               [self loadGifImageUrl:_alongWallUrl];
          }else{
               _mapView.hidden = NO;
               _gifView.hidden = YES;
          }
          
     }
     if (message==5 || message == 13) {
          self.keyCleanBtn.selected=YES;
          if (self.mapEditBtn.hidden == YES || self.mapEditBtn.selected == NO) {
               _mapView.hidden=YES;
               _gifView.hidden=NO;
               [self loadGifImageUrl:self.spotUrl];
          }else{
               _mapView.hidden = NO;
               _gifView.hidden = YES;
          }
          
     }else{
          self.keyCleanBtn.selected=NO;
     }
     if (message==8) {
          self.rechargeBtn.selected=YES;
          if (self.mapEditBtn.hidden == YES || self.mapEditBtn.selected == NO) {
               _mapView.hidden = YES;
               _gifView.hidden = NO;
               [self loadGifImageUrl:self.rechargeUrl];
          }else{
               _mapView.hidden = NO;
               _gifView.hidden = YES;
          }
          
     }else{
          self.rechargeBtn.selected=NO;
     }
     if (message==2||message==10) {
          self.remoteBtn.enabled=YES;
     }else{
          self.remoteBtn.enabled=NO;
     }
     if (self.remoteView.hidden == NO) {
          if (message==3||message==4||message==5||message==8||message==7) {
               self.remoteView.hidden = YES;
          }else{
               self.alongWallBtn.selected = NO;
               self.mapEditBtn.selected = NO;
          }
     }
     if (message == 12) {
          self.alongWallBtn.selected = NO;
          self.reserBtn.selected = NO;
     }
     if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
          if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
               if (message == 6 || message == 8 || message == 4 || message == 5 || message == 13) {
                    [_Histimer setFireDate:[NSDate distantPast]];
               }else{
                    [_Histimer setFireDate:[NSDate distantFuture]];
               }
          }
          [self queryVirtualWallStatus:message];
     }
     
     if (!self.errorView.hidden) {
          self.remoteBtn.enabled = NO;
          self.remoteBtn.selected = NO;
          return status = NSLocalizedString(@"Abnormal", nil);
     }
     return status;
}

-(void)changeKeyCleanStatus{
     self.keyCleanBtn.enabled=YES;
}


#pragma mark - 沿墙
- (IBAction)sendAlongWall:(UIButton *)sender {
     if (self.alongWallBtn.selected) {
          if ( self.status == 2 && self.batteryPower<=6) {
               [self showHudWithString:NSLocalizedString(@"Low battery", nil)];
          }
          if (self.status!=4)
          {
               Byte content [] = {4};
               _data = [NSData dataWithBytes:content length:sizeof(content)];
               _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
               [self sendWorkModelWithBinaryData:_data Button:sender];
               
          }else
          {
               Byte byte[] = {2};
               _data = [NSData dataWithBytes:byte length:sizeof(byte)];
               _deviceMsg = [[ACDeviceMsg alloc]initWithCode:70 binaryData:_data];
               [self sendWorkModelWithBinaryData:_data Button:sender];
          }
     }else{
          self.remoteView.hidden = YES;
          self.alongWallBtn.selected = YES;
          self.remoteBtn.selected = YES;
     }
     
}

#pragma mark - 底部遥控事件
- (IBAction)showRemoteView:(UIButton *)sender {
     self.remoteView.hidden =! self.remoteView.hidden;
     sender.selected=!sender.selected;
     if (!self.remoteView.hidden && !sender.selected) {
          self.alongWallBtn.selected = NO;
          self.mapEditBtn.selected = NO;
          self.mapEditBtn.enabled = NO;
     }else{
          self.alongWallBtn.selected = YES;
          self.mapEditBtn.selected = YES;
          self.mapEditBtn.enabled = YES;
     }
     
     if (self.remoteView.hidden==YES) {
          Byte content[] = {2};
          NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
          ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
          [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
               if (!error) {
                    [self loadGifImageUrl:_staybyUrl];
               }else{
                    
               }
          }];
     }
}

#pragma mark - 遥控前进
-(void)goStraight{
     
     self.upBtn.highlighted=YES;
     Byte content[] = {1};
     if (select==0) {
          return;
     }
     select=0;
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          
          if (!error) {
               NSLog(@"下发前进成功");
          }else{
               NSLog(@"下发前进失败");
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
          select=1;
     }];
     
}

#pragma mark - 遥控左转
- (void)goLeft {
     if (select==0) {
          return;
     }
     select=0;
     self.leftBtn.highlighted=!self.leftBtn.highlighted;
     Byte content[] = {3};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               NSLog(@"下发左转成功");
          }else{
               NSLog(@"下发左转失败");
               
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
          select=1;
     }];
     
}
#pragma mark - 遥控后退
- (void)retreatDown{
     if (select==0) {
          return;
     }
     select=0;
     self.downBtn.highlighted=!self.downBtn.highlighted;
     Byte content[] = {2};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               NSLog(@"下发后退成功");
               
          }else{
               NSLog(@"下发后退失败");
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
          select=1;
     }];
     
}

#pragma mark - 遥控右转
- (void)goRight{
     if (select==0) {
          return;
     }
     select=0;
     self.rightBtn.highlighted=! self.rightBtn.highlighted;
     Byte content[] = {4};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               NSLog(@"下发右转成功");
          }else{
               NSLog(@"下发右转失败");
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
          select=1;
     }];
}
#pragma mark - 遥控暂停
- (void)pauseAction{
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          Byte content[] = {5};
          NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
          ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
          [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
               self.upBtn.highlighted=NO;
               self.downBtn.highlighted=NO;
               self.rightBtn.highlighted=NO;
               self.leftBtn.highlighted=NO;
               if (!error) {
                    NSLog(@"下发暂停成功");
               }else{
                    NSLog(@"下发暂停失败");
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
               }
          }];
     });
     
}
#pragma mark- 放大地图事件
- (IBAction)setBig:(UIButton *)sender {
     if (self.remoteView.hidden==NO) {
          [self touchClickBtn];
     }else{
          
     }
}
#pragma mark- 缩小地图事件
- (IBAction)setSmall:(UIButton *)sender {
     if (self.remoteView.hidden==NO) {
          [self touchClickBtn];
     }else{
          
     }
}

#pragma mark - 加载本地gif
-(void)loadGifImageUrl:(NSURL *)url{
     dispatch_async(dispatch_get_main_queue(), ^{
          if (!self.gifImageView) {
               self.gifImageView = [[FLAnimatedImageView alloc] init];
               self.gifImageView.contentMode = UIViewContentModeScaleAspectFit;
               self.gifImageView.clipsToBounds = YES;
          }
          [_gifView addSubview:self.gifImageView];
          self.gifImageView.frame = CGRectMake(0,0,_gifView.bounds.size.width, _gifView.bounds.size.height);
          
          FLAnimatedImage *animatedImg = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
          self.gifImageView.animatedImage = animatedImg;
          
     });
}

- (IBAction)removeErrorView:(UIButton *)sender {
     
     self.errorView.hidden=YES;
}

#pragma mark - 电池事件
- (IBAction)referClick:(UIButton *)sender {
     if (self.remoteView.hidden==NO) {
          [self touchClickBtn];
     }
}

#pragma mark -- 获取设备状态
-(void)demandStatusWithCode:(NSInteger)code dinaryData:(NSData *)data{
     _deviceMsg = [[ACDeviceMsg alloc]initWithCode:code binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:_deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          
          if (!error) {
               if (responseMsg.payload==nil) {
                    return ;
               }else{
                    if (responseMsg.payload.length ==10) {
                         canStop = YES;
                    }else{
                         canStop = NO;
                    }
                    NSInteger editNum = [[NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(14, 2)] UTF8String], 0, 16)] integerValue];
                    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
                         NSLog(@"数据长度 == %d",responseMsg.payload.length);
                         [self mapEditBtnYesOrNoSelect:editNum];
                         if (editNum == 1) {
                              [self getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:_subDomain PhysicalDeviceId:_physicalDeviceId];
                              if (responseMsg.payload.length ==20 ){
                                   Byte *mapByte = (Byte *)[[responseMsg getBinaryData] bytes];
                                   int16_t X = (int16_t)((mapByte[12]<<8)+mapByte[13]);
                                   int16_t Y =(int16_t)((mapByte[14]<<8)+mapByte[15]);
                                   if (![self.subDomain isEqualToString:X800SubDomain]) {
                                        X=X+MAPWIDTH/2;
                                        Y=Y+MAPWIDTH/2;
                                   }
                                   _drawView.robotPoint = CGPointMake(X, Y) ;
                                   int16_t chargeX = (int16_t)((mapByte[16]<<8)+mapByte[17]);
                                   int16_t chargeY =(int16_t)((mapByte[18]<<8)+mapByte[19]);
                                   if (![self.subDomain isEqualToString:X800SubDomain]) {
                                        chargeX=chargeX+MAPWIDTH/2;
                                        chargeY=chargeY+MAPWIDTH/2;
                                   }
                                   _drawView.chargPoint = CGPointMake(chargeX, chargeY);
                              }
                         }
                         
                         // 注:X900查询有无预约 其他机器不做处理
                         NSString *roomStyle = [[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(2, 2)];
                         if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                              if ([roomStyle isEqualToString:@"00"])  {
                                   self.reserBtn.selected = NO;
                              }else if([roomStyle isEqualToString:@"01"]){
                                   self.reserBtn.selected = YES;
                              }
                         }
                    }
                    self.status = [[NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr:responseMsg.payload] substringToIndex:2] UTF8String], 0, 16)] integerValue];
                    self.tempStr = self.status;
                    NSString *dataStr = [[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(10, 2)];
                    self.batteryPower = [[NSString stringWithFormat:@"%lu",strtoul([dataStr UTF8String],0,16)]integerValue];
                    NSString * errorStr = [[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(16, 2)];
                    self.errorMessage = [[NSString stringWithFormat:@"%lu",strtoul([errorStr UTF8String], 0, 16)] integerValue];
                    
                    if (self.errorMessage==0) {
                         self.errorView.hidden=YES;
                    }else{
                         self.errorView.hidden=NO;
                         self.errorLab.text = [self backErrorCode:self.errorMessage];
                    }
                    self.statusLab.text=[self backStatusMessage:self.status];
                    [self getDeviceBatteryValue:self.batteryPower Status:_status];
               }
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
}
#pragma mark - 获取主机的当前位置
-(void)getRobotCurrentPosition{
     Byte content[] = {0};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:88 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:self.subDomain physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               if (responseMsg.payload == nil) {
                    return ;
               }else{
                    if (![[NSString stringWithFormat:@"%@",[[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(0, 4)]] isEqualToString:@"7fff"] && ![[NSString stringWithFormat:@"%@",[[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(4, 4)]] isEqualToString:@"7fff"] ) {
                         Byte *mapByte = (Byte *)[[responseMsg getBinaryData] bytes];
                         int16_t X = (int16_t)((mapByte[0]<<8)+mapByte[1]);
                         int16_t Y =(int16_t)((mapByte[2]<<8)+mapByte[3]);
                         if (![self.subDomain isEqualToString:X800SubDomain]) {
                              X=X+MAPWIDTH/2;
                              Y=Y+MAPWIDTH/2;
                         }
                         [_drawView createArrWithPoint:CGPointMake(X,Y)];
                    }
                    if (![[NSString stringWithFormat:@"%@",[[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(12, 4)]] isEqualToString:@"7fff"] && ![[NSString stringWithFormat:@"%@",[[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(16, 4)]] isEqualToString:@"7fff"]) {
                         int16_t chargeX = (int16_t)((mapByte[6]<<8)+mapByte[7]);
                         int16_t chargeY =(int16_t)((mapByte[8]<<8)+mapByte[9]);
                         if (![self.subDomain isEqualToString:X800SubDomain]) {
                              chargeX=chargeX+MAPWIDTH/2;
                              chargeY=chargeY+MAPWIDTH/2;
                         }
                         _drawView.chargPoint = CGPointMake(chargeX, chargeY); ;
                    }
               }
          }else{
               //               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
     
}
#pragma mark -  故障信息
-(NSString *)backErrorCode:(NSInteger)code{
     
     NSString *status;
     switch (code) {
          case 1:
               status = NSLocalizedString(@"Bumper Abnormal", nil);
               break;
          case 17:
               status = NSLocalizedString(@"Anti-bump Sensors Abnormal", nil);
               break;
          case 18:
               status = NSLocalizedString(@"Edge Module Abnormal", nil);
               break;
          case 33:
               status = NSLocalizedString(@"Cliff Sensors Abnormal", nil);
               break;
          case 34:
               status = NSLocalizedString(@"Robot Not On the Floor", nil);
               break;
          case 49:
               status = NSLocalizedString(@"Nose Wheel Abnormal", nil);
               break;
          case 65:
               status = NSLocalizedString(@"Left Side Brush Abnormal", nil);
               break;
          case 66:
               status = NSLocalizedString(@"Right Side Brush Abnormal", nil);
               break;
          case 67:
               status =NSLocalizedString(@"Side Brush Abnormal", nil);
               break;
          case 81:
               status = NSLocalizedString(@"Left Wheel Abnormal", nil);
               break;
          case 82:
               status = NSLocalizedString(@"Right Wheel Abnormal", nil);
               break;
          case 97:
               status = NSLocalizedString(@"Main Brush Abnormal", nil);
               break;
          case 113:
               status = NSLocalizedString(@"Fan Motor Abnormal", nil);
               break;
          case 129:
               status = NSLocalizedString(@"Water Pump Abnormal", nil);
               break;
          case 130:
               status = NSLocalizedString(@"Air Aump Abnormal", nil);
               break;
          case 145:
               status = NSLocalizedString(@"Dust Tank Abnormal", nil);
               break;
          case 146:
               status = NSLocalizedString(@"Water Tank Abnormal", nil);
               break;
          case 147:
               status = NSLocalizedString(@"Filter Abnormal", nil);
               break;
          case 161:
               status = NSLocalizedString(@"Battery Abnormal", nil);
               break;
          case 177:
               status = NSLocalizedString(@"Navigation Module Abnormal", nil);
               break;
          case 193:
               status = NSLocalizedString(@"Radar Assembly Abnormal", nil);
               break;
          case 194:
               status = NSLocalizedString(@"Robot Camera Abnormal", nil);
               break;
          case 195:
               status = NSLocalizedString(@"Optical Component Anomaly", nil);
               break;
          case 209:
               status = NSLocalizedString(@"Route Abnormal", nil);
               break;
          case 225:
               status = NSLocalizedString(@"Other Error", nil);
               break;
          case 241:
               status = NSLocalizedString(@"Other Error", nil);
               break;
          default:
               status = NSLocalizedString(@"Other Error", nil);
               break;
     }
     return status;
}
#pragma mark - 获取slam地图
-(void)getSlamRealMap{
     ACMsg *msg = [ACMsg msgWithName:SearchCleanRealTime];
     [msg putInteger:@"device_id" value:_deviceID];
     [ACloudLib sendToService:_serviceName version:1 msg:msg callback:^(ACMsg *responseMsg, NSError *error) {
          if (!error) {
               NSDictionary *dict =[responseMsg getObjectData];
               if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                    NSString *mapStr=[NSString stringWithFormat:@"%@",dict[@"slam_map"]];
                    if(mapStr != nil && ![mapStr isEqualToString:@""]) {
                         NSData *data = [[NSData alloc] initWithBase64EncodedString:mapStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                         [_slamView modifyAlphaData:data];
                         _slamView.slam_x_min = [dict[@"slam_x_min"] floatValue];
                         _slamView.slam_x_max = [dict[@"slam_x_max"] floatValue];
                         _slamView.slam_y_min = [dict[@"slam_y_min"] floatValue];
                         _slamView.slam_y_max = [dict[@"slam_y_max"] floatValue];
                         CGFloat distance = _slamView.slam_x_max-_slamView.slam_x_min;
                         CGFloat distanceY = (MAPWIDTH -_slamView.slam_y_min)-(MAPWIDTH-_slamView.slam_y_max);
                         //根据 X.Y自动缩放地图
                         //MAPWIDTH/SCREENWEIGHT slamMap转化为手机尺寸:SCREENWEIGHT*SCREENWEIGHT
                         CGFloat X= ((_slamView.slam_x_max-_slamView.slam_x_min)/2-(MAPWIDTH/2-(_slamView.slam_x_min)))/(MAPWIDTH/SCREENWEIGHT);
                         CGFloat Y =((MAPWIDTH - _slamView.slam_y_min-(MAPWIDTH-_slamView.slam_y_max))/2-(MAPWIDTH/2-(MAPWIDTH-_slamView.slam_y_max)))/(MAPWIDTH/SCREENWEIGHT);
                         if (_slamView.isPanAction==NO) {
                              CGFloat scale;
                              if (distanceY<distance) {
                                   scale = MAPWIDTH/distance;
                              }else{
                                   scale = MAPWIDTH/distanceY;
                              }
                              if (scale>10) {
                                   scale = 10;
                              }
                              _slamView.drawView.scale = scale;
                              [_slamView setScale:scale withTranslateByX:X andY:Y];
                         }
                    }
               }else{
                    self.dataArrM = dict[@"data"];
                    NSDictionary *cleanDic = [[NSDictionary alloc]init];
                    if (self.dataArrM.count>0) {
                         NSMutableArray * pathArray = [[NSMutableArray alloc] init];
                         for (int i =0 ; i<self.dataArrM.count; i++) {
                              cleanDic = _dataArrM[i];
                              NSString *cleanStr= cleanDic[@"clean_data"];
                              NSData *cleanData = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                              Byte *mapByte = (Byte *)[cleanData bytes];
                              for (int i =4; i<[cleanData length]; i+=4) {
                                   int16_t X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                                   int16_t Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                                   int8_t type=0;
                                   [pathArray addObject:@(-X)];
                                   [pathArray addObject:@(Y)];
                                   [_gridView addGridByPoint:CGPointMake(-X, Y) DataType:type Realtime:NO SubDomain:_subDomain];
                              }
                              
                         }
                         NSLog(@"pathArray == %@",pathArray);
                         
                    }
               }
               
          }else{
               //               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
     
}

#pragma mark - 获取历史清扫路径
-(void)getHistoryCleanRecord{
     __block void (^blocks)(int);
     blocks = ^(int index){
          ACMsg * msg;
          if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
               msg = [ACMsg msgWithName:SearchCleanRoadDataMore];
          }else{
               msg = [ACMsg msgWithName:SearchCleanRealTimeMore];
          }
          [msg putInteger:@"pageNo" value:index];
          [msg putInteger:@"device_id" value:_deviceID];
          [ACloudLib sendToService:_serviceName version:1 msg:msg callback:^(ACMsg *responseMsg, NSError *error) {
               if (!error) {
                    NSDictionary *data =[responseMsg getObjectData];
                    NSArray * dataArrM = data[@"data"];
                    if (dataArrM.count==1000) {
                         blocks(index + 1);
                    }
                    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                         NSSortDescriptor * sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"start_time" ascending:YES];
                         dataArrM = [dataArrM sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
                         NSMutableArray * historyArr = [[NSMutableArray alloc] init];
                         if ([dataArrM count]>0) {
                              for (NSDictionary * dict in dataArrM) {
                                   [historyArr removeAllObjects];
                                   NSString * cleanStr = dict[@"clean_data"];
                                   NSMutableData * mapData = [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                   if ([mapData length]>4) {
                                        if ([[[self convertDataToHexStr:mapData] substringWithRange:NSMakeRange(4, 8)]isEqualToString:@"7fff7fff"]) {
                                             continue;
                                        }
                                   }
                                   Byte *mapByte = (Byte *)[mapData bytes];
                                   for (int i = 2; i<[mapData length]; i+=2) {
                                        int16_t point =((mapByte[i]<<8)+mapByte[i+1]);
                                        point=(point*SlamPathRadio)+MAPWIDTH/2;
                                        [historyArr addObject:[NSString stringWithFormat:@"%d",point]];
                                   }
                                   
                                   [self.slamView drawLineByPathArr:historyArr type:0];
                              }
                         }
                    }else{
                         if (dataArrM.count>0) {
                              for (int i =0 ; i<dataArrM.count; i++) {
                                   NSString *cleanStr = dataArrM[i][@"clean_data"];
                                   NSData *cleanData = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                   Byte *mapByte = (Byte *)[cleanData bytes];
                                   if ([self.subDomain isEqualToString:X790SubDomain]) {
                                        for (int i =4; i<[cleanData length]; i+=5) {
                                             CGFloat X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                                             CGFloat Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                                             NSInteger type=(int8_t)(mapByte[i+4]);
                                             if (type==0) {
                                                  type=2;
                                             }
                                             [_gridView addGridByPoint:CGPointMake(-X, Y) DataType:type Realtime:NO SubDomain:_subDomain];
                                        }
                                   }else{
                                        for (int i =4; i<[cleanData length]; i+=4) {
                                             int16_t X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                                             int16_t Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                                             int8_t type=0;
                                             [_gridView addGridByPoint:CGPointMake(-X, Y) DataType:type Realtime:NO SubDomain:_subDomain];
                                             
                                        }
                                   }
                              }
                         }
                         
                    }
                    
               }else{
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
               }
          }];
     };
     blocks(1);
}

#pragma mark - 实时地图清扫 && X900清扫路径
-(void)listenMapValueChange{
     ACObject *primaryKey = [[ACObject alloc] init];
     [primaryKey putInteger:@"device_id" value:_deviceID];
     [ACClassDataManager subscribeClass:CleanRealTime primaryKey:primaryKey callback:^(NSError *error) {
          if (!error) {
               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [ACClassDataManager setClassMessageHandler:^(NSString *className, ACClassDataOperationType opType, ACObject *payload) {
                         NSString *cleanStr = [NSString stringWithFormat:@"%@",[payload get:@"clean_data"]];
                         if (![cleanStr isEqualToString:@""]) {
                              if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                                   cleanArea = [payload getInteger:@"real_clean_area"];
                                   cleanTime = [[payload get:@"real_clean_time"]integerValue];
                                   if (self.status==6 || self.status == 7||self.status==12) {
                                        if (cleanArea == 0) {
                                             self.cleanAreaLab.text = [NSString stringWithFormat:@"%.1f㎡",cleanArea/100];
                                        }else{
                                             self.cleanAreaLab.text = [NSString stringWithFormat:@"%.2f㎡",cleanArea/100];
                                        }
                                        self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
                                   }else{
                                        self.cleanAreaLab.text =@"— —";
                                        self.cleanTimeLab.text = @"— —";
                                   }
                                   
                                   _mapData = [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                   if ([_mapData length]>4) {
                                        if ([[[self convertDataToHexStr:_mapData] substringWithRange:NSMakeRange(4, 8)]isEqualToString:@"7fff7fff"]) {
                                             [_slamView clearMapData];
                                             if (_pathArr.count>0) {
                                                  [_pathArr removeAllObjects];
                                             }
                                             [self getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:_subDomain PhysicalDeviceId:_physicalDeviceId];
                                             return;
                                        }
                                   }
                                   Byte *mapByte = (Byte *)[_mapData bytes];
                                   if ((_mapData.length-2)%4==0) {
                                        [_pathArr removeAllObjects];
                                        for (int i = 2; i<[_mapData length]; i +=2) {
                                             int16_t point =((mapByte[i]<<8)+mapByte[i+1]);
                                             //+MAPWIDTH/2 路径的点偏移到中心点(和Slam处于同一坐标系)
                                             point =point*SlamPathRadio+MAPWIDTH/2;
                                             [_pathArr addObject:[NSString stringWithFormat:@"%d",point]];
                                        }
                                        if (_pathArr.count>=4 ) {
                                             [self.slamView drawLineByPathArr:_pathArr type:1];
                                        }
                                   }
                                   
                              }else{
                                   NSData *data = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                   Byte *mapByte = (Byte *)[data bytes];
                                   if ([data length]>0) {
                                        cleanArea = ((mapByte[0]<<8)+mapByte[1]);
                                        cleanTime = (mapByte[2]<<8)+mapByte[3];
                                        float cleanAreaNumber = cleanArea/100.0;
                                        if (self.status==6  || self.status == 7||self.status==12) {
                                             self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
                                             self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
                                        }
                                        else{
                                             self.cleanAreaLab.text =@"— —";
                                             self.cleanTimeLab.text = @"— —";
                                        }
                                   }
                                   if ([self.subDomain isEqualToString:X790SubDomain]) {
                                        for (int i =4; i<[data length]; i+=5) {
                                             CGFloat X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                                             CGFloat   Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                                             NSInteger  type=(int16_t)(mapByte[i+4]);
                                             [_gridView addGridByPoint:CGPointMake(-X, Y) DataType:type Realtime:YES SubDomain:_subDomain];
                                        }
                                   }else{
                                        if ([self.subDomain isEqualToString:X800SubDomain]) {
                                             if ([data length]>4) {
                                                  if ([[[self convertDataToHexStr:data] substringWithRange:NSMakeRange(4, 8)]isEqualToString:@"7fff7fff"]) {
                                                       [self getNumOfVitulWallOrFbdareaFromServiceWithSubDomain:_subDomain PhysicalDeviceId:_physicalDeviceId];
                                                       return;
                                                  }
                                             }
                                        }
                                        for (int i =4; i<[data length]; i+=4) {
                                             int16_t X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                                             int16_t Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                                             int8_t type=0;
                                             [_gridView addGridByPoint:CGPointMake(-X, Y) DataType:type Realtime:NO SubDomain:_subDomain];
                                        }
                                   }
                                   
                              }
                         }
                         
                    }];
               });
               
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
}

#pragma mark - 状态属性监听
-(void)listenStautusWithSubDomain:(NSString *)subDomain DeviceId:(NSInteger)deviceId{
     [ACDeviceDataManager subscribePropDataWithSubDomain:subDomain deviceId:deviceId callback:^(NSError *error) {
          if (!error) {
               [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
                         [self mapEditBtnYesOrNoSelect:[[properties get:@"light_mode"]integerValue]];
                    }
                    _status = [[properties get:@"work_pattern"]integerValue];
                    [_drawView hiddenByStatus:_status];
                    NSLog(@"状态监听 == %d",self.status);
                    self.batteryPower = [[properties get:@"battery_level"]integerValue];
                    [self getDeviceBatteryValue:self.batteryPower Status:self.status];
                    self.errorMessage = [[properties get:@"error_info"]integerValue];
                    if (self.errorMessage==0) {
                         self.errorView.hidden=YES;
                    }else{
                         self.errorView.hidden=NO;
                         self.errorLab.text = [self backErrorCode:self.errorMessage];
                    }
                    self.statusLab.text=[self backStatusMessage:_status];
               }];
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
}

#pragma mark - 获取电池电量
-(void)getDeviceBatteryValue:(NSInteger)value Status:(NSInteger)status{
     if ([self.subDomain isEqualToString:X790SubDomain]) {
          [_batteryBtn setImage:[UIImage imageNamed:@"电量"] forState:UIControlStateNormal];
          _batteryLabel.text=[NSString stringWithFormat:@"%ld%%",value];
     }else{
          _batteryLabel.text = @"";
          if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
               if (value<98 &&(status==9 ||status==11)) {
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9充电中"] forState:UIControlStateNormal];
               }else if (value>=98 &&(status==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9充满电"] forState:UIControlStateNormal];
               }else if(value >=75&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9电量满格"] forState:UIControlStateNormal];
               }else if (value<75&&value>35&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9电量2格"] forState:UIControlStateNormal];
               } else if (value<35&&value>6&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9电量1格"] forState:UIControlStateNormal];
               }else if (value<=6&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"X9电量0格"] forState:UIControlStateNormal];
               }
          }else{
               if (value<98 &&(status==9 ||status==11)) {
                    [_batteryBtn setImage:[UIImage imageNamed:@"充电中"] forState:UIControlStateNormal];
               }else if (value>=98 &&(status==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"充满电"] forState:UIControlStateNormal];
               }else if(value >=75&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"电量满格"] forState:UIControlStateNormal];
               }else if (value<75&&value>35&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"电量2格"] forState:UIControlStateNormal];
               } else if (value<35&&value>6&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"电量1格"] forState:UIControlStateNormal];
               }else if (value<=6&&!(status ==9 ||status==11)){
                    [_batteryBtn setImage:[UIImage imageNamed:@"电量0格"] forState:UIControlStateNormal];
               }
          }
     }
     
}

#pragma mark -  上传实时信息
-(void)updateRealTime{
     Byte content[] ={1};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:77 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          
          if (!error) {
               NSLog(@"上传实时信息成功");
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
}
#pragma mark - 取消上传实时信息
-(void)cancelUpdateRealTime{
     Weakself;
     
     Byte content[] ={0};
     NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
     ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:77 binaryData:data];
     [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:weakSelf.subDomain physicalDeviceId:weakSelf.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
          if (!error) {
               
          }else{
               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
          }
     }];
}
-(void)returnData:(NSData *)data{
     backData = data;
     _pop=YES;
}

-(void)returnName:(NSString *)name{
     _deviceName=name;
}
#pragma mark - 按钮事件与点击空白冲突
-(void)touchClickBtn{
     _remoteView.hidden=YES;
     self.alongWallBtn.selected = YES;
     if (_remoteBtn.selected==YES) {
          _remoteBtn.selected=NO;
     }else{
          _remoteBtn.selected=YES;
     }
     if  ([self.statusLab.text isEqualToString:NSLocalizedString(@"Remote", nil)]) {
          Byte content[] = {2};
          NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
          ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
          [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
               if (!error) {
                    [self loadGifImageUrl:_staybyUrl];
               }else{
                    
               }
          }];
     }
}

#pragma mark - 点击空白处隐藏遥控视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     if (self.remoteView.hidden == NO) {
          if  ([self.statusLab.text isEqualToString:NSLocalizedString(@"Remote", nil)]) {
               
               Byte content[] = {2};
               NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
               ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
               [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    if (!error) {
                         
                    }else{
                         
                    }
               }];
          }
     }
     if (_remoteView.hidden==NO) {
          if (_remoteBtn.selected==YES) {
               _remoteBtn.selected=NO;
          }else{
               _remoteBtn.selected=YES;
          }
          
     }   _remoteView.hidden=YES;
     self.alongWallBtn.selected = YES;
     
     
}
#pragma mark - 预约按钮事件
- (IBAction)reserView:(UIButton *)sender {
     if (self.remoteView.hidden == NO) {
          [self touchClickBtn];
     }else{
          ZJMAddReserVC *timerReserVc = [[ZJMAddReserVC alloc]init];
          timerReserVc.title = NSLocalizedString(@"Planning", nil);
          timerReserVc.subDomain =self.subDomain;
          [self.navigationController pushViewController:timerReserVc animated:YES];
     }
}

//#pragma mark - 导航栏按钮事件
-(void)pushSettingVC:(UIButton *)sender{
     self.navigationItem.rightBarButtonItem.enabled = NO;
     if ([self.subDomain isEqualToString:X786SubDomain]||[self.subDomain isEqualToString:X782SubDomain]||[self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]) {
          ZJMX785SettingVC *settingVc = [[ZJMX785SettingVC alloc]init];
          settingVc.title = NSLocalizedString(@"Settings", nil);
          settingVc.delegate = self;
          settingVc.deviceID = _deviceID;
          settingVc.deviceName = _deviceName;
          settingVc.deviceStatus = cleanModel;
          settingVc.subDomain=_subDomain;
          settingVc.physicalDeviceId = _physicalDeviceId;
          settingVc.isManager = _isManager;
          [self.navigationController pushViewController:settingVc animated:YES];
          
     }else{
          ZJMSettingVC *settingVc = [[ZJMSettingVC alloc]init];
          settingVc.title = NSLocalizedString(@"Settings", nil);
          settingVc.delegate = self;
          settingVc.deviceID = _deviceID;
          settingVc.deviceName = _deviceName;
          settingVc.deviceStatus = cleanModel;
          settingVc.subDomain=_subDomain;
          settingVc.physicalDeviceId = _physicalDeviceId;
          settingVc.isManager = _isManager;
          [self.navigationController pushViewController:settingVc animated:YES];
     }
     
}
#pragma mark - 位图上的点转换成手机屏幕上的点
-(CGPoint)getPointFromBitMapPoint:(CGPoint)point{
     if ([self.subDomain isEqualToString:X800SubDomain]) {
          return CGPointMake(point.x*PointSize+_drawView.bounds.size.width/2,point.y*PointSize+_drawView.bounds.size.height/2);
     }else{
          return CGPointMake(point.x*SCREENWEIGHT/MAPWIDTH,(MAPWIDTH - point.y)* SCREENWEIGHT/MAPWIDTH);
     }
}

#pragma mark - 服务名
-(NSDictionary *)backServiceNameDict{
     AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
     NSDictionary *serviceNameDict;
     switch (delegate.appRegion) {
          case 0:
          {
               serviceNameDict =@{
                                  X420SubDomain : Service_Name_X420_CN,
                                  X430SubDomain : Service_Name_X430_CN,
                                  X660SubDomain : Service_Name_X660_CN,
                                  X610SubDomain : Service_Name_X610_CN,
                                  X620SubDomain : Service_Name_X620_CN,
                                  X782SubDomain : Service_Name_X782_CN,
                                  X785SubDomain : Service_Name_X785_CN,
                                  X785SubDomain : Service_Name_X785_CN,
                                  X786SubDomain : Service_Name_X786_CN,
                                  X787SubDomain : Service_Name_X787_CN,
                                  X790SubDomain : Service_Name_X790_CN,
                                  X800SubDomain : Service_Name_X800_CN,
                                  X900SubDomain : Service_Name_X900_CN,
                                  X910SubDomain : Service_Name_X910_CN
                                  
                                  };
          }
               break;
          case 1:
          {
               serviceNameDict =@{
                                  X420SubDomain : Service_Name_X420_SA,
                                  X430SubDomain : Service_Name_X430_SA,
                                  X660SubDomain : Service_Name_X660_SA,
                                  X610SubDomain : Service_Name_X610_SA,
                                  X620SubDomain : Service_Name_X620_SA,
                                  X782SubDomain : Service_Name_X782_SA,
                                  X785SubDomain : Service_Name_X785_SA,
                                  X785SubDomain : Service_Name_X785_SA,
                                  X786SubDomain : Service_Name_X786_SA,
                                  X787SubDomain : Service_Name_X787_SA,
                                  X790SubDomain : Service_Name_X790_SA,
                                  X800SubDomain : Service_Name_X800_SA,
                                  X900SubDomain : Service_Name_X900_SA,
                                  X910SubDomain : Service_Name_X910_SA
                                  };
          }
               break;
          case 2:
          {
               serviceNameDict =@{
                                  X420SubDomain : Service_Name_X420_EU,
                                  X430SubDomain : Service_Name_X430_EU,
                                  X660SubDomain : Service_Name_X660_EU,
                                  X610SubDomain : Service_Name_X610_EU,
                                  X620SubDomain : Service_Name_X620_EU,
                                  X782SubDomain : Service_Name_X782_EU,
                                  X785SubDomain : Service_Name_X785_EU,
                                  X785SubDomain : Service_Name_X785_EU,
                                  X786SubDomain : Service_Name_X786_EU,
                                  X787SubDomain : Service_Name_X787_EU,
                                  X790SubDomain : Service_Name_X790_EU,
                                  X800SubDomain : Service_Name_X800_EU,
                                  X900SubDomain : Service_Name_X900_EU,
                                  X910SubDomain : Service_Name_X910_EU
                                  };
          }
               break;
          case 3:
          {
               serviceNameDict =@{
                                  X420SubDomain : Service_Name_X420_NA,
                                  X430SubDomain : Service_Name_X430_NA,
                                  X660SubDomain : Service_Name_X660_NA,
                                  X610SubDomain : Service_Name_X610_NA,
                                  X620SubDomain : Service_Name_X620_NA,
                                  X782SubDomain : Service_Name_X782_NA,
                                  X785SubDomain : Service_Name_X785_NA,
                                  X785SubDomain : Service_Name_X785_NA,
                                  X786SubDomain : Service_Name_X786_NA,
                                  X787SubDomain : Service_Name_X787_NA,
                                  X790SubDomain : Service_Name_X790_NA,
                                  X800SubDomain : Service_Name_X800_NA,
                                  X900SubDomain : Service_Name_X900_NA,
                                  X910SubDomain : Service_Name_X910_NA
                                  };
          }
               break;
          default:
               break;
     }
     return serviceNameDict;
}

#pragma mark - 字符串补位
- (NSString *)formatFloat:(float)f
{
     if (fmodf(f, 1)==0) {//如果有一位小数点
          return [NSString stringWithFormat:@"%.1f",f];
     } else if (fmodf(f*10, 1)==0) {//如果有两位小数点
          return [NSString stringWithFormat:@"%.1f",f];
     } else {
          return [NSString stringWithFormat:@"%.2f",f];
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


-(BOOL)canBecomeFirstResponder{
     return YES;
}



@end

