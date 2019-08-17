
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

@interface ZJMRechargeVC ()<SettingDelegate,X785SettingDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UIView *gifView;
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *rechargeTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *startCleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *startCleanTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyCleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyCleanTextBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *cleanAreaLab;
@property (weak, nonatomic) IBOutlet UILabel *cleanTimeLab;
@property (strong,nonatomic) FLAnimatedImageView *gifImageView;
@property (nonatomic,strong) UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UILabel *bottomStatusLab;
@property (weak, nonatomic) IBOutlet UILabel *bottomAreaLab;
@property (weak, nonatomic) IBOutlet UILabel *bottomTimeLab;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIButton *remoteBtn;
@property (weak, nonatomic) IBOutlet UIButton *reserBtn;
@property (weak, nonatomic) IBOutlet UIButton *batteryBtn;

@property (weak, nonatomic) IBOutlet UIButton *upBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (nonatomic,assign) CFTimeInterval minimumPressDuration;
@property (weak, nonatomic) IBOutlet UILabel *errorLab;
@property (strong,nonatomic)NSDictionary *info;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *areaView;
@property (weak, nonatomic) IBOutlet UIView *timeView;

@property (assign,atomic)   NSInteger FirstYearByte;
@property (assign,atomic)   NSInteger SecondYearByte;
@property (assign,atomic)   NSInteger ThirdMonthByte;
@property (assign,atomic)   NSInteger ForthDayByte;
@property (assign,atomic)   NSInteger FifthWeekByte;
/** 校准时间小时*/
@property (assign,atomic)   NSInteger SixthHourByte;
/** 校准时间分钟*/
@property (assign,atomic)   NSInteger SeventhMinByte;
/** 校准时间秒*/
@property (assign,atomic)   NSInteger EighthSecByte;
@property (nonatomic,strong)ACObject *object;
@property (nonatomic,strong)NSMutableArray *dataArrM;
@property (nonatomic, strong)GridView *gridView;
@property (nonatomic,strong)SlamView *slamView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (atomic,assign)    CGPoint currentPoint;
@property (nonatomic,strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong)UIPanGestureRecognizer *pan;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSURL *randomUrl;
@property (nonatomic,strong)NSURL *rechargeUrl;
@property (nonatomic,strong)NSURL *spotUrl;
@property (nonatomic,strong)NSURL *staybyUrl;
@property (nonatomic,strong)NSURL *cleanUrl;
@property (nonatomic,strong)NSURL *alongWallUrl;
@property (nonatomic,assign)BOOL mode;

@property (nonatomic,strong) UITapGestureRecognizer *secondTap;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *alongWallBtn;
@property (nonatomic,copy)NSData *backdata;
@property (nonatomic,strong)NSMutableData *mapData;
@end

@implementation ZJMRechargeVC
{
    NSData *backData;
    Byte cleanContent[1];
    Byte dataByte[50];
    NSInteger batteryText;
    NSString *cleanModel;
    NSData *payloadData;
    ACDeviceMsg *deviceMsg;
    BOOL isAppend;
    Byte Byte[50];
    uint16_t cleanArea;
    uint16_t cleanTime;
    NSString *status;
    int select;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _mapView.hidden=YES;
        if ([self.subDomain isEqualToString:X900SubDomain]) {
            [_scrollView setContentOffset:_slamView.center animated:NO];
        }else{
            [_scrollView setContentOffset:_gridView.center animated:NO];
        }
    _mode = [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
    [self listenMapValueChange];
    [self listenPropertyValueChange];
    [self referDeviceStatus];
    [self queryReser];
    [self sendCleanData:backData];
}


- (void)viewWillDisappear:(BOOL)animated{
    [self cancelUpdateRealTime];
    [ACClassDataManager unSubscribeAllClassData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.subDomain isEqualToString:@"ziyitest"]) {
        _statusView.hidden=YES;
        _areaView.hidden=YES;
        _timeView.hidden=YES;
        
    }else{
        _statusView.hidden=NO;
        _areaView.hidden=NO;
        _timeView.hidden=NO;
        
        _backgroundImage.hidden=YES;
    }if ([self.subDomain isEqualToString:X785SubDomain]||[self. subDomain isEqualToString:X787SubDomain]) {
        _alongWallBtn.hidden=YES;
        [_downBtn setImage:[UIImage imageNamed:@"map_aty_down"] forState:UIControlStateNormal];
        [_downBtn setImage:[UIImage imageNamed:@"map_aty_down_press"] forState:UIControlStateHighlighted];
        
    }else{
        [_downBtn setImage:[UIImage imageNamed:@"X800方向盘回转.png"] forState:UIControlStateNormal];
        
        _alongWallBtn.hidden=NO;
    }
    _remoteView.hidden=YES;
    _errorView.hidden=YES;
    [self.view becomeFirstResponder];
    [self setRightBtn];
    [self setUpTimeCalibration];
    [self updateRealTime];
    [self getHistoryCleanRecord];
    self.bottomStatusLab.text = NSLocalizedString(@"Current Status", nil);
    self.bottomTimeLab.text = NSLocalizedString(@"Clean Time", nil);
    self.bottomAreaLab.text = NSLocalizedString(@"Clean Area", nil);
    [self.rechargeTextBtn setTitle:NSLocalizedString(@"Recharge", nil) forState:UIControlStateNormal];
    [self.startCleanTextBtn setTitle:NSLocalizedString(@"Start Clean", nil) forState:UIControlStateNormal];
    [self.startCleanTextBtn setTitle:NSLocalizedString(@"Stop Clean", nil) forState:UIControlStateSelected];
    [self.keyCleanTextBtn setTitle:NSLocalizedString(@"Spot Clean", nil) forState:UIControlStateNormal];
    self.rechargeTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.startCleanTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.keyCleanTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [_batteryBtn setImage:[UIImage imageNamed:@"电量满格"] forState:UIControlStateNormal];
    if ([self.subDomain isEqualToString:X430SubDomain]||[self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
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
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT)];
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
    _scrollView.decelerationRate=0;
    _scrollView.delegate=self;
    if ([self.subDomain isEqualToString:X900SubDomain]) {
        _slamView = [[SlamView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT)];
        [_mapView addSubview:_slamView];
        _mapView.frame = CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT);
        _scrollView.contentSize = _mapView.bounds.size;
    }else{
        _gridView = [[GridView alloc] initWithFrame:CGRectMake(0, 0,SCREENWEIGHT*5, SCREENHEIGHT*5) column:720 row:1296];
        [_mapView addSubview:_gridView];
        _mapView.frame = CGRectMake(0, 0, SCREENWEIGHT*5, SCREENHEIGHT*5);
        _scrollView.contentSize = _mapView.bounds.size;
    }
    
    [_scrollView addSubview:_mapView];
    _scrollView.maximumZoomScale=1.5;
    _scrollView.minimumZoomScale=1.0;
    _scrollView.showsVerticalScrollIndicator=NO;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.scrollView addGestureRecognizer:_tap];
    self.randomUrl = [[NSBundle mainBundle] URLForResource:@"随机清扫动态" withExtension:@"gif"];
    self.rechargeUrl = [[NSBundle mainBundle] URLForResource:@"回充动态" withExtension:@"gif"];
    self.spotUrl = [[NSBundle mainBundle] URLForResource:@"重点清扫动态" withExtension:@"gif"];
    self.staybyUrl = [[NSBundle mainBundle] URLForResource:@"待机动态" withExtension:@"gif"];
    self.cleanUrl = [[NSBundle mainBundle] URLForResource:@"规划清扫动态" withExtension:@"gif"];
    self.alongWallUrl = [[NSBundle mainBundle] URLForResource:@"沿墙动态" withExtension:@"gif"];
    select=1;
    _scrollView.scrollsToTop = NO;
}

