//
//  ZJMTimedReserVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/9.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMAddReserVC.h"
#import "ZJMTimeReserVC.h"
#import "ZJMReserRecordCell.h"
#import "ZJMReserModel.h"

@interface ZJMAddReserVC ()<UITableViewDelegate,UITableViewDataSource>



@property (strong, nonatomic) IBOutlet UIView *neverReverView;

@property (weak, nonatomic) IBOutlet UITableView *reserTableView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (strong,nonatomic)NSMutableArray <ZJMReserModel *> *opencloseArrM;
@property (strong,nonatomic)NSMutableArray *reserNumberArr;

@property (assign,atomic)BOOL btnSelect;

@property (assign,atomic)NSInteger FirstYearByte;
@property (assign,atomic)NSInteger SecondYearByte;
@property (assign,atomic)NSInteger ThirdMonthByte;
@property (assign,atomic)NSInteger ForthDayByte;
@property (assign,atomic)NSInteger FifthWeekByte;
/** 校准时间小时*/
@property (assign,atomic)NSInteger SixthHourByte;
/** 校准时间分钟*/
@property (assign,atomic)NSInteger SeventhMinByte;
/** 校准时间秒*/
@property (assign,atomic)NSInteger EighthSecByte;
/** 预约时间秒*/
@property (assign,atomic)NSInteger reserHourByte;
/** 预约时间秒*/
@property (assign,atomic)NSInteger reserMinByte;
@property (strong,nonatomic)  NSIndexPath *selectIndexPath;
@property (weak, nonatomic) IBOutlet UILabel *neverLab;
@property (weak, nonatomic) IBOutlet UIButton *neverBtn;
@property (strong,nonatomic)NSMutableArray *weeksTextArrM;
@property (copy,nonatomic)NSString *currentWeekStr;

@end

@implementation ZJMAddReserVC
{
    Byte dataByte[50];
    NSMutableArray *dataArrM;
    Byte opencloseByte[10];
    NSData *backData;
    NSNumber *reserNumber;
    NSMutableString *_weeksText;
    NSString *hourStr;
    NSString *minStr;
    NSMutableArray *_weekArrM;
    BOOL toSelect;
    
}

