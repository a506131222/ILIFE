
//  ZJMRechargeVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/7.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMX786RechargeVC.h"
#import "ZJMSettingVC.h"
#import "ZJMAddReserVC.h"
#import "GridView.h"
#import "SlamView.h"
#import "ZJMX785SettingVC.h"

@interface ZJMX786RechargeVC ()<X785SettingDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gifView;
@property (weak, nonatomic) IBOutlet UIButton *rechargeBtn;
@property (weak, nonatomic) IBOutlet UIButton *rechargeTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *startCleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *startCleanTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyCleanBtn;
@property (weak, nonatomic) IBOutlet UIButton *keyCleanTextBtn;
@property (strong,nonatomic) FLAnimatedImageView *gifImageView;
@property (nonatomic,strong) UIButton *selectedBtn;
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
@property (atomic,assign)    CGPoint currentPoint;
@property (nonatomic,strong)NSTimer *goTimer;
@property (nonatomic,strong)NSTimer *rightTimer;
@property (nonatomic,strong)NSTimer *leftTimer;
@property (nonatomic,strong)NSURL *randomUrl;
@property (nonatomic,strong)NSURL *rechargeUrl;
@property (nonatomic,strong)NSURL *spotUrl;
@property (nonatomic,strong)NSURL *staybyUrl;
@property (nonatomic,strong)NSURL *cleanUrl;
@property (nonatomic,strong)NSURL *alongWallUrl;
@property (nonatomic,assign)BOOL mode;

@property (nonatomic,strong) UITapGestureRecognizer *secondTap;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic,copy)NSData *backdata;
@property (nonatomic,copy) NSString *statusStr;

@end

@implementation ZJMX786RechargeVC
{
    NSData *backData;
    Byte cleanContent[1];
    Byte dataByte[50];
    NSInteger batteryText;
    NSString *cleanModel;
    NSData *payloadData;
    ACDeviceMsg *deviceMsg;
    
    Byte Byte[50];
    uint16_t cleanArea;
    uint16_t cleanTime;
    NSString *status;
    int select;
    int click;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _mode = [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
    //    [self listenMapValueChange];
    [self listenPropertyValueChange];
    self.dataArrM = [NSMutableArray array];
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
    _remoteView.hidden=YES;
    _errorView.hidden=YES;
    _remoteBtn.enabled=NO;
    [self.view becomeFirstResponder];
    [self setRightBtn];
    [self setUpTimeCalibration];
    [self updateRealTime];
    [self.rechargeTextBtn setTitle:NSLocalizedString(@"Recharge", nil) forState:UIControlStateNormal];
    [self.rechargeTextBtn setTitle:NSLocalizedString(@"Recharge", nil) forState:UIControlStateSelected];
    [self.startCleanTextBtn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    [self.startCleanTextBtn setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateSelected];
    [self.keyCleanTextBtn setTitle:NSLocalizedString(@"Spot Cleaning", nil) forState:UIControlStateNormal];
    [self.keyCleanTextBtn setTitle:NSLocalizedString(@"Spot Cleaning", nil) forState:UIControlStateSelected];
    self.rechargeTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.startCleanTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.keyCleanTextBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_batteryBtn setImage:[UIImage imageNamed:@"电量满格"] forState:UIControlStateNormal];
    [self.upBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self.upBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
    [self.downBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self.downBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
    [self.leftBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self.leftBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
    [self.rightBtn addTarget:self action:@selector(buttonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self.rightBtn addTarget:self action:@selector(buttonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
    CGAffineTransform transform = CGAffineTransformMakeRotation(-45 * M_PI/180.0);
    [self.remoteView setTransform:transform];
    self.randomUrl = [[NSBundle mainBundle] URLForResource:@"随机清扫动态" withExtension:@"gif"];
    self.rechargeUrl = [[NSBundle mainBundle] URLForResource:@"回充动态" withExtension:@"gif"];
    self.spotUrl = [[NSBundle mainBundle] URLForResource:@"重点清扫动态" withExtension:@"gif"];
    self.staybyUrl = [[NSBundle mainBundle] URLForResource:@"待机动态" withExtension:@"gif"];
    self.cleanUrl = [[NSBundle mainBundle] URLForResource:@"规划清扫动态" withExtension:@"gif"];
    self.alongWallUrl = [[NSBundle mainBundle] URLForResource:@"沿墙动态" withExtension:@"gif"];
    select=1;
    click = 1;
}

#pragma mark - 默认规划/随机模式
-(void)sendCleanData:(NSData *)data{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        
        if ([self.subDomain isEqualToString:X430SubDomain]) {
            //默认随机
            cleanContent[0]= 3;
        }
        else {
            //默认规划
            cleanContent[0] = 6;
        }
    }else{
        //
        // 1为随机 0为规划
        if (_mode ==1) {
            cleanContent[0]= 3;
        }else{
            
            cleanContent[0] = 6;
        }
    }
    data = [NSData dataWithBytes:cleanContent length:sizeof(cleanContent)];
    deviceMsg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
}
#pragma mark - 查询预约
-(void)queryReser{
    
    if (self.remoteView.hidden==NO) {
        [self touchClickBtn];
    }else{
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
                            self.reserBtn.selected=YES;
                            break;
                        }else{
                            self.reserBtn.selected=NO;
                            
                        }
                    }
                }
            }
        }];
    }
}