#pragma mark - 默认规划/随机模式
-(void)sendCleanData:(NSData *)data{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        
        cleanContent[0] = 6;
    }else{
        //
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
    data = [NSData dataWithBytes:cleanContent length:sizeof(cleanContent)];
    deviceMsg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
}
#pragma mark - 查询预约
-(void)queryReser{
    Weakself;
    
    if (weakSelf.remoteView.hidden==NO) {
        [weakSelf touchClickBtn];
    }else{
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        Byte content[] = {0};
        NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
        ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:66 binaryData:data];
        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
            StrongSelf;
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
}

#pragma mark - 长按遥控按钮
-(void)buttonTouchBegin:(UIButton *)sender{
    NSInteger btnTag = [sender tag];
    switch (btnTag) {
        case 10:{
            [self goStraight];
            self.upBtn.highlighted=YES;
            _timer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goStraight) userInfo:nil repeats:YES];
            // 加入RunLoop中
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
            
        }
            break;
        case 11:{
            [self goLeft];
            self.leftBtn.highlighted=YES;
            _timer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goLeft) userInfo:nil repeats:YES];
            // 加入RunLoop中
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
            // 加入RunLoop中
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        }
            break;
        default:
            break;
    }
    
}
-(void)buttonTouchEnd:(UIButton *)sender{
    [_timer invalidate];
    [_timer setFireDate:[NSDate distantFuture]];
    _timer=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(pauseAction) withObject:nil afterDelay:0.3];
    
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

#pragma mark - 校准时间
-(void)setUpTimeCalibration{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE HH:mm:ss"];
    NSInteger yearFront =[[dateFormatter stringFromDate:[NSDate date]] integerValue];
    [dateFormatter setDateFormat:@"MM"];
    NSString *monthStr =[dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dayStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *weekStr = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger newWeekStr;
    
    if ([weekStr isEqualToString:NSLocalizedString(@"Monday", nil)]) {
        
        newWeekStr = 01;
    }
    else if ([weekStr isEqualToString:NSLocalizedString(@"Tuesday", nil)]) {
        
        newWeekStr = 02;
    }else if ([weekStr isEqualToString:NSLocalizedString(@"Wednesday", nil)]) {
        
        newWeekStr = 03;
    }else if ([weekStr isEqualToString:NSLocalizedString(@"Thursday", nil)]) {
        
        newWeekStr = 04;
    }else if ([weekStr isEqualToString:NSLocalizedString(@"Friday", nil)]) {
        
        newWeekStr = 05;
    }else if ([weekStr isEqualToString:NSLocalizedString(@"Saturday", nil)]) {
        
        newWeekStr = 06;
    }else{
        newWeekStr = 07;
    }
    _FirstYearByte =  (yearFront &0xff00) >>8;
    
    _SecondYearByte = yearFront &0x00ff;
    _ThirdMonthByte =[monthStr intValue];
    _ForthDayByte = [dayStr intValue];
    _FifthWeekByte = newWeekStr;
    [dateFormatter setDateFormat:@"HH"];
    NSString *hourStr =[dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"mm"];
    NSString *minStr =[dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"ss"];
    NSString *secStr = [dateFormatter stringFromDate:[NSDate date]];
    _SixthHourByte = [hourStr intValue];
    _SeventhMinByte = [minStr intValue];
    _EighthSecByte = [secStr intValue];
    Byte content[] = {_FirstYearByte,_SecondYearByte,_ThirdMonthByte,_ForthDayByte,_FifthWeekByte,_SixthHourByte,_SeventhMinByte,_EighthSecByte};
    
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:76 binaryData:data];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            NSLog(@"校准时间");
            
        }
    }];
}

#pragma mark - 回充
- (IBAction)recharge:(UIButton *)btn {
    Weakself;
   
     if (self.keyCleanBtn.selected==YES){
        if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
            [weakSelf showHudWithString:NSLocalizedString(@"Not operable", nil)];
        }
        
    }
   if ([self.statusLab.text isEqualToString:NSLocalizedString(@"Charging", nil)]) {
        [weakSelf showHudWithString:NSLocalizedString(@"Charging...", nil)];
        
    }
    else if([self.statusLab.text isEqualToString:NSLocalizedString(@"AlongWall", nil)]){
        [weakSelf showHudWithString:NSLocalizedString(@"Not operable", nil)];
    }
    else{
        
        if (self.remoteView.hidden==NO) {
            [weakSelf touchClickBtn];
        }else{
            if (select==0) {
                return;
            }
            select=0;
            if (btn.selected == NO) {
                Byte content[] = {8};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    StrongSelf;
                    if (error) {
                        NSLog(@"响应超时");
                        [weakSelf showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
                        
                    }else{
                        
                        _backdata = [responseMsg getBinaryData];
                        NSLog(@"回充");
                        status =[self convertDataToHexStr:[responseMsg getBinaryData]];
                        [weakSelf getStatus:status];
                        
                    }
                    select=1;
                }];
                
            }
            else{
                
                Byte content[] = {2};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    StrongSelf;
                    if (!error) {
                        NSString *backStatus = [self convertDataToHexStr:[responseMsg getBinaryData]];
                        NSLog(@"待机");
                        self.rechargeBtn.selected = NO;
                        self.rechargeTextBtn.selected = NO;
                        [self loadGifImageUrl:_staybyUrl];
                        if ([backStatus isEqualToString:@"02"]||[backStatus isEqualToString:@"04"]||[backStatus isEqualToString:@"0a"]||[backStatus isEqualToString:@"0c"]) {
                            self.alongWallBtn.enabled=YES;
                            self.alongWallBtn.selected=YES;
                        }else{
                            self.alongWallBtn.selected=NO;
                            self.alongWallBtn.enabled=NO;
                            
                        }
                        
                    }else{
                        
                        NSLog(@"11");
                    }
                    select=1;
                }];
                
            }
        }
        
        self.rechargeBtn.enabled = YES;
        self.rechargeTextBtn.enabled =YES;
    }
}


#pragma mark - 开始清扫
- (IBAction)startClean:(UIButton *)btn {
    Weakself;
    
    if (self.remoteView.hidden==NO) {
        [self touchClickBtn];
    }else{
        
        if (select==0) {
            return;
        }
        select=0;
        if (btn.selected==NO) {
            
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                StrongSelf;
                
                if (!error) {
                    NSLog(@"开始清扫");
                    NSString *status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                    [self getStatus:status];
                    _remoteView.hidden=YES;
                    Byte randomContent[] = {3};
                    NSData *randomData = [NSData dataWithBytes:randomContent length:sizeof(randomContent)];
                    NSData *wallData = [NSData dataWithBytes:randomContent length:sizeof(randomContent)];
                    if ([backData isEqualToData:randomData]) {
                        [weakSelf loadGifImageUrl:_randomUrl];
                    }else if ([backData isEqualToData:wallData]){
                        [weakSelf loadGifImageUrl:_alongWallUrl];
                    }
                    Byte planByte[] = {6};
                    payloadData = [NSData dataWithBytes:planByte length:sizeof planByte];
                    if ([responseMsg.payload isEqualToData:payloadData]){
                        
                        self.startCleanBtn.selected=YES;
                        self.startCleanTextBtn.selected=YES;
                        self.keyCleanBtn.selected=NO;
                        self.keyCleanTextBtn.selected=NO;
                        self.statusLab.text = NSLocalizedString(@"Nav", nil);
//
                        _gifView.hidden=YES;
                        _mapView.hidden=NO;
                    }else{
                        _gifView.hidden=NO;
                        _mapView.hidden=YES;
                    }
                    Byte byte[] = {9};
                    payloadData = [NSData dataWithBytes:byte length:sizeof(byte)];
                    if ([responseMsg.payload isEqualToData:payloadData]) {
                        [weakSelf showHudWithString:NSLocalizedString(@"Charging...", nil)];
                        [weakSelf loadGifImageUrl:_staybyUrl];
                    }
                }
                else{
                    if (btn.enabled==YES) {
                        self.startCleanBtn.selected = NO;
                        self.startCleanTextBtn.selected = NO;
                        self.rechargeTextBtn.enabled=NO;
                        [weakSelf showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
                    }
                }
                select=1;
            }];
            
        }else{
            Byte byte[] = {2};
            NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                StrongSelf;
                if (!error) {
                    status =[self convertDataToHexStr:[responseMsg getBinaryData]];
                    if([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]){
                        [weakSelf loadGifImageUrl:_staybyUrl];
                        self.startCleanBtn.selected=NO;
                        self.startCleanTextBtn.selected=NO;
                        if ([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]||[status isEqualToString:@"0c"]) {
                            self.alongWallBtn.enabled=YES;
                            self.alongWallBtn.selected=YES;
                        }else{
                            self.alongWallBtn.selected=NO;
                            self.alongWallBtn.enabled=NO;
                            
                        }
                    }
                    
                }else{
                    [weakSelf showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
                }
                select=1;
            }];
        }
        
        self.startCleanBtn.enabled = YES;
        self.startCleanTextBtn.enabled =YES;
    }
    
}