-(void)viewWillAppear:(BOOL)animated{
    __weak typeof(self)weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
    [self setUpTimeCalibration];
    _weeksTextArrM = [NSMutableArray array];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _opencloseArrM = [NSMutableArray array];
    _addBtn.hidden = YES;
    _neverLab.text = NSLocalizedString(@"No Planning Records Found", nil);
    [_neverBtn setTitle:NSLocalizedString(@"Add Planning", nil) forState:UIControlStateNormal];
    [_addBtn setTitle:NSLocalizedString(@"Add Planning", nil) forState:UIControlStateNormal];
    Byte content[] = {0};
    [weakSelf showHudWithRound];
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:66 binaryData:data];
    
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [weakSelf hideHud];
        
        if (!error) {
            
            backData = responseMsg.payload;
            for(int i=0;i<[backData length];i++){
                Byte *byte= (Byte *)[backData bytes];
                dataByte[i]=byte[i];
            }
            
            reserNumber = 0;
            //            NSData * data = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
            for (int i = 0; i <50; i++) {
                if (i%5==0){
                    if (dataByte[i+2]!=0) {
                        ZJMReserModel *reserModel = [[ZJMReserModel alloc]init];
                        reserModel.reserNumber = dataByte[i];
                        reserModel.reserOpen = dataByte[i+1];
                        reserModel.week = dataByte[i+2];
                        reserModel.hour = dataByte[i+3];
                        reserModel.min = dataByte[i+4];
                        [_opencloseArrM addObject:reserModel];
                    }
                }
            }
            
            if (_opencloseArrM.count>0) {
                
                _reserTableView.backgroundView = nil;
                _addBtn.hidden = NO;
                
            }else{
                _reserTableView.backgroundView = _neverReverView;
            }
            
        }else{
            _reserTableView.backgroundView = _neverReverView;
            [weakSelf showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
        if (![self.subDomain isEqualToString:X430SubDomain] && ![self.subDomain isEqualToString:X420SubDomain] && ![self.subDomain isEqualToString:X620SubDomain] && ![self.subDomain isEqualToString:X610SubDomain]) {
            for (int i = 0; i < _opencloseArrM.count; i++) {
                for (int j = i+1; j < _opencloseArrM.count; j++) {
                    ZJMReserModel * model1 = _opencloseArrM[i];
                    ZJMReserModel * model2 = _opencloseArrM[j];
                    if (model1.hour == model2.hour && model1.min == model2.min) {
                        model1.week = model1.week + model2.week;
                        if (model2.reserOpen == 1) {
                            model1.reserOpen = 1;
                        }
                        _opencloseArrM[i] = model1;
                        j-=1;
                        [_opencloseArrM removeObject:model2];
                    }
                }
            }
        }
        NSLog(@"%@",_opencloseArrM);
        [_reserTableView reloadData];
        
    }];
    
}
- (void)applicationWillEnterForeground{
    [self.reserTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _reserNumberArr = [NSMutableArray array];
    // Do any additional setup after loading the view from its nib
    [_reserTableView registerNib:[UINib nibWithNibName:@"ZJMReserRecordCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    //    [self setUpdataTableView];
}

#pragma mark - 预约时间校准
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
#pragma mark - 上下拉刷新
-(void)setUpdataTableView{
    
    _reserTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ACBindManager listDevicesWithStatusCallback:^(NSArray<ACUserDevice *> *devices, NSError *error) {
            if (!error) {
                [_reserTableView.mj_header endRefreshing];
                [_reserTableView.mj_footer endRefreshing];
                [_reserTableView reloadData];
            }else{
                [_reserTableView.mj_header endRefreshing];
                [_reserTableView.mj_footer endRefreshing];
                [_reserTableView reloadData];
            }
            
        }];
        
        
    }];
    _reserTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [ACBindManager listDevicesWithStatusCallback:^(NSArray<ACUserDevice *> *devices, NSError *error) {
            if (!error) {
                [_reserTableView.mj_header endRefreshing];
                [_reserTableView.mj_footer endRefreshing];
                [_reserTableView reloadData];
            }else{
                [_reserTableView.mj_header endRefreshing];
                [_reserTableView.mj_footer endRefreshing];
                [_reserTableView reloadData];
            }
            
        }];
    }];
    [_reserTableView.mj_header beginRefreshing];
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.reserCount = _opencloseArrM.count;
    return _opencloseArrM.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZJMReserRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.opencloseArrM.count>0) {
        
        ZJMReserModel *reserModel = self.opencloseArrM[indexPath.row];
        if (reserModel.reserOpen == 0) {
            cell.openLab.text = NSLocalizedString(@"Off", nil);
            cell.selectBtn.selected = NO;
        }else{
            cell.openLab.text = NSLocalizedString(@"On", nil);
            cell.selectBtn.selected = YES;
        }
        _weeksText = [[NSMutableString alloc]initWithString:@""];
        NSString *weekStr;
        _weekArrM =  [@[@"",@"",@"",@"",@"",@"",@"",@""]mutableCopy];
        if (indexPath.row <=_opencloseArrM.count) {
            hourStr = [self ToHex:reserModel.hour];
            minStr = [self ToHex:reserModel.min];
            NSString*formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
            NSRange containsA =[formatStringForHours rangeOfString:@"a"];
            
            BOOL hasAMPM =containsA.location != NSNotFound;
            if (hasAMPM == YES) {
                if (reserModel.hour >=12) {
                    if (reserModel.hour == 12) {
                        cell.timeLab.text =  [NSString stringWithFormat: @"%@:%@",hourStr,minStr];
                    }else{
                        cell.timeLab.text =  [NSString stringWithFormat: @"%@:%@",[self ToHex:reserModel.hour-12],minStr];
                    }
                    cell.noonLab.text =NSLocalizedString(@"PM", nil);
                    
                }else{
                    cell.timeLab.text =  [NSString stringWithFormat: @"%@:%@",hourStr,minStr];
                    cell.noonLab.text =NSLocalizedString(@"AM", nil);
                }
            }else{
                cell.timeLab.text =  [NSString stringWithFormat: @"%@:%@",hourStr,minStr];
                cell.noonLab.text = @"";
            }
            if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
                if ((reserModel.week & 1)==1) {
                    
                    weekStr = NSLocalizedString(@"MON", nil);
                    [_weekArrM replaceObjectAtIndex:0 withObject:weekStr];
                    
                }
                if ((reserModel.week & 2)==2) {
                    weekStr =NSLocalizedString(@"TUE", nil);
                    
                    [_weekArrM replaceObjectAtIndex:1 withObject:weekStr];
                }
                if ((reserModel.week & 4)==4) {
                    weekStr =NSLocalizedString(@"WED", nil);
                    [_weekArrM replaceObjectAtIndex:2 withObject:weekStr];
                }
                if ((reserModel.week & 8)==8) {
                    weekStr =NSLocalizedString(@"THUR", nil);
                    [_weekArrM replaceObjectAtIndex:3 withObject:weekStr];
                }
                if ((reserModel.week & 16)==16) {
                    weekStr =NSLocalizedString(@"Fri", nil);
                    [_weekArrM replaceObjectAtIndex:4 withObject:weekStr];
                }
                if ((reserModel.week & 32)==32) {
                    weekStr =NSLocalizedString(@"Sat", nil);
                    [_weekArrM replaceObjectAtIndex:5 withObject:weekStr];
                }
                if ((reserModel.week &64)==64) {
                    weekStr =NSLocalizedString(@"Sun", nil);
                    [_weekArrM replaceObjectAtIndex:6 withObject:weekStr];
                }else if ((reserModel.week &128)==128) {
                    weekStr =NSLocalizedString(@"Once", nil);
                    [_weekArrM replaceObjectAtIndex:7 withObject:weekStr];
                }
                NSMutableString *cellWeeksText = [[NSMutableString alloc]initWithString:@""];
                for (NSString *str in _weekArrM) {
                    [cellWeeksText appendFormat:@"%@ ",str];
                    cell.weekLab.text = cellWeeksText;
                }
                [_weeksTextArrM addObject:_weekArrM];
            }else{
                [_weekArrM removeAllObjects];
                if ((reserModel.week & 1)==1) {
                    
                    weekStr = NSLocalizedString(@"Every MON", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[1]= 1;
                    }
                }
                if ((reserModel.week & 2)==2) {
                    weekStr =NSLocalizedString(@"Every TUE", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(1*5)+1]= 1;
                    }
                }
                if ((reserModel.week & 4)==4) {
                    weekStr =NSLocalizedString(@"Every WED", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(2*5)+1]= 1;
                    }
                }
                if ((reserModel.week & 8)==8) {
                    weekStr =NSLocalizedString(@"Every THUR", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(3*5)+1]= 1;
                    }
                }
                if ((reserModel.week & 16)==16) {
                    weekStr =NSLocalizedString(@"Every FRI", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(4*5)+1]= 1;
                    }
                }
                if ((reserModel.week & 32)==32) {
                    weekStr =NSLocalizedString(@"Every SAT", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(5*5)+1]= 1;
                    }
                }
                if ((reserModel.week &64)==64) {
                    weekStr =NSLocalizedString(@"Every SUN", nil);
                    [_weekArrM addObject:weekStr];
                    if (reserModel.reserOpen == 1) {
                        dataByte[(6*5)+1]= 1;
                    }
                }
                
                NSMutableString *cellWeeksText = [[NSMutableString alloc]initWithString:@""];
                for (NSString *str in _weekArrM) {
                    if ([str isEqualToString:[_weekArrM lastObject] ]) {
                        [cellWeeksText appendFormat:@"%@",str];
                        backData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
                    }else{
                        [cellWeeksText appendFormat:@"%@,",str];
                    }
                    
                }
               
                cell.weekLab.text = cellWeeksText;
                [_weeksTextArrM addObject:cellWeeksText];
                
                
            }
            
        }
        
    }
    
    
    [cell.selectBtn addTarget:self action:@selector(openOrCloseReser:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREENHEIGHT*0.15;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    toSelect=YES;
    if (self.opencloseArrM.count>0) {
        ZJMTimeReserVC *timeReverVc = [[ZJMTimeReserVC alloc]init];
        if (self.opencloseArrM.count>0) {
            ZJMReserModel *reserModel = self.opencloseArrM[indexPath.row];
            timeReverVc.cellDidSelect = YES;
            timeReverVc.reserHour = reserModel.hour;
            timeReverVc.reserMin = reserModel.min;
            timeReverVc.receiveData = backData;
            timeReverVc.reserNumber = reserModel.reserNumber;
        }
        
        timeReverVc.type=0;
        self.selectIndexPath = indexPath;
        if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
            timeReverVc.reserWeekStrArrM = _weeksTextArrM[indexPath.row];
        }else{
            [self getReserNumArrFromIndexPath:indexPath];
            timeReverVc.reserNumArr = _reserNumberArr;
            if (_weeksTextArrM.count>0) {
                timeReverVc.oneWeekText=_weeksTextArrM[indexPath.row];
                [_weeksTextArrM removeObjectAtIndex:indexPath.row];
                timeReverVc.reserWeekStrArrM=_weeksTextArrM;
                
            }
            
            
        }
        
        timeReverVc.subDomain=self.subDomain;
        [self.navigationController pushViewController:timeReverVc  animated:YES];
        
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ZJMReserModel *reserModel = self.opencloseArrM[indexPath.row];
        NSLog(@"删除");
        self.selectIndexPath = indexPath;
        for(int i=0;i<[backData length];i++){
            Byte *byte= (Byte *)[backData bytes];
            dataByte[i]=byte[i];
        }
        if (![self.subDomain isEqualToString:X430SubDomain ]&&![self.subDomain isEqualToString:X420SubDomain]&&![self.subDomain isEqualToString:X620SubDomain] &&![self.subDomain isEqualToString:X610SubDomain]) {
            [self getReserNumArrFromIndexPath:indexPath];
            for (NSString * reserNumber in _reserNumberArr) {
                dataByte[([reserNumber integerValue]*5)+1]= 0;
                dataByte[([reserNumber integerValue]*5)+2]= 0;
                dataByte[([reserNumber integerValue]*5)+3]= 0;
                dataByte[([reserNumber integerValue]*5)+4]= 0;
            }
        }else{
            dataByte[((reserModel.reserNumber-1)*5)+1] =0;
            dataByte[((reserModel.reserNumber-1)*5)+2] =0;
            dataByte[((reserModel.reserNumber-1)*5)+3] =0;
            dataByte[((reserModel.reserNumber-1)*5)+4] =0;
        }
        
        backData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        ACDeviceMsg *deviceMsg = [[ACDeviceMsg alloc]initWithCode:74 binaryData:backData];
       
        [self showHudWithRound];
        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
            [self hideHud];
            if (!error) {
                [self.opencloseArrM removeObjectAtIndex:self.selectIndexPath.row];
                [self.weeksTextArrM removeObjectAtIndex:indexPath.row];
                if (self.opencloseArrM.count == 0) {
                    _addBtn.hidden = YES;
                    self.reserTableView.backgroundView = self.neverReverView;
                }
                 [self.reserTableView reloadData];
              
            } else {
                
            }
        }];
        
    }
}