#pragma mark - 长按遥控按钮
-(void)buttonTouchBegin:(UIButton *)sender{
    if (click == 1) {
        click = 2;
        NSInteger btnTag = [sender tag];
        switch (btnTag) {
            case 10:{
                
                [self goStraight];
                if (select==1) {
                    _goTimer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goStraight) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_goTimer forMode:NSDefaultRunLoopMode];
                }
            }
                break;
            case 11:{
                [self goLeft];
                if (select==1) {
                    _leftTimer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goLeft) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_leftTimer forMode:NSDefaultRunLoopMode];
                }
                
            }
                break;
            case 12:{
                if (select==1) {
                    [self retreatDown];
                }
                
            }
                break;
            case 13:{
                [self goRight];
                if (select==1) {
                    _rightTimer =[NSTimer timerWithTimeInterval:3 target:self selector:@selector(goRight) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_rightTimer forMode:NSDefaultRunLoopMode];
                }
            }
                break;
            default:
                break;
        }
    }
   
    
}
-(void)buttonTouchEnd:(UIButton *)sender{
    [_goTimer invalidate];
    _goTimer=nil;
    [_rightTimer invalidate];
    _rightTimer=nil;
    [_leftTimer invalidate];
    _leftTimer=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(pauseAction) withObject:nil afterDelay:0.3];
     click = 1;
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
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger yearFront = [dateComponent year];
    NSInteger month =  [dateComponent month];
    NSInteger weekday = [dateComponent weekday];
    NSInteger day = [dateComponent day];
    NSInteger hour =  [dateComponent hour];
    NSInteger minute =  [dateComponent minute];
    NSInteger second = [dateComponent second];
    _FirstYearByte =  (yearFront &0xff00) >>8;
    _SecondYearByte = yearFront &0x00ff;
    _ThirdMonthByte = month;
    _ForthDayByte = day;
    if (weekday == 1) {
        _FifthWeekByte = 7;
    }else{
        _FifthWeekByte = weekday-1;
    }
    _SixthHourByte = hour;
    _SeventhMinByte = minute;
    _EighthSecByte = second;
    Byte content[] = {_FirstYearByte,_SecondYearByte,_ThirdMonthByte,_ForthDayByte,_FifthWeekByte,_SixthHourByte,_SeventhMinByte,_EighthSecByte};
    
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:76 binaryData:data];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            NSLog(@"%@",responseMsg.payload);
            NSLog(@"校准时间");
            
        }
    }];
}