-(void)changeCleanBtn{
    if (_startCleanBtn.selected==YES) {
        _startCleanBtn.enabled = YES;
        _startCleanTextBtn.enabled=YES;
    }else if (_rechargeBtn.selected==YES){
        _rechargeBtn.enabled = YES;
        _rechargeTextBtn.enabled=YES;
    }else{
        _keyCleanBtn.enabled = YES;
        _keyCleanTextBtn.enabled=YES;
    }
    
}
#pragma mark - 重点清扫

- (IBAction)keyClean:(UIButton *)btn {
    Weakself;
    if (self.rechargeBtn.selected==YES){
        if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
            [weakSelf showHudWithString:NSLocalizedString(@"Not operable", nil)];
        }
    }
    if ([self.statusLab.text isEqualToString:NSLocalizedString(@"Charging", nil)]) {
        
        [weakSelf showHudWithString:NSLocalizedString(@"Charging...", nil)];
    }
    else if([self.statusLab.text isEqualToString:NSLocalizedString(@"AlongWall", nil)]){
      [weakSelf showHudWithString:NSLocalizedString(@"Not operable", nil)];
    }
    else{
        
        if (self.remoteView.hidden==NO) {
            [self touchClickBtn];
        }else{
            if (select==0) {
                return;
            }
            select=0;
            if (btn.selected==NO) {
                
                Byte content[] = {5};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    StrongSelf;
                    if (!error) {
                        
                        NSLog(@"---%@",[self convertDataToHexStr:[responseMsg getBinaryData]]);
                        NSLog(@"重点");
                        NSString *status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                        [weakSelf getStatus:status];
                        if ([status isEqualToString:@"08"]) {
                            [weakSelf showHudWithString:NSLocalizedString(@"Not operable", nil)];
                        }
                    }
                    
                    else{
                        [weakSelf showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
                    }
                    
                    select=1;
                }];
            }else{
                
                Byte byte[] = {2};
                NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    NSLog(@"---%@",[self convertDataToHexStr:[responseMsg getBinaryData]]);
                    if (!error) {
                        NSLog(@"待机");
                        Byte byte[] = {6};
                        payloadData = [NSData dataWithBytes:byte length:sizeof(byte)];
                        NSString *backStatus = [self convertDataToHexStr:[responseMsg getBinaryData]];
                        
                        self.rechargeBtn.selected = NO;
                        self.rechargeTextBtn.selected = NO;
                        [weakSelf loadGifImageUrl:_staybyUrl];
                        if ([backStatus isEqualToString:@"02"]||[backStatus isEqualToString:@"0a"]||[backStatus isEqualToString:@"0c"]) {
                            self.alongWallBtn.enabled=YES;
                            self.alongWallBtn.selected=YES;
                        }else{
                            self.alongWallBtn.selected=NO;
                            self.alongWallBtn.enabled=NO;
                            
                        }
                        if ([responseMsg.payload isEqualToData:payloadData]){
                            
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                            self.statusLab.text = NSLocalizedString(@"Nav", nil);
                            _gifView.hidden=YES;
                            _mapView.hidden=NO;
                            
                        }
                        else{
                            _gifView.hidden=NO;
                            _mapView.hidden=YES;
                            [weakSelf loadGifImageUrl:_staybyUrl];
                        }
                        
                        
                    }else{
                        
                    }
                    select=1;
                    
                }];
                
            }
        }
    }
}
#pragma mark - 状态
-(void)getStatus:(NSString *)status{
    
    switch ([status intValue]) {
        case 0:
            self.statusLab.text = NSLocalizedString(@"Offline", nil);
            break;
        case 1:
            self.statusLab.text = NSLocalizedString(@"Sleeping", nil);
            self.remoteBtn.selected=YES;
            [self loadGifImageUrl:_staybyUrl];
            
            break;
        case 2:{
            self.statusLab.text = NSLocalizedString(@"Standby", nil);
            self.downBtn.selected=NO;
            self.rightBtn.selected=NO;
            self.leftBtn.selected=NO;
            self.remoteBtn.selected=YES;
            self.remoteBtn.enabled=YES;
            self.rechargeBtn.selected=NO;
            self.rechargeTextBtn.selected=NO;
            self.startCleanBtn.selected=NO;
            self.startCleanTextBtn.selected=NO;
            self.keyCleanBtn.selected=NO;
            self.keyCleanTextBtn.selected=NO;
            self.upBtn.selected=NO;
            //            [_gridView clear];
            [self loadGifImageUrl:_staybyUrl];
        }
            break;
        case 3:
        {
            self.statusLab.text = NSLocalizedString(@"Random", nil);
            self.remoteBtn.selected=NO;
            self.startCleanBtn.selected=YES;
            self.startCleanTextBtn.selected=YES;
            _rechargeBtn.selected = NO;
            _rechargeTextBtn.selected=NO;
            _keyCleanBtn.selected=NO;
            _keyCleanTextBtn.selected=NO;
            [self loadGifImageUrl:_randomUrl];
        }
            break;
        case 4:
            self.statusLab.text = NSLocalizedString(@"AlongWall", nil);
            self.startCleanBtn.selected=YES;
            self.startCleanTextBtn.selected=YES;
            self.alongWallBtn.enabled=NO;
            [self loadGifImageUrl:_alongWallUrl];
            break;
        case 5:{
            self.statusLab.text = NSLocalizedString(@"Spot", nil);
            self.keyCleanBtn.selected=YES;
            self.keyCleanTextBtn.selected=YES;
            _rechargeBtn.selected = NO;
            _rechargeTextBtn.selected=NO;
            self.startCleanBtn.selected=NO;
            self.startCleanTextBtn.selected=NO;
            [self loadGifImageUrl:_spotUrl];
        }
            break;
        case 6:
            self.statusLab.text =  NSLocalizedString(@"Nav", nil);
            self.remoteBtn.selected=NO;
            self.startCleanBtn.selected=YES;
            self.startCleanTextBtn.selected=YES;
            _rechargeBtn.selected = NO;
            _rechargeTextBtn.selected=NO;
            _keyCleanBtn.selected = NO;
            _keyCleanTextBtn.selected=NO;
            break;
        case 8:{
            self.statusLab.text = NSLocalizedString(@"Recharge", nil);
            _keyCleanBtn.selected=NO;
            _keyCleanTextBtn.selected=NO;
            _startCleanBtn.selected=NO;
            _startCleanTextBtn.selected=NO;
            
            [self loadGifImageUrl:_rechargeUrl];
        }
            break;
        case 9:{
            self.statusLab.text = NSLocalizedString(@"Charging", nil);
            self.remoteBtn.enabled=NO;
            [self loadGifImageUrl:_staybyUrl];
            
        }
            break;
        case 10:
            self.statusLab.text = NSLocalizedString(@"Remote", nil);
            break;
        case 11:
            self.statusLab.text=NSLocalizedString(@"Charging", nil);
            [self loadGifImageUrl:_staybyUrl];
            break;
        case 12:
            self.statusLab.text=NSLocalizedString(@"Pause", nil);
            break;
        case 13:
            self.statusLab.text=NSLocalizedString(@"临时重点", nil);
        default:
            break;
    }
    
    
    if ([status isEqualToString:@"06"]) {
        
        _gifView.hidden=YES;
        _mapView.hidden=NO;
    }else{
        _gifView.hidden=NO;
        _mapView.hidden=YES;
    }if ([status isEqualToString:@"03"]||[status isEqualToString:@"04"]||[status isEqualToString:@"05"]||[status isEqualToString:@"08"]) {
        if([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]){
            _alongWallBtn.hidden=YES;
        }else{
            _alongWallBtn.hidden=NO;
        }
        _remoteBtn.enabled=NO;
    }else{
        
        _remoteBtn.enabled=YES;
    }
    [self getDeviceBatteryValue:batteryText Status:[status intValue]];
    if ([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]) {
        if ([status isEqualToString:@"03"]||[status isEqualToString:@"06"]||[status isEqualToString:@"07"]) {
            self.startCleanBtn.selected=YES;
            self.startCleanTextBtn.selected=YES;
        }else{
            self.startCleanBtn.selected=NO;
            self.startCleanTextBtn.selected=NO;
        }
        
        if ([status isEqualToString:@"08"]) {
            self.rechargeBtn.selected=YES;
            self.rechargeTextBtn.selected=YES;
        }else{
            self.rechargeBtn.selected=NO;
            self.rechargeTextBtn.selected=NO;
        }
    }
    if ([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]||[status isEqualToString:@"0c"]) {
        self.remoteBtn.enabled=YES;
    }else{
        self.remoteBtn.enabled=NO;
    }
    if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
        if ([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]||[status isEqualToString:@"0c"]) {
            self.alongWallBtn.enabled=YES;
            self.alongWallBtn.selected=YES;
        }else{
            self.alongWallBtn.selected=NO;
            self.alongWallBtn.enabled=NO;
        }
        
        if ([status isEqualToString:@"05"]) {
            self.keyCleanBtn.selected=YES;
            self.keyCleanTextBtn.selected=YES;
        }
        else{
            self.keyCleanBtn.selected=NO;
            self.keyCleanTextBtn.selected=NO;
            self.rechargeBtn.enabled=YES;
            self.rechargeTextBtn.enabled=YES;
        }
    } if ([status isEqualToString:@"09"]) {
        
    }else if(!([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]||[_statusLab.text isEqualToString:NSLocalizedString(@"Random", nil)])) {
        self.cleanAreaLab.text =@"— —";
        self.cleanTimeLab.text = @"— —";
    }
}
-(void)changeKeyCleanStatus{
    self.keyCleanBtn.enabled=YES;
}