#pragma mark - 开启/关闭预约
-(void)openOrCloseReser:(UIButton *)sender{
    ZJMReserRecordCell *cell = (ZJMReserRecordCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.reserTableView indexPathForCell:cell];
    ZJMReserModel *reserModel = self.opencloseArrM[indexPath.row];
    cell = [self.reserTableView cellForRowAtIndexPath:indexPath];
    if (![self.subDomain isEqualToString:X430SubDomain] && ![self.subDomain isEqualToString:X420SubDomain] && ![self.subDomain isEqualToString:X620SubDomain] && ![self.subDomain isEqualToString:X610SubDomain]) {
        [self getReserNumArrFromIndexPath:indexPath];
        if (cell.selectBtn.selected) {
            for (NSString * reserNumber in _reserNumberArr) {
                dataByte[([reserNumber integerValue]*5)+1]= 0;
            }
            
        }else{
            for (NSString * reserNumber in _reserNumberArr) {
                dataByte[([reserNumber integerValue]*5)+1]= 1;
            }
            
        }
    }else{
        if (cell.selectBtn.selected) {
            dataByte[((reserModel.reserNumber-1)*5)+1] =0;
        }else{
            dataByte[((reserModel.reserNumber-1)*5)+1] =1;
        }
    }
    
    backData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
    [self showHudWithRound];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ACDeviceMsg *deviceMsg = [[ACDeviceMsg alloc]initWithCode:74 binaryData:backData];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            if (cell.selectBtn.selected) {
                cell.selectBtn.selected=NO;
                cell.openLab.text = NSLocalizedString(@"Off", nil);
                reserModel.reserOpen=0;
            }else{
                cell.selectBtn.selected = YES;
                cell.openLab.text = NSLocalizedString(@"On", nil);
                reserModel.reserOpen=1;
            }
        } else {
            
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
}
-(void)getReserNumArrFromIndexPath:(NSIndexPath *)indexPath{
    [_reserNumberArr removeAllObjects];
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every MON",nil)]) {
        [_reserNumberArr addObject:@(0)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every TUE",nil)]){
        [_reserNumberArr addObject:@(1)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every WED",nil)]){
        [_reserNumberArr addObject:@(2)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every THUR",nil)]){
        [_reserNumberArr addObject:@(3)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every FRI",nil)]){
        [_reserNumberArr addObject:@(4)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every SAT",nil)]){
        [_reserNumberArr addObject:@(5)];
    }
    if ([_weeksTextArrM[indexPath.row] containsString:NSLocalizedString(@"Every SUN",nil)]){
        [_reserNumberArr addObject:@(6)];
    }
}

#pragma mark - 添加预约
- (IBAction)onceAddRever:(UIButton *)sender {
    
    ZJMTimeReserVC *timeReverVc = [[ZJMTimeReserVC alloc]init];
    timeReverVc.type=2;
    timeReverVc.receiveData = backData;
    timeReverVc.subDomain=self.subDomain;
    timeReverVc.reserWeekStrArrM=_weeksTextArrM;
    if (![self.subDomain isEqualToString:X430SubDomain] && ![self.subDomain isEqualToString:X420SubDomain] && ![self.subDomain isEqualToString:X620SubDomain]){
        NSInteger week = 0;
        for (ZJMReserModel * model in self.opencloseArrM) {
            week += model.week;
        }
        if (week==127) {
            [self showHudWithString:NSLocalizedString(@"You Could Add Maximum 7 Plannings", nil)];
        }else{
            
            [self.navigationController pushViewController:timeReverVc animated:YES];
        }
        
    }else{
        if (self.opencloseArrM.count>=7) {
            [self showHudWithString:NSLocalizedString(@"You Could Add Maximum 7 Plannings", nil)];
        }else{
            
            [self.navigationController pushViewController:timeReverVc animated:YES];
        }
    }
}

#pragma mark - 不足两位补0
-(NSString *)ToHex:(NSInteger)number
{
    NSString * result = [NSString stringWithFormat:@"%ld",number];
    if (result.length<2) {
        result = [NSString stringWithFormat:@"0%ld",number];
    }
    return [result uppercaseString];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