#pragma mark - 回充
- (IBAction)recharge:(UIButton *)btn {
    if ([_statusStr isEqualToString:@"09"]||[_statusStr isEqualToString:@"9"]) {
        [self showHudWithString:NSLocalizedString(@"Charging", nil)];
    }
    else{
        
        if (self.remoteView.hidden==NO) {
            [self touchClickBtn];
        }else{
            _remoteBtn.enabled=NO;
            if (select==0) {
                return;
            }
            select=0;
            if (btn.selected == NO) {
                Byte content[] = {8};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    if (error) {
                        NSLog(@"响应超时");
                        [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                        
                    }else{
                        
                        self.backdata = [responseMsg getBinaryData];
                        NSLog(@"回充");
                        status =[self convertDataToHexStr:[responseMsg getBinaryData]];
                        [self getStatus:status];
                        
                    }
                    select=1;
                }];
                
            }
            else{
                
                Byte content[] = {2};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    if (!error) {
                        NSString *backStatus = [self convertDataToHexStr:[responseMsg getBinaryData]];
                        NSLog(@"待机");
                        self.rechargeBtn.selected = NO;
                        self.rechargeTextBtn.selected = NO;
                        [self loadGifImageUrl:self.staybyUrl];
                        
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
    if (self.remoteView.hidden==NO) {
        [self touchClickBtn];
    }else{
        
        if (select==0) {
            return;
        }
        select=0;
        if (btn.selected==NO) {
            
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                if (!error) {
                    NSLog(@"开始清扫");
                    NSString *status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                    [self getStatus:status];
                    _remoteView.hidden=YES;
                    self.remoteBtn.enabled=NO;
                    self.remoteBtn.selected=NO;
                    Byte randomContent[] = {3};
                    NSData *randomData = [NSData dataWithBytes:randomContent length:sizeof(randomContent)];
                    if ([backData isEqualToData:randomData]) {
                        [self loadGifImageUrl:self.randomUrl];
                    }
                    Byte planByte[] = {6};
                    payloadData = [NSData dataWithBytes:planByte length:sizeof planByte];
                    if ([responseMsg.payload isEqualToData:payloadData]){
                        
                        self.startCleanBtn.selected=YES;
                        self.startCleanTextBtn.selected=YES;
                        self.keyCleanBtn.selected=NO;
                        self.keyCleanTextBtn.selected=NO;
                        
                    }
                    self.remoteBtn.selected=NO;
                    Byte byte[] = {9};
                    payloadData = [NSData dataWithBytes:byte length:sizeof(byte)];
                    if ([responseMsg.payload isEqualToData:payloadData]) {
                        [self showHudWithString:NSLocalizedString(@"Charging", nil)];
                        [self loadGifImageUrl:self.staybyUrl];
                    }
                }
                else{
                    if (btn.enabled==YES) {
                        self.startCleanBtn.selected = NO;
                        self.startCleanTextBtn.selected = NO;
                        self.rechargeTextBtn.enabled=NO;
                        [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    }
                }
                select=1;
            }];
            
        }else{
            Byte byte[] = {2};
            NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                
                if (!error) {
                    status =[self convertDataToHexStr:[responseMsg getBinaryData]];
                    if([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]){
                        self.remoteBtn.enabled=YES;
                        [self loadGifImageUrl:_staybyUrl];
                        self.startCleanBtn.selected=NO;
                        self.startCleanTextBtn.selected=NO;
                    }
                    
                }else{
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
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
    if ([_statusStr isEqualToString:@"09"]||[_statusStr isEqualToString:@"9"]) {
        [self showHudWithString:NSLocalizedString(@"Charging", nil)];
    }
    else{
        
        if (self.remoteView.hidden==NO) {
            [self touchClickBtn];
        }else{
            _remoteBtn.enabled=NO;
            if (select==0) {
                return;
            }
            select=0;
            if (btn.selected==NO){
                Byte content[] = {5};
                NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error){
                    if (!error) {
                        
                        NSLog(@"---%@",[self convertDataToHexStr:[responseMsg getBinaryData]]);
                        NSLog(@"重点");
                        NSString *status=[self convertDataToHexStr:[responseMsg getBinaryData]];
                        [self getStatus:status];
                    }
                    
                    else{
                        [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
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
                        [self loadGifImageUrl:_staybyUrl];
                        if ([responseMsg.payload isEqualToData:payloadData]){
                            
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                            
                        }
                        else{
                            
                            [self loadGifImageUrl:self.staybyUrl];
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
            break;
        case 1:
            self.remoteBtn.selected=YES;
            [self loadGifImageUrl:_staybyUrl];
            
            break;
        case 2:{
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
            [self loadGifImageUrl:_alongWallUrl];
            break;
        case 5:{
//            self.keyCleanBtn.selected=YES;
//            self.keyCleanTextBtn.selected=YES;
            _rechargeBtn.selected = NO;
            _rechargeTextBtn.selected=NO;
            self.startCleanBtn.selected=NO;
            self.startCleanTextBtn.selected=NO;
            [self loadGifImageUrl:_spotUrl];
        }
            break;
        case 6:
            self.remoteBtn.selected=NO;
            self.startCleanBtn.selected=YES;
            self.startCleanTextBtn.selected=YES;
            _rechargeBtn.selected = NO;
            _rechargeTextBtn.selected=NO;
            _keyCleanBtn.selected = NO;
            _keyCleanTextBtn.selected=NO;
            break;
        case 8:{
            _keyCleanBtn.selected=NO;
            _keyCleanTextBtn.selected=NO;
            _startCleanBtn.selected=NO;
            _startCleanTextBtn.selected=NO;
            
            [self loadGifImageUrl:_rechargeUrl];
        }
            break;
        case 9:{
            self.remoteBtn.enabled=NO;
            [_batteryBtn setImage:[UIImage imageNamed:@"充电中"] forState:UIControlStateNormal];
            [self loadGifImageUrl:_staybyUrl];
            
        }
            break;
        case 10:
            break;
        case 11:
            [_batteryBtn setImage:[UIImage imageNamed:@"充电中"] forState:UIControlStateNormal];
            [self loadGifImageUrl:_staybyUrl];
            break;
        case 12:
            break;
        case 13:
        default:
            break;
    }
    
    if ([status isEqualToString:@"03"]||[status isEqualToString:@"04"]||[status isEqualToString:@"05"]||[status isEqualToString:@"08"]) {
        _remoteBtn.enabled=NO;
    }else{
        
        _remoteBtn.enabled=YES;
    }
        if ([status isEqualToString:@"03"]||[status isEqualToString:@"06"]||[status isEqualToString:@"07"] || [status isEqualToString:@"04"]) {
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
    if ([status isEqualToString:@"02"]||[status isEqualToString:@"0a"]||[status isEqualToString:@"0c"]) {
        self.remoteBtn.enabled=YES;
    }else{
        self.remoteBtn.enabled=NO;
    }
}
-(void)changeKeyCleanStatus{
    self.keyCleanBtn.enabled=YES;
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
                    [self loadGifImageUrl:self.staybyUrl];
                }else{
                    
                }
            }];
        }
    }
}

#pragma mark - 遥控前进
-(void)goStraight{
    if (select==0) {
        return;
    }
    select=0;
    self.upBtn.highlighted=!self.upBtn.highlighted;
    Byte content[] = {1};
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
    [_goTimer invalidate];
    _goTimer=nil;
    [_rightTimer invalidate];
    _rightTimer=nil;
    [_leftTimer invalidate];
    _leftTimer=nil;
    Byte content[] = {5};
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:73 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        
        if (!error) {
            self.upBtn.highlighted=NO;
            self.downBtn.highlighted=NO;
            self.rightBtn.highlighted=NO;
            self.leftBtn.highlighted=NO;
            NSLog(@"下发暂停成功");
        }else{
            NSLog(@"下发暂停失败");
            
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
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
//        self.gifImageView.animatedImage = animatedImg;
        
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
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:65 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            if (responseMsg) {
                if ([responseMsg getBinaryData].length==9) {
                    
                    NSData *statusData =[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(0, 1)];
                    NSData *battaryData =[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(5, 1)];
                    NSData *errorData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(8, 1)];
                    NSString *statusStr =  [self convertDataToHexStr:statusData];
                    NSString *dataStr = [self convertDataToHexStr:battaryData];
                    NSString *errorStr = [self convertDataToHexStr:errorData];
                    errorStr = [NSString stringWithFormat:@"%lu",strtoul([errorStr UTF8String],0,16)];
                    
                    batteryText = [[NSString stringWithFormat:@"%lu",strtoul([dataStr UTF8String],0,16)]integerValue];
                    _statusStr = statusStr;
                    [self getDeviceBatteryValue:batteryText Status:[statusStr intValue]];
                    
                    switch ([statusStr intValue]) {
                        case 0:
                            break;
                        case 1:{
                            
                            [self loadGifImageUrl:self.staybyUrl];
                        }
                            break;
                        case 2:{
                            
                            if (![errorStr isEqualToString:@"0"]) {
                                
                                [self returnErrorCode:errorStr];
                            }else{
                                self.errorView.hidden=YES;
                                _keyCleanBtn.selected=NO;
                                _keyCleanTextBtn.selected=NO;
                                _startCleanBtn.selected=NO;
                                _startCleanTextBtn.selected=NO;
                                _rechargeBtn.selected=NO;
                                _rechargeTextBtn.selected=NO;
                                [self loadGifImageUrl:_staybyUrl];
                            }
                        }
                            break;
                        case 3:{
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            
                            [self loadGifImageUrl:self.randomUrl];
                        }
                            break;
                        case 4:
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            break;
                        case 5:{
                            self.keyCleanBtn.selected=YES;
                            self.keyCleanTextBtn.selected=YES;
                            self.startCleanBtn.selected=NO;
                            self.startCleanTextBtn.selected=NO;
                            [self loadGifImageUrl:_spotUrl];
                        }
                            break;
                        case 6:{
                            self.startCleanBtn.selected=YES;
                            self.startCleanTextBtn.selected=YES;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                            
                        }
                            break;
                        case 8:{
                            self.rechargeBtn.selected=YES;
                            self.rechargeTextBtn.selected=YES;
                            [self loadGifImageUrl:_rechargeUrl];
                        }
                            break;
                        case 9:
                            [self loadGifImageUrl:_staybyUrl];
                            break;
                        case 10:
                            break;
                        case 11:
                            [self loadGifImageUrl:_staybyUrl];
                            break;
                            
                        default:
                            break;
                            
                    }
                    
                    if ([statusStr isEqualToString:@"03"]||[statusStr isEqualToString:@"04"]||[statusStr isEqualToString:@"05"]||[statusStr isEqualToString:@"08"]) {
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
                    }
                        if ([statusStr isEqualToString:@"09"]||[statusStr isEqualToString: @"0b"]){
                            self.startCleanBtn.selected=NO;
                            self.startCleanTextBtn.selected=NO;
                            self.rechargeBtn.selected=NO;
                            self.rechargeTextBtn.selected=NO;
                            self.keyCleanBtn.selected=NO;
                            self.keyCleanTextBtn.selected=NO;
                        
                    }
                    
                }
                
            }else{
                //查询设备状态失败
            }
        }
    }];
}



#pragma mark - 状态属性监听
-(void)listenPropertyValueChange{
    [ACDeviceDataManager subscribePropDataWithSubDomain:_subDomain deviceId:_deviceID callback:^
     (NSError *error) {
         
         if (!error) {
             
             [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                 cleanModel = [[properties get:@"work_pattern"] stringValue];
                 
                 NSString *errorCode = [properties get:@"error_info"];
                 NSInteger batteryText = [[properties get:@"battery_level"]integerValue];
                 _statusStr=cleanModel;
                 [self getDeviceBatteryValue:batteryText Status:[cleanModel intValue]];
                 switch ([cleanModel intValue]) {
                         
                     case 0:
                         
                         break;
                     case 1:
                         [self loadGifImageUrl:_staybyUrl];
                         
                         break;
                     case 2:{
                         self.rechargeBtn.selected=NO;
                         self.rechargeTextBtn.selected=NO;
                         self.keyCleanBtn.selected=NO;
                         self.keyCleanTextBtn.selected=NO;
                         self.downBtn.selected=NO;
                         self.rightBtn.selected=NO;
                         self.leftBtn.selected=NO;
                         self.startCleanBtn.selected=NO;
                         self.startCleanTextBtn.selected=NO;
                         
                         self.upBtn.selected=NO;
                         //                            [_gridView clear];
                         [self loadGifImageUrl:_staybyUrl];
                     }
                         break;
                     case 3:
                     {
                         
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
                         
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                         
                         [self loadGifImageUrl:_alongWallUrl];
                         break;
                     case 5:{
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
                         self.startCleanBtn.selected=YES;
                         self.startCleanTextBtn.selected=YES;
                         _rechargeBtn.selected = NO;
                         _rechargeTextBtn.selected=NO;
                         _keyCleanBtn.selected = NO;
                         _keyCleanTextBtn.selected=NO;
                         break;
                     case 8:{
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
                         [self loadGifImageUrl:_staybyUrl];
                         
                     }
                         break;
                     default:
                         break;
                         
                 }
                 
                 if ([cleanModel isEqualToString:@"3"]||[cleanModel isEqualToString:@"6"]||[cleanModel isEqualToString:@"7"] || [cleanModel isEqualToString:@"4"]) {
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
                 if (self.remoteView.hidden==YES) {
                     if ([cleanModel isEqualToString:@"2"]||[cleanModel isEqualToString:@"10"]||[cleanModel isEqualToString:@"12"]) {
                         self.remoteBtn.selected=YES;
                         self.remoteBtn.enabled=YES;
                     }
                     else{
                         self.remoteBtn.selected=NO;
                          self.remoteBtn.enabled=NO;
                     }
                 }
                
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
    } if (value>=96 &&(status==9 ||status==11)){
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
    switch ([code integerValue]) {
        case 1:
            _errorLab.text = NSLocalizedString(@"Bumper Abnormal", nil);
            break;
        case 17:
            _errorLab.text = NSLocalizedString(@"Anti-bump Sensors Abnormal", nil);
            break;
        case 18:
            _errorLab.text = NSLocalizedString(@"Edge Module Abnormal", nil);
            break;
        case 33:
            _errorLab.text = NSLocalizedString(@"Cliff Sensors Abnormal", nil);
            break;
        case 34:
            _errorLab.text = NSLocalizedString(@"Robot Not On the Floor", nil);
            break;
        case 49:
            _errorLab.text = NSLocalizedString(@"Nose Wheel Abnormal", nil);
            break;
        case 65:
            _errorLab.text = NSLocalizedString(@"Left Side Brush Abnormal", nil);
            break;
        case 66:
            _errorLab.text = NSLocalizedString(@"Right Side Brush Abnormal", nil);
            break;
        case 67:
            _errorLab.text =NSLocalizedString(@"Side Brush Error", nil);
            break;
        case 81:
            _errorLab.text = NSLocalizedString(@"Left Wheel Abnormal", nil);
            break;
        case 82:
            _errorLab.text = NSLocalizedString(@"Right Wheel Abnormal", nil);
            break;
        case 97:
            _errorLab.text = NSLocalizedString(@"Main Brush Abnormal", nil);
            break;
        case 113:
            _errorLab.text = NSLocalizedString(@"Fan Motor Abnormal", nil);
            break;
        case 129:
            _errorLab.text = NSLocalizedString(@"Water Pump Error", nil);
            break;
        case 130:
            _errorLab.text = NSLocalizedString(@"Air Aump Error", nil);
            break;
        case 145:
            _errorLab.text = NSLocalizedString(@"Dust Tank Abnormal", nil);
            break;
        case 146:
            _errorLab.text = NSLocalizedString(@"Water Tank Error", nil);
            break;
        case 147:
            _errorLab.text = NSLocalizedString(@"Filter Abnormal", nil);
            break;
        case 161:
            _errorLab.text = NSLocalizedString(@"Battery Abnormal", nil);
            break;
        case 177:
            _errorLab.text = NSLocalizedString(@"Navigation Module Abnormal", nil);
            break;
        case 193:
            _errorLab.text = NSLocalizedString(@"Radar Assembly Error", nil);
            break;
        case 194:
            _errorLab.text = NSLocalizedString(@"Robot Camera Abnormal", nil);
            break;
        case 209:
            _errorLab.text = NSLocalizedString(@"Route Error", nil);
            break;
        case 225:
            _errorLab.text = NSLocalizedString(@"Other error", nil);
            break;
        case 241:
            _errorLab.text = NSLocalizedString(@"Other error", nil);
            break;
        default:
            _errorLab.text = NSLocalizedString(@"Other error", nil);
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
    Byte content[] ={0};
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:77 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:self.subDomain physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
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
    
    Byte content[] = {2};
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            [self loadGifImageUrl:self.staybyUrl];
        }else{
            
        }
    }];
}

#pragma mark - 点击空白处隐藏遥控视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.remoteView.hidden == NO) {
        if ([cleanModel isEqualToString:@"10"]) {
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
    }
    _remoteView.hidden=YES;

    
}
#pragma mark - 预约按钮事件
- (IBAction)reserView:(UIButton *)sender {
    
    ZJMAddReserVC *timerReserVc = [[ZJMAddReserVC alloc]init];
    timerReserVc.title = NSLocalizedString(@"Planning", nil);
    timerReserVc.subDomain =self.subDomain;
    [self.navigationController pushViewController:timerReserVc animated:YES];
}


#pragma mark - 导航栏按钮事件
-(void)pushSettingVC:(UIButton *)sender{
    ZJMX785SettingVC *settingVc = [[ZJMX785SettingVC alloc]init];
    settingVc.title = NSLocalizedString(@"Setting", nil);
    settingVc.delegate = self;
    settingVc.deviceID = _deviceID;
    settingVc.deviceName = _deviceName;
    settingVc.deviceStatus = cleanModel;
    settingVc.subDomain=_subDomain;
    settingVc.physicalDeviceId = _physicalDeviceId;
    settingVc.isManager = _isManager;
    [self.navigationController pushViewController:settingVc animated:YES];
    
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