#pragma mark - 下发沿墙模式
- (IBAction)sendAlongWall:(UIButton *)sender {
    if ([status isEqualToString:@"04"]) {
        
        Byte content[] = {2};
        NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
        ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
            
            if (!error) {
                status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                [self getStatus:status];
            }else{
                
            }
        }];
    }else{
        Byte content[] = {4};
        NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
        ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
            if (!error) {
                status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                [self getStatus:status];
            }else{
                
            }
        }];
        
    }
}

#pragma mark - 底部遥控事件
- (IBAction)showRemoteView:(UIButton *)sender {
    self.remoteView.hidden =! self.remoteView.hidden;
    sender.selected=!sender.selected;
    if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
        
    }else{
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
            
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
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
            //          self.leftBtn.selected=NO;
        }else{
            NSLog(@"下发左转失败");
            
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
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
            
            //            self.downBtn.selected=NO;
        }else{
            NSLog(@"下发后退失败");
            
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
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
            //                 self.rightBtn.selected=NO;
            
        }else{
            NSLog(@"下发右转失败");
            
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
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
                
                [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
            }
        }];
    });
    
}
#pragma mark- 放大地图事件
- (IBAction)setBig:(UIButton *)sender {
    if (self.remoteView.hidden==NO) {
        [self touchClickBtn];
    }else{
        if ( self.scrollView.frame.size.width< ( self.scrollView.bounds.size.width*1.5)) {
            self.scrollView.transform =CGAffineTransformScale(self.scrollView.transform,1.1, 1.1);
            
            
        }else{
            self.scrollView.transform =CGAffineTransformScale(self.scrollView.transform,1.0, 1.0);
        }
    }
}
#pragma mark- 缩小地图事件
- (IBAction)setSmall:(UIButton *)sender {
    if (self.remoteView.hidden==NO) {
        [self touchClickBtn];
    }else{
        if ( self.scrollView.frame.size.width > self.scrollView.bounds.size.width) {
            self.scrollView.transform =CGAffineTransformScale(self.scrollView.transform,1/1.09, 1/1.09);
        }else{
            self.scrollView.transform =CGAffineTransformScale(self.scrollView.transform,1.0, 1.0);
        }
    }
}

#pragma mark - 加载本地gif
-(void)loadGifImageUrl:(NSURL *)url{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.gifImageView) {
            self.gifImageView = [[FLAnimatedImageView alloc] init];
            self.gifImageView.contentMode = UIViewContentModeScaleAspectFill;
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

#pragma mark - 查询设备状态
-(void)referDeviceStatus{
    
    Byte content[] = {00};
    Weakself;
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:65 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        StrongSelf;
        if (!error) {
            if (responseMsg) {
                if ([responseMsg getBinaryData].length==9) {
                    
                    NSData *statusData =[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(0, 1)];
                    NSData *battaryData =[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(5, 1)];
                    NSData *errorData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(8, 1)];
                    NSString *statusStr =  [weakSelf convertDataToHexStr:statusData];
                    NSString *dataStr = [weakSelf convertDataToHexStr:battaryData];
                    NSString *errorStr = [weakSelf convertDataToHexStr:errorData];
                    errorStr = [NSString stringWithFormat:@"%lu",strtoul([errorStr UTF8String],0,16)];
                    
                    batteryText = [[NSString stringWithFormat:@"%lu",strtoul([dataStr UTF8String],0,16)]integerValue];
                    [weakSelf getDeviceBatteryValue:batteryText Status:[statusStr integerValue]];
                    
                    switch ([statusStr intValue]) {
                        case 0:
                            self.statusLab.text = NSLocalizedString(@"Offline", nil);
                            break;
                        case 1:{
                            self.statusLab.text = NSLocalizedString(@"Sleeping", nil);
                            [weakSelf loadGifImageUrl:_staybyUrl];
                        }
                            break;
                        case 2:{
                            
                            if (![errorStr isEqualToString:@"0"]) {
                                
                                [weakSelf returnErrorCode:errorStr];
                            }else{
                                self.statusLab.text = NSLocalizedString(@"Standby", nil);
                                self.errorView.hidden=YES;
                                _keyCleanBtn.selected=NO;
                                _keyCleanTextBtn.selected=NO;
                                _startCleanBtn.selected=NO;
                                _startCleanTextBtn.selected=NO;
                                _rechargeBtn.selected=NO;
                                _rechargeTextBtn.selected=NO;
                                [weakSelf loadGifImageUrl:_staybyUrl];
                            }
                        }
                            break;
                        case 3:{
                            self.statusLab.text = NSLocalizedString(@"Random", nil);
                            
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            
                            [weakSelf loadGifImageUrl:_randomUrl];
                        }
                            break;
                        case 4:
                            self.statusLab.text = NSLocalizedString(@"AlongWall", nil);
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            [weakSelf loadGifImageUrl:_alongWallUrl];
                            break;
                        case 5:{
                            self.statusLab.text = NSLocalizedString(@"Spot", nil);
                            self.keyCleanBtn.selected=YES;
                            self.keyCleanTextBtn.selected=YES;
                            self.startCleanBtn.selected=NO;
                            self.startCleanTextBtn.selected=NO;
                            [weakSelf loadGifImageUrl:_spotUrl];
                        }
                            break;
                        case 6:{
                            self.statusLab.text = NSLocalizedString(@"Nav", nil);
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                            
                        }
                            break;
                        case 8:{
                            self.statusLab.text = NSLocalizedString(@"Recharge", nil);
                            self.rechargeBtn.selected=YES;
                            self.rechargeTextBtn.selected=YES;
                            [weakSelf loadGifImageUrl:_rechargeUrl];
                        }
                            break;
                        case 9:
                            self.statusLab.text = NSLocalizedString(@"Charging", nil);
                            [weakSelf loadGifImageUrl:_staybyUrl];
                            break;
                        case 10:
                            self.statusLab.text = NSLocalizedString(@"Remote", nil);
                            break;
                        case 11:
                            self.statusLab.text=NSLocalizedString(@"Charging", nil);
                            [weakSelf loadGifImageUrl:_staybyUrl];
                            break;
                        case 12:
                            self.statusLab.text=NSLocalizedString(@"Pause", nil);
                            break;
                        case 13:
                            self.statusLab.text=NSLocalizedString(@"临时重点", nil);
                            
                        default:
                            break;
                            
                    }
                    
                    if (!([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]||[_statusLab.text isEqualToString:NSLocalizedString(@"Random", nil)])) {
                        self.cleanAreaLab.text =@"— —";
                        self.cleanTimeLab.text = @"— —";
                    }
                    
                    if ([statusStr isEqualToString:@"06"]) {
                        
                        _gifView.hidden=YES;
                        _mapView.hidden=NO;
                    }else{
                        _gifView.hidden=NO;
                        _mapView.hidden=YES;
                    }if ([statusStr isEqualToString:@"03"]||[statusStr isEqualToString:@"04"]||[statusStr isEqualToString:@"05"]||[statusStr isEqualToString:@"08"]) {
                        _remoteBtn.enabled=NO;
                        
                    }else{
                        _remoteBtn.enabled=YES;
                        
                    }
                    
                    if ([statusStr isEqualToString:@"02"]||[statusStr isEqualToString:@"0a"]||[statusStr isEqualToString:@"0c"]) {
                        self.remoteBtn.enabled=YES;
                        self.remoteBtn.selected=YES;
                    }else{
                        self.remoteBtn.enabled=NO;
                        self.remoteBtn.selected=NO;
                    }if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
                        if ([statusStr isEqualToString:@"09"]||[statusStr isEqualToString: @"0b"]){
                            self.startCleanBtn.selected=NO;
                            self.startCleanTextBtn.selected=NO;
                            self.rechargeBtn.selected=NO;
                            self.rechargeTextBtn.selected=NO;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                        }if ([statusStr isEqualToString:@"02"]||[statusStr isEqualToString:@"0a"]||[statusStr isEqualToString:@"0c"]) {
                            self.alongWallBtn.enabled=YES;
                            self.alongWallBtn.selected=YES;
                        }else{
                            self.alongWallBtn.selected=NO;
                            self.alongWallBtn.enabled=NO;
                            
                        }
                    }
                    
                }
                
            }else{
                //查询设备状态失败
            }
        }
    }];
}

//#pragma mark - 获取历史清扫记录
//-(void)getHistoryCleanRecord{
//    self.dataArrM = [NSMutableArray array];
//    NSString *serviceName;
//    __block  NSMutableArray *cleanArrM =[NSMutableArray array];
//    ACMsg *msg = [ACMsg msgWithName:@"searchCleanRealTime"];
//    if ([self.subDomain isEqualToString:X785SubDomain]){
//        serviceName = Service_Name_X785;
//    }else if ([self.subDomain isEqualToString:X787SubDomain]){
//        serviceName = Service_Name_X787;
//    }
//    else if ([self.subDomain isEqualToString:X800SubDomain]){
//        serviceName = Service_Name_X800;
//    }
//    else if ([self.subDomain isEqualToString:X900SubDomain]){
//        serviceName=Service_Name_X900;
//    }
//    Weakself;
//    CleanDataModel *cleanDataModel=[[CleanDataModel alloc]init];
//    [msg putInteger:@"device_id" value:_deviceID];
//    _mapData  = [[NSMutableData alloc]init];
//    [ACloudLib sendToService:serviceName version:1 msg:msg callback:^(ACMsg *responseMsg, NSError *error) {
//        StrongSelf;
//        if (!error) {
//            NSDictionary *data =[responseMsg getObjectData];
//            cleanArrM= data[@"data"];
//            NSDictionary *cleanDic = [[NSDictionary alloc]init];
//            for (int i = 0; i<cleanArrM.count; i++) {
//                cleanDic = cleanArrM[i];
//                int dataNum = [cleanDic[@"package_num"]intValue];
//                NSLog(@"%d",dataNum);
//                int dataId =[cleanDic[@"package_id"]intValue];
//                NSString *cleanStr= cleanDic[@"clean_data"];
//                NSMutableData *temp;
//                NSMutableData *cleanData = [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                temp = cleanData;
//                [_mapData appendData:cleanData];
//                NSLog(@"%@",_mapData);
//                if (dataId==dataNum) {
//                    [_dataArrM addObject:_mapData];
//                    _mapData = [[NSMutableData alloc]init];
//                }
//            }
//            for (int i =0; i<_dataArrM.count; i++) {
//                NSInteger X;
//                NSInteger Y;
//                NSData *data = _dataArrM[i];
//                Byte *mapByte = (Byte *)[data bytes];
//                NSInteger type;   //数据类型
//                NSInteger lenth; //数据宽度
//                if ([data length]>0) {
//                    cleanArea = ((mapByte[0]<<8)+mapByte[1]);
//                    cleanTime = (mapByte[2]<<8)+mapByte[3];
//                    float cleanAreaNumber = cleanArea/100.0;
//                    type =mapByte[4];
//                    if (type==1) {
//                        
//                        int16_t originX =(int16_t)((mapByte[5]<<8)+mapByte[6]);
//                        int16_t originY =(int16_t)((mapByte[7]<<8)+mapByte[8]);
//                        //                            NSLog(@"%d  %d",originX,originY);
//                        lenth =((mapByte[9]<<8)+mapByte[10]);
//                        NSInteger model; //属性类型
//                        NSInteger mapCount; //长度
//                        NSInteger temp=0;
//                        NSInteger index=0;
//                        for (int i=11; i<[data length]; i+=2) {
//                            model = mapByte[i];
//                            mapCount=mapByte[i+1];
//                            for (int j=0; j<mapCount; j++) {
//                                temp++;
//                                if (temp>lenth) {
//                                    index++;
//                                    temp=0;
//                                }
//                                X = originX+temp;
//                                Y = originY+index;
//                                //                                    NSLog(@"%d  %d",X,Y);
//                                [_slamView addGridByPoint:CGPointMake(X, Y) model:model];
//                            }
//                        }
//                        if ([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]) {
//                            
//                            self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
//                            self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
//                        }
//                        else{
//                            self.cleanAreaLab.text =@"— —";
//                            self.cleanTimeLab.text = @"— —";
//                        }
//                    }
//                }
//            }
//        }else{
//            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
//        }
//    }];
//            
//            //
//            //                for (int j = dataId; j<dataNum; j++) {
//            //
//            //                }
//            //                if (dataNum!=1) {
//            //                      NSString *cleanStr= cleanDic[@"clean_data"];
//            //                    NSLog(@"%@",cleanStr);
//            //                }
//            //            }
//            
//            //            if (self.dataArrM.count>0) {
//            //                for (int i =0 ; i<_dataArrM.count; i++) {
//            //                    cleanDic = _dataArrM[i];
//            //
//            //                    int dataNum = [cleanDic[@"package_num"]intValue];
//            //                    NSLog(@"%d",dataNum);
//            //                    int dataId =[cleanDic[@"package_id"]intValue];
//            //                    NSLog(@"%d",dataId);
//            //                    if (dataNum!=1) {
//            //                        for (int j = dataId; j<=dataNum; j++) {
//            //                             NSString *cleanStr= cleanDic[@"clean_data"];
//            //                            NSMutableData *cleanData = [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//            //                            NSLog(@"%@",cleanData);
//            //                        }
//            //                    }
//            ////                     NSMutableData *cleanData = [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//            ////                    for (int j=dataId; j<=dataNum; j++) {
//            //////                        temp = cleanData;
//            //////                        [otherData appendData:temp];
//            //////                        _mapData = otherData;
//            //////                        isAppend=YES;
//            ////                    }
//            //
//            ////                    if (dataNum==dataId) {
//            ////                    _mapData = cleanData;
//            ////                    NSInteger X;
//            ////                    NSInteger Y;
//            ////                    Byte *mapByte = (Byte *)[cleanData bytes];
//            ////                    NSInteger type;   //数据类型
//            ////                    NSInteger lenth; //数据宽度
//            ////                    if ([cleanData length]>0) {
//            ////                        cleanArea = ((mapByte[0]<<8)+mapByte[1]);
//            ////                        cleanTime = (mapByte[2]<<8)+mapByte[3];
//            ////                        float cleanAreaNumber = cleanArea/100.0;
//            ////                        type =mapByte[4];
//            ////                        if (type==1) {
//            ////
//            ////                            int16_t originX =(int16_t)((mapByte[5]<<8)+mapByte[6]);
//            ////                            int16_t originY =(int16_t)((mapByte[7]<<8)+mapByte[8]);
//            ////                            lenth =((mapByte[9]<<8)+mapByte[10]);
//            ////                            NSInteger model; //属性类型
//            ////                            NSInteger mapCount; //长度
//            ////                            NSInteger temp=0;
//            ////                            NSInteger index=0;
//            ////                            for (int i=11; i<[cleanData length]; i+=2) {
//            ////                                model = mapByte[i];
//            ////                                mapCount=mapByte[i+1];
//            ////                                for (int j=0; j<mapCount; j++) {
//            ////                                    temp++;
//            ////                                    if (temp>lenth) {
//            ////                                        index++;
//            ////                                        temp=0;
//            ////                                    }
//            ////                                    X = originX+temp;
//            ////                                    Y = originY+index;
//            ////                                    //                                    NSLog(@"%d  %d",X,Y);
//            ////                                    [_slamView addGridByPoint:CGPointMake(X, Y) model:model];
//            ////                                }
//            ////                            }
//            ////                            if ([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]) {
//            //////
//            ////                                self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
//            ////                                self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
//            ////                            }
//            ////                            else{
//            ////                                self.cleanAreaLab.text =@"— —";
//            ////                                self.cleanTimeLab.text = @"— —";
//            ////                            }
//            ////                        }
//            ////                    }
//            ////                }
//            //            }
//            //        }
//        
//    
//}
#pragma mark - 获取历史清扫记录
-(void)getHistoryCleanRecord{
    NSString *serviceName;
    ACMsg *msg = [ACMsg msgWithName:@"searchCleanRealTime"];
    if ([self.subDomain isEqualToString:X785SubDomain]){
        serviceName = Service_Name_X785;
    }else if ([self.subDomain isEqualToString:X787SubDomain]){
        serviceName = Service_Name_X787;
    }
    else if ([self.subDomain isEqualToString:X800SubDomain]){
        serviceName = Service_Name_X800;
    }

    [msg putInteger:@"device_id" value:_deviceID];
    [ACloudLib sendToService:serviceName version:1 msg:msg callback:^(ACMsg *responseMsg, NSError *error) {

        if (!error) {

            NSDictionary *data =[responseMsg getObjectData];
            self.dataArrM = data[@"data"];
            NSDictionary *cleanDic = [[NSDictionary alloc]init];

            if (self.dataArrM.count>0) {
                for (int i =0 ; i<self.dataArrM.count; i++) {
                    cleanDic = _dataArrM[i];
                    NSString *cleanStr= cleanDic[@"clean_data"];
                    NSData *cleanData = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];

                    Byte *mapByte = (Byte *)[cleanData bytes];
                    for (int i =4; i<[cleanData length]; i+=4) {
                        int16_t X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                        int16_t Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                        [_gridView addGridByPoint:CGPointMake(-X, Y)];
                    }
                    if ([cleanData length]>0) {
                        cleanArea = ((mapByte[0]<<8)+mapByte[1]);
                        cleanTime = (mapByte[2]<<8)+mapByte[3];
                        float cleanAreaNumber = cleanArea/100.0;

                        if ([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]) {

                            self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
                            self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
                        }
                        else{
                            self.cleanAreaLab.text =@"— —";
                            self.cleanTimeLab.text = @"— —";
                        }
                    }
                }
            }
        }else{
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
        }


    }];

}
#pragma mark - 实时地图清扫
-(void)listenMapValueChange{

    ACObject *primaryKey = [[ACObject alloc] init];
    [primaryKey putInteger:@"device_id" value:_deviceID];
    [ACClassDataManager subscribeClass:@"clean_realtime" primaryKey:primaryKey callback:^(NSError *error) {

        if (!error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [ACClassDataManager setClassMessageHandler:^(NSString *className, ACClassDataOperationType opType, ACObject *payload) {
                    NSString *cleanStr =[payload get:@"clean_data"];
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    Byte *mapByte = (Byte *)[data bytes];
                    if ([data length]>0) {
                        cleanArea = ((mapByte[0]<<8)+mapByte[1]);
                        cleanTime = (mapByte[2]<<8)+mapByte[3];
                        float cleanAreaNumber = cleanArea/100.0;

                        if ([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]) {

                            self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
                            self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
                        }
                        else{
                            self.cleanAreaLab.text =@"— —";
                            self.cleanTimeLab.text = @"— —";
                        }
                    }
                    for (int i =4; i<[data length]; i+=4) {
                        int16_t X = (int16_t)((mapByte[i]<<8)+mapByte[i+1]);
                        int16_t Y =(int16_t)((mapByte[i+2]<<8)+mapByte[i+3]);
                        [_gridView addGridByPoint:CGPointMake(-X, Y)];

                    }

                }];
            });

        }else{
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
        }
    }];
}
//#pragma mark - 实时地图清扫
//-(void)listenMapValueChange{
//
//    ACObject *primaryKey = [[ACObject alloc] init];
//    [primaryKey putInteger:@"device_id" value:_deviceID];
//    [ACClassDataManager subscribeClass:@"clean_realtime" primaryKey:primaryKey callback:^(NSError *error) {
//
//        if (!error) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                [ACClassDataManager setClassMessageHandler:^(NSString *className, ACClassDataOperationType opType, ACObject *payload) {
//                    NSString *cleanStr =[payload get:@"clean_data"];
//                    NSInteger X;
//                    NSInteger Y;
//                    NSData *data = [[NSData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//                    NSLog(@"%@",data);
//                    Byte *mapByte = (Byte *)[data bytes];
//                    NSInteger type;   //数据类型
//                    NSInteger lenth; //数据宽度
//                    if ([data length]>0) {
//                        cleanArea = ((mapByte[0]<<8)+mapByte[1]);
//                        cleanTime = (mapByte[2]<<8)+mapByte[3];
//                        float cleanAreaNumber = cleanArea/100.0;
//                        type =mapByte[4];
//                        if (type==1) {
//                            int16_t originX =(int16_t)((mapByte[5]<<8)+mapByte[6]);
//                            int16_t originY =(int16_t)((mapByte[7]<<8)+mapByte[8]);
//                            //                            NSLog(@"%d  %d",originX,originY);
//                            lenth =((mapByte[9]<<8)+mapByte[10]);
//                            NSInteger model; //属性类型
//                            NSInteger mapCount; //长度
//                            NSInteger temp=0;
//                            NSInteger index=0;
//                            for (int i=11; i<[data length]; i+=2) {
//                                model = mapByte[i];
//                                mapCount=mapByte[i+1];
//                                for (int j=0; j<mapCount; j++) {
//                                    temp++;
//                                    if (temp>lenth) {
//                                        index++;
//                                        temp=0;
//                                    }
//                                    X = originX+temp;
//                                    Y = originY+index;
//                                    //                                    NSLog(@"%d  %d",X,Y);
//                                    [_slamView addGridByPoint:CGPointMake(X, Y) model:model];
//                                    NSLog(@"%d  %d",X,Y);
//                                }
//                            }
//                            if ([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]) {
//
//                                self.cleanAreaLab.text =[NSString stringWithFormat:@"%@m²", [self formatFloat:cleanAreaNumber]];
//                                self.cleanTimeLab.text = [NSString stringWithFormat:@"%.0fmin",cleanTime/60.0];
//                            }
//                            else{
//                                self.cleanAreaLab.text =@"— —";
//                                self.cleanTimeLab.text = @"— —";
//                            }
//                        }
//                    }
//                }];
//            });
//
//        }else{
//            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
//        }
//    }];
//}

#pragma mark - 状态属性监听
-(void)listenPropertyValueChange{
    [ACDeviceDataManager subscribePropDataWithSubDomain:_subDomain deviceId:_deviceID callback:^
     (NSError *error) {
         
         if (!error) {
             
             [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                 cleanModel = [[properties get:@"work_pattern"] stringValue];
                 
                 NSString *errorCode = [properties get:@"error_info"];
                 NSInteger batteryText = [[properties get:@"battery_level"]integerValue];
                 [self getDeviceBatteryValue:batteryText Status:[cleanModel integerValue]];
                 switch ([cleanModel intValue]) {
                     case 0:
                         self.statusLab.text = NSLocalizedString(@"Offline", nil);
                         break;
                     case 1:
                         self.statusLab.text = NSLocalizedString(@"Sleeping", nil);
                         self.remoteBtn.selected=YES;
                         [self loadGifImageUrl:_staybyUrl];
                         
                         break;
                     case 2:{
                         self.statusLab.text = NSLocalizedString(@"Standby", nil);
                         self.rechargeBtn.selected=NO;
                         self.rechargeTextBtn.selected=NO;
                         self.keyCleanBtn.selected=NO;
                         self.keyCleanTextBtn.selected=NO;
                         self.downBtn.selected=NO;
                         self.rightBtn.selected=NO;
                         self.leftBtn.selected=NO;
                         self.remoteBtn.selected=YES;
                         self.remoteBtn.enabled=YES;
                         
                         self.startCleanBtn.selected=NO;
                         self.startCleanTextBtn.selected=NO;
                         
                         self.upBtn.selected=NO;
                         //                            [_gridView clear];
                         [self loadGifImageUrl:_staybyUrl];
                     }
                         break;
                     case 3:
                     {
                         self.statusLab.text = NSLocalizedString(@"Random", nil);
                         self.remoteBtn.selected=NO;
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                         _rechargeBtn.selected = NO;
                         _rechargeTextBtn.selected=NO;
                         _keyCleanBtn.selected=NO;
                         _keyCleanTextBtn.selected=NO;
                         [self loadGifImageUrl:_randomUrl];
                     }
                         break;
                     case 4:
                         self.statusLab.text = NSLocalizedString(@"AlongWall", nil);
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                         self.alongWallBtn.enabled=NO;
                         [self loadGifImageUrl:_alongWallUrl];
                         break;
                     case 5:{
                         self.statusLab.text = NSLocalizedString(@"Spot", nil);
                         self.keyCleanBtn.selected=YES;
                         self.keyCleanTextBtn.selected=YES;
                         _rechargeBtn.selected = NO;
                         _rechargeTextBtn.selected=NO;
                         self.startCleanBtn.selected=NO;
                         self.startCleanTextBtn.selected=NO;
                         [self loadGifImageUrl:_spotUrl];
                     }
                         break;
                     case 6:
                         self.statusLab.text =  NSLocalizedString(@"Nav", nil);
                         self.remoteBtn.selected=NO;
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                         _rechargeBtn.selected = NO;
                         _rechargeTextBtn.selected=NO;
                         _keyCleanBtn.selected = NO;
                         _keyCleanTextBtn.selected=NO;
                         break;
                     case 8:{
                         self.statusLab.text = NSLocalizedString(@"Recharge", nil);
                         _rechargeBtn.selected = YES;
                         _rechargeTextBtn.selected= YES;
                         _keyCleanBtn.selected=NO;
                         _keyCleanTextBtn.selected=NO;
                         _startCleanBtn.selected=NO;
                         _startCleanTextBtn.selected=NO;
                         
                         [self loadGifImageUrl:_rechargeUrl];
                     }
                         break;
                     case 9:{
                         self.statusLab.text = NSLocalizedString(@"Charging", nil);
                         self.remoteBtn.enabled=NO;
                         [self loadGifImageUrl:_staybyUrl];
                         
                     }
                         break;
                     case 10:
                         self.statusLab.text = NSLocalizedString(@"Remote", nil);
                         break;
                     case 11:
                         self.statusLab.text=NSLocalizedString(@"Charging", nil);
                         [self loadGifImageUrl:_staybyUrl];
                         break;
                     case 12:
                         self.statusLab.text=NSLocalizedString(@"Pause", nil);
                         break;
                     case 13:
                         self.statusLab.text=NSLocalizedString(@"临时重点", nil);
                         
                     default:
                         break;
                 }
                 if ([cleanModel isEqualToString:@"9"]) {
                     
                 }else if(!([_statusLab.text isEqualToString:NSLocalizedString(@"Nav", nil)]||[_statusLab.text isEqualToString:NSLocalizedString(@"Random", nil)])) {
                     self.cleanAreaLab.text =@"— —";
                     self.cleanTimeLab.text = @"— —";
                 }
                 if ([cleanModel isEqualToString:@"6"]) {

                     _gifView.hidden=YES;
                     _mapView.hidden=NO;
                 }else{
                     _gifView.hidden=NO;
                     _mapView.hidden=YES;
                 }
                 if ([cleanModel isEqualToString:@"3"]||[cleanModel isEqualToString:@"4"]||[cleanModel isEqualToString:@"5"]||[cleanModel isEqualToString:@"8"]) {
                     if([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]){
                         _alongWallBtn.hidden=YES;
                     }else{
                         _alongWallBtn.hidden=NO;
                     }
                     _remoteBtn.enabled=NO;
                 }else{
                     _remoteBtn.enabled=YES;
                 }
                 if ([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]) {
                     if ([cleanModel isEqualToString:@"3"]||[cleanModel isEqualToString:@"6"]||[cleanModel isEqualToString:@"7"]) {
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                     }else{
                         self.startCleanBtn.selected=NO;
                         self.startCleanTextBtn.selected=NO;
                     }if ([cleanModel isEqualToString:@"5"]) {
                         self.keyCleanBtn.selected=YES;
                         self.keyCleanTextBtn.selected=YES;
                     }else{
                         self.keyCleanBtn.selected=NO;
                         self.keyCleanTextBtn.selected=NO;
                         
                     }
                     
                     if ([cleanModel isEqualToString:@"8"]) {
                         self.rechargeBtn.selected=YES;
                         self.rechargeTextBtn.selected=YES;
                     }else{
                         self.rechargeBtn.selected=NO;
                         self.rechargeTextBtn.selected=NO;
                     }
                 }
                 if ([cleanModel isEqualToString:@"2"]||[cleanModel isEqualToString:@"10"]||[cleanModel isEqualToString:@"12"]) {
                     self.remoteBtn.enabled=YES;
                 }else{
                     self.remoteBtn.enabled=NO;
                 } if ([cleanModel isEqualToString:@"2"]||[cleanModel isEqualToString:@"10"]||[cleanModel isEqualToString:@"12"]) {
                     self.alongWallBtn.enabled=YES;
                 }else{
                     self.alongWallBtn.enabled=NO;
                 }if ([self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
                     if ([cleanModel isEqualToString:@"9"]||[cleanModel isEqualToString: @"11"]){
                         self.startCleanBtn.selected=NO;
                         self.startCleanTextBtn.selected=NO;
                         self.rechargeBtn.selected=NO;
                         self.rechargeTextBtn.selected=NO;
                         self.keyCleanBtn.selected=NO;
                         self.keyCleanTextBtn.selected=NO;
                         
                     }
                     if ([cleanModel isEqualToString:@"5"]||[cleanModel isEqualToString:@"9"]||[cleanModel isEqualToString:@"11"]) {
                         
                     } else {
                         self.rechargeBtn.enabled=YES;
                         self.rechargeTextBtn.enabled=YES;
                     }
                     if ([cleanModel isEqualToString:@"2"]||[cleanModel isEqualToString:@"10"]||[cleanModel isEqualToString:@"12"]) {
                         self.alongWallBtn.enabled=YES;
                         self.alongWallBtn.selected=YES;
                     }else{
                         self.alongWallBtn.selected=NO;
                         self.alongWallBtn.enabled=NO;
                         
                     }
                 }
                 
                 if ([errorCode integerValue]!=0) {
                     [self returnErrorCode:errorCode];
                 }else{
                     _errorView.hidden=YES;
                 }
                 
             }];
         }
     }];
    
}
#pragma mark - 获取电池电量
-(void)getDeviceBatteryValue:(NSInteger)value Status:(NSInteger)status{
    
    if (value<96 &&(status==9 ||status==11)) {
        [_batteryBtn setImage:[UIImage imageNamed:@"充电中"] forState:UIControlStateNormal];
    }else if (value>=96 &&(status==9 ||status==11)){
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
#pragma mark - 异常信息
-(void)returnErrorCode:(NSString *)code{
    _errorView.hidden=NO;
    self.statusLab.text = NSLocalizedString(@"Abnormal", nil);
    switch ([code integerValue]) {
        case 1:
            _errorLab.text = NSLocalizedString(@"Bumper Error", nil);
            break;
        case 17:
            _errorLab.text = NSLocalizedString(@"OBS Assembly Error", nil);
            break;
        case 18:
            _errorLab.text = NSLocalizedString(@"WALL EDGING SENSORS Assembly Error", nil);
            break;
        case 33:
            _errorLab.text = NSLocalizedString(@"Cliff Sensor Assembly Error", nil);
            break;
        case 34:
            _errorLab.text = NSLocalizedString(@"Machine Hung Up", nil);
            break;
        case 49:
            _errorLab.text = NSLocalizedString(@"Nose Wheel Error", nil);
            break;
        case 65:
            _errorLab.text = NSLocalizedString(@"Left Side Brush Error", nil);
            break;
        case 66:
            _errorLab.text = NSLocalizedString(@"Right Side Brush Error", nil);
            break;
        case 67:
            _errorLab.text =NSLocalizedString(@"Side Brush Error", nil);
            break;
        case 81:
            _errorLab.text = NSLocalizedString(@"Left Wheel Error", nil);
            break;
        case 82:
            _errorLab.text = NSLocalizedString(@"Right Wheel Error", nil);
            break;
        case 97:
            _errorLab.text = NSLocalizedString(@"Roll Wheel Error", nil);
            break;
        case 113:
            _errorLab.text = NSLocalizedString(@"Air Fan Error", nil);
            break;
        case 129:
            _errorLab.text = NSLocalizedString(@"Water Pump Error", nil);
            break;
        case 130:
            _errorLab.text = NSLocalizedString(@"Air Aump Error", nil);
            break;
        case 145:
            _errorLab.text = NSLocalizedString(@"Dust Bin Error", nil);
            break;
        case 146:
            _errorLab.text = NSLocalizedString(@"Water Tank Error", nil);
            break;
        case 147:
            _errorLab.text = NSLocalizedString(@"HEPA Filter Error", nil);
            break;
        case 161:
            _errorLab.text = NSLocalizedString(@"Battery Error", nil);
            break;
        case 177:
            _errorLab.text = NSLocalizedString(@"GRYO Assembly Error", nil);
            break;
        case 193:
            _errorLab.text = NSLocalizedString(@"Radar Assembly Error", nil);
            break;
        case 194:
            _errorLab.text = NSLocalizedString(@"Camera Assembly Error", nil);
            break;
        case 209:
            _errorLab.text = NSLocalizedString(@"Route Error", nil);
            break;
        case 225:
            _errorLab.text = NSLocalizedString(@"Other Error", nil);
            break;
        case 241:
            _errorLab.text = NSLocalizedString(@"Other Error", nil);
            break;
        default:
            _errorLab.text = NSLocalizedString(@"Other Error", nil);
            break;
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
            NSLog(@"上传实时信息失败");
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
        StrongSelf;
        if (!error) {
            
        }else{
            
        }
    }];
}
-(void)returnData:(NSData *)data{
    backData = data;
}

-(void)returnName:(NSString *)name{
    _deviceName=name;
}
#pragma mark - 按钮事件与点击空白冲突
-(void)touchClickBtn{
    _remoteView.hidden=YES;
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
    
    if (_remoteView.hidden==NO) {
        if (_remoteBtn.selected==YES) {
            _remoteBtn.selected=NO;
        }else{
            _remoteBtn.selected=YES;
        }
    }
   
    if (![self.subDomain isEqualToString:X800SubDomain]||[self.subDomain isEqualToString:X900SubDomain]) {
        if  ([self.statusLab.text isEqualToString:NSLocalizedString(@"Remote", nil)]) {
            Byte content[] = {2};
            NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                if (!error) {
                     _remoteView.hidden=YES;
                
                }else{
                    
                }
            }];
        }
        
    }
}
#pragma mark - 预约按钮事件
- (IBAction)reserView:(UIButton *)sender {
    
    ZJMAddReserVC *timerReserVC = [[ZJMAddReserVC alloc]init];
    timerReserVC.title = NSLocalizedString(@"Regular Clocking", nil);
    timerReserVC.subDomain =self.subDomain;
    [self.navigationController pushViewController:timerReserVC animated:YES];
}

#pragma mark - scrollView点击事件
- (void)tapAction:(UIGestureRecognizer *)tap {
    
    if (_scrollView.zoomScale>1.35&&_scrollView.zoomScale<=1.5) {
        [_scrollView setContentOffset:CGPointMake(_gridView.center.x*_scrollView.zoomScale*1.055, _gridView.center.y*_scrollView.zoomScale*1.06)  animated:NO];
    }else if(_scrollView.zoomScale>1.0&&_scrollView.zoomScale<1.2){
        [_scrollView setContentOffset:CGPointMake(_gridView.center.x*_scrollView.zoomScale*1.02, _gridView.center.y*_scrollView.zoomScale*1.03)  animated:NO];
    }else if(_scrollView.zoomScale>1.2&&_scrollView.zoomScale<1.35){
        [_scrollView setContentOffset:CGPointMake(_gridView.center.x*_scrollView.zoomScale*1.04, _gridView.center.y*_scrollView.zoomScale*1.03)  animated:NO];
    }else{
        [_scrollView setContentOffset:_gridView.center animated:NO];
    }
}



#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _mapView;
}
#pragma mark - 导航栏按钮事件
-(void)pushSettingVC:(UIButton *)sender{
    if ([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]) {
        ZJMX785SettingVC *settingVC = [[ZJMX785SettingVC alloc]init];
        settingVC.title = NSLocalizedString(@"Setting", nil);
        settingVC.delegate = self;
        settingVC.deviceID = _deviceID;
        settingVC.deviceName = _deviceName;
        settingVC.deviceStatus = cleanModel;
        
        settingVC.subDomain=_subDomain;
        settingVC.physicalDeviceId = _physicalDeviceId;
        settingVC.isManager = _isManager;
        [self.navigationController pushViewController:settingVC animated:YES];
    }else{
        ZJMSettingVC *settingVC = [[ZJMSettingVC alloc]init];
        settingVC.title = NSLocalizedString(@"Setting", nil);
        settingVC.delegate = self;
        settingVC.deviceID = _deviceID;
        settingVC.deviceName = _deviceName;
        settingVC.deviceStatus = cleanModel;
        
        settingVC.subDomain=_subDomain;
        settingVC.physicalDeviceId = _physicalDeviceId;
        settingVC.isManager = _isManager;
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
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
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2);
    return zoomRect;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

@end

