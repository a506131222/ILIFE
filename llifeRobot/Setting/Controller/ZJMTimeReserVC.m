//
//  ZJMTimeReserVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/16.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMTimeReserVC.h"
#import "ZJMTimerReverCell.h"
#import "ZJMReserView.h"
#import "ZJMWeekChoiceCell.h"
#import "ZJMSaveView.h"
#import "ZJMAddReserVC.h"

@interface ZJMTimeReserVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *reserTableView;

@property(nonatomic,assign)NSInteger clickNum;
@property(nonatomic,assign)NSInteger getClickNum;
//选中时间
@property(strong,nonatomic)NSDate *selectedDate;

@property (strong,nonatomic) NSMutableArray *weekArrM;

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
/** 预约时间小时*/
@property (assign,atomic)NSInteger reserHourByte;
/** 预约时间分*/
@property (assign,atomic)NSInteger reserMinByte;
/**选择多个*/
@property (assign,atomic)NSInteger MoreSelectByte;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong,nonatomic)NSDate *date;
@property (strong,nonatomic)UIButton *sender;

@property (strong,nonatomic)NSMutableArray *didSelectWeekArrM;
@property (strong,nonatomic)UIButton *selectedBtn;


@end

@implementation ZJMTimeReserVC
{
    NSString *_reserTime;
    NSMutableString *_weeksStr;
    NSMutableArray *_dataArrM;
     /**预约编号*/
    NSNumber *reserNum;
    NSNumber *index;
    /**未预约的编号*/
    NSInteger neverReserNum;
    NSMutableArray *_numberArrM;
    NSData *sendData;
    Byte dataByte[50];
    BOOL changed;
    BOOL selected;
    NSInteger week;
    NSInteger hour;
    NSInteger min;
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void)applicationWillEnterForeground{
    
    [self.reserTableView reloadData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Add Planning", nil);
    [_saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [_cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_reserTableView registerNib:[UINib nibWithNibName:@"ZJMTimerReverCell" bundle:nil] forCellReuseIdentifier:@"timerReverCell"];
    [_reserTableView registerNib:[UINib nibWithNibName:@"ZJMWeekChoiceCell" bundle:nil] forCellReuseIdentifier:@"weekChoiceCell"];
    _reserTableView.tableFooterView = [UIView new];
    
    _saveBtn.titleLabel.font= [UIFont systemFontOfSize:18.0];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        _weekArrM =  [@[@"",@"",@"",@"",@"",@"",@"",NSLocalizedString(@"Once", nil)]mutableCopy];
    }else{
        _weekArrM = [NSMutableArray array];
        if (_oneWeekText != nil) {
            NSArray * array = [_oneWeekText componentsSeparatedByString:@","];
            for (NSString * str in array) {
                if (![str isEqualToString:@""]) {
                    [_weekArrM addObject:str];
                }
            }
        }
       
    }
 
    _dataArrM  =[NSMutableArray array];
    _numberArrM = [NSMutableArray array];
    for (int i = 1; i <= 10; i++) {
        reserNum =@(i);
        [_numberArrM addObject:reserNum];
    }
     self.clickNum = 180;
      index = 0;
      [_reserTableView reloadData];
}

-(NSMutableArray *)didSelectWeekArrM{
    
    if (_didSelectWeekArrM==nil) {
        _didSelectWeekArrM = [NSMutableArray array];
    }
    return _didSelectWeekArrM;
}
-(NSMutableArray *)weekArrM{
    if (_weekArrM ==nil) {
        _weekArrM = [NSMutableArray array];
    }
    return  _weekArrM;
}
#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        ZJMReserView *reserView = [[ZJMReserView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, 200)];
        NSString*formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
        NSRange containsA =[formatStringForHours rangeOfString:@"a"];
        BOOL hasAMPM =containsA.location != NSNotFound;
        reserView.mainLab.text = NSLocalizedString(@"Planning Time", nil);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSArray *languages = [NSLocale preferredLanguages]; //系统偏好语言
        NSString *language = languages.firstObject;
        NSLocale * locale;
        if ([language hasPrefix:@"zh-Hans"]) {
            locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
        }else{
            locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        }
        dateFormatter.locale=locale;
        if (self.cellDidSelect==YES) {
            if (changed==1) {
                _reserTime =[dateFormatter stringFromDate:self.selectedDate];
                if (hasAMPM) {
                    [dateFormatter setDateFormat:@"a hh:mm"];
                    reserView.detailLab.text = [dateFormatter stringFromDate:self.selectedDate];
                }else{
                    reserView.detailLab.text = _reserTime;
                }
            }else{
                NSString *hourStr = [self ToHex:_reserHour];
                NSString *minStr = [self ToHex:_reserMin];
                _reserTime = [NSString stringWithFormat:@"%@:%@",hourStr,minStr];
                if (hasAMPM) {
                    if (_reserHour >=12) {
                        if (_reserHour == 12) {
                            reserView.detailLab.text = [NSString stringWithFormat:@"%@ %@:%@",NSLocalizedString(@"PM", nil),hourStr,minStr];
                        }else{
                            reserView.detailLab.text = [NSString stringWithFormat:@"%@ %@:%@",NSLocalizedString(@"PM", nil),[self ToHex:_reserHour-12],minStr];
                        }
                        
                    }else{
                        reserView.detailLab.text = [NSString stringWithFormat:@"%@ %@:%@",NSLocalizedString(@"AM", nil),hourStr,minStr];
                    }
                }else{
                    reserView.detailLab.text = _reserTime;
                }
                
                
            }
            
        }else{
            
            if (self.selectedDate == nil) {
                _reserTime =[dateFormatter stringFromDate:[NSDate date]];
                if (hasAMPM) {
                    [dateFormatter setDateFormat:@"a hh:mm"];
                    reserView.detailLab.text = [dateFormatter stringFromDate:[NSDate date]];
                }else{
                    reserView.detailLab.text = _reserTime;
                }
                
            }else{
                _reserTime =[dateFormatter stringFromDate:self.selectedDate];
                if (hasAMPM) {
                    [dateFormatter setDateFormat:@"a hh:mm"];
                    reserView.detailLab.text = [dateFormatter stringFromDate:self.selectedDate];
                }else{
                    reserView.detailLab.text = _reserTime;
                }
                
            }
        }
       
        if (self.cellDidSelect == NO) {
            if (self.selectedDate == nil) {
                [dateFormatter setDateFormat:@"HH"];
                _reserHourByte = [[dateFormatter stringFromDate:[NSDate date]]integerValue];
                [dateFormatter setDateFormat:@"mm"];
                _reserMinByte =[[dateFormatter stringFromDate:[NSDate date]]integerValue];
            }else{
                [dateFormatter setDateFormat:@"HH"];
                _reserHourByte = [[dateFormatter stringFromDate:self.selectedDate]integerValue];
                [dateFormatter setDateFormat:@"mm"];
                _reserMinByte =[[dateFormatter stringFromDate:self.selectedDate]integerValue];
            }
            
        }else{
            if (self.selectedDate == nil) {
                _reserHourByte = [[self ToHex:_reserHour] integerValue];
                _reserMinByte =[[self ToHex:_reserMin]integerValue];
            }else{
                [dateFormatter setDateFormat:@"HH"];
                _reserHourByte = [[dateFormatter stringFromDate:self.selectedDate]integerValue];
                [dateFormatter setDateFormat:@"mm"];
                _reserMinByte =[[dateFormatter stringFromDate:self.selectedDate]integerValue];
            }
           
        }
       
        reserView.detailLab.font = [UIFont systemFontOfSize:14];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
        [reserView addGestureRecognizer:tap];
        reserView.tag = section;
        if (self.clickNum == 180 || self.clickNum == 0) {
           reserView.reserImageView.image = [UIImage imageNamed:@"reser_down"];
        }
        if (self.clickNum== 200 ) {
            reserView.reserImageView.image = [UIImage imageNamed:@"reser_up"];
        }
        
        
        
        return reserView;
        
        
    }else {
        ZJMReserView *reserView = [[ZJMReserView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, 200)];
        reserView.detailLab.text=nil;
        if (self.clickNum == section) {
            reserView.reserImageView.image = [UIImage imageNamed:@"reser_down"];
        
        }else{
             reserView.reserImageView.image = [UIImage imageNamed:@"reser_up"];
            
        }
        ZJMWeekChoiceCell *cell  = (ZJMWeekChoiceCell *)[_reserTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
            if (self.type==0) {
                _weeksStr = [[NSMutableString alloc]initWithString:@""];
                for (NSString *str in _reserWeekStrArrM) {
                    [_weeksStr appendFormat:@"%@ ",str];
                }
                reserView.detailLab.text = _weeksStr;
                for (NSMutableString *_reserWeekStr in _reserWeekStrArrM) {
                    
                    cell.OnceBtn.selected=NO;
                    if ([_weeksStr containsString:NSLocalizedString(@"MON", nil)]) {
                        cell.MondayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"Tue",nil)]){
                        cell.TuesdayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"Wed",nil)]){
                        cell.WednesdayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"THUR",nil)]){
                        cell.ThursdayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"FRI",nil)]){
                        cell.FridayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"SAT",nil)]){
                        cell.SaturdayBtn.selected=YES;
                    } if ([_weeksStr containsString:NSLocalizedString(@"SUN",nil)]){
                        cell.WeekdayBtn.selected=YES;
                    }else if ([_weeksStr containsString:NSLocalizedString(@"Once",nil)]){
                        cell.OnceBtn.selected=YES;
                    }
                }
            }
            else if (self.type==1){
                if (self.cellDidSelect==YES) {
                    _weeksStr = [[NSMutableString alloc]initWithString:@""];
                    for (NSString *str in _reserWeekStrArrM) {
                        [_weeksStr appendFormat:@"%@ ",str];
                        reserView.detailLab.text = _weeksStr;
                    }if (cell.OnceBtn.selected==YES) {
                        NSString *weekText = NSLocalizedString(@"Once", nil);
                        reserView.detailLab.text = weekText;
                    }
                    
                }else{
                    _weeksStr = [[NSMutableString alloc]initWithString:@""];
                    for (NSString *str in _weekArrM) {
                        [_weeksStr appendFormat:@"%@ ",str];
                    }
                    reserView.detailLab.text = _weeksStr;
                }
            }else if (self.type==2){
                
                _weeksStr = [[NSMutableString alloc]initWithString:@""];
                for (NSString *str in _weekArrM) {
                    [_weeksStr appendFormat:@"%@ ",str];
                }
                reserView.detailLab.text = _weeksStr;
            }
        }else{
            
            reserView.detailLab.text=_oneWeekText;
            
        }
        reserView.mainLab.numberOfLines = 0;
        reserView.mainLab.text = NSLocalizedString(@"Repeat", nil);
        reserView.detailLab.font = [UIFont systemFontOfSize:14];
        reserView.detailLab.numberOfLines = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)];
        [reserView addGestureRecognizer:tap];
        
        reserView.tag = section;
        
        return reserView;
    }
  

    
}

#pragma mark -展开手势
-(void)tapCell:(UITapGestureRecognizer *)tap{
    self.clickNum = tap.view.tag;
    if (self.clickNum == self.getClickNum) {
        self.clickNum = 200;
    }
    [_reserTableView reloadData];
    self.getClickNum = self.clickNum;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.clickNum == 180 && section==0) {
        return 1;
    }
    if (self.clickNum== 200) {
        return 0;
    }
    else{
        if (self.clickNum == section) {
            
            return 1;
        }else{
            
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{

    if (indexPath.section == 0) {
   
       ZJMTimerReverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerReverCell" forIndexPath:indexPath];

            if (self.date == nil) {
                if (self.cellDidSelect==YES) {
                    NSString *hourStr = [self ToHex:_reserHour];
                    NSString *minStr = [self ToHex:_reserMin];
                    _reserTime = [NSString stringWithFormat:@"%@:%@",hourStr,minStr];
                    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
                    [dateFormat setDateFormat:@"HH:mm"];
                    NSArray *languages = [NSLocale preferredLanguages]; //系统偏好语言
                    NSString *language = languages.firstObject;
                    NSLocale * locale;
                    if ([language hasPrefix:@"zh-Hans"]) {
                        locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
                    }else{
                         locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
                    }
                    dateFormat.locale=locale;
                    _date =[dateFormat dateFromString:_reserTime];
            
                    cell.clockDatePicker.date =_date;
                }
               else if (self.selectedDate==nil){
                   
                    cell.clockDatePicker.date = [NSDate date];
                }
                else if(self.selectedDate!=nil){
                   
                    cell.clockDatePicker.date = self.selectedDate;

                }

            }
        [cell.clockDatePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }else{
     ZJMWeekChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekChoiceCell" forIndexPath:indexPath];
     [cell.MondayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.TuesdayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.WednesdayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.ThursdayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.FridayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.SaturdayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.WeekdayBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
     [cell.OnceBtn addTarget:self action:@selector(onceSelect:) forControlEvents:UIControlEventTouchUpInside];

     if (cell.MondayBtn.selected ==YES) {
         cell.detailTextLabel.text =NSLocalizedString(@"MON", nil);
     }
     _weeksStr = [[NSMutableString alloc]initWithString:@""];
     if (![self.subDomain isEqualToString:X430SubDomain] && ![self.subDomain isEqualToString:X420SubDomain] && ![self.subDomain isEqualToString:X620SubDomain] && ![self.subDomain isEqualToString:X610SubDomain]) {
         NSLog(@"%@",_reserWeekStrArrM);
         
              if ([_oneWeekText containsString:NSLocalizedString(@"Every MON",nil)]){
                    cell.MondayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every TUE",nil)]){
                    cell.TuesdayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every WED",nil)]){
                    cell.WednesdayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every THUR",nil)]){
                    cell.ThursdayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every FRI",nil)]){
                    cell.FridayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every SAT",nil)]){
                    cell.SaturdayBtn.selected=YES;
                }
              if ([_oneWeekText containsString:NSLocalizedString(@"Every SUN",nil)]){
                    cell.WeekdayBtn.selected=YES;
                }
        
            for(NSMutableString *str in _reserWeekStrArrM){
                    
                    [_weeksStr appendFormat:@"%@",str];
                    if ([_weeksStr containsString:NSLocalizedString(@"Every MON",nil)]) {
                        [cell.MondayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.MondayBtn.enabled=NO;
                        
                    }
                    if ([_weeksStr containsString:NSLocalizedString(@"Every TUE",nil)]){
                        [cell.TuesdayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.TuesdayBtn.enabled=NO;
                    }
                    if ([_weeksStr containsString:NSLocalizedString(@"Every WED",nil)]){
                        [cell.WednesdayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.WednesdayBtn.enabled=NO;
                    }
                    if ([_weeksStr containsString:NSLocalizedString(@"Every THUR",nil)]){
                        
                        [cell.ThursdayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.ThursdayBtn.enabled=NO;
                    }
                    if ([_weeksStr containsString:NSLocalizedString(@"Every FRI",nil)]){
                        
                        [cell.FridayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.FridayBtn.enabled=NO;
                    }
                    if ([_weeksStr containsString:NSLocalizedString(@"Every SAT",nil)]){
                        [cell.SaturdayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.SaturdayBtn.enabled=NO;
                    }if ([_weeksStr containsString:NSLocalizedString(@"Every SUN",nil)]){
                         [cell.WeekdayBtn setImage:[UIImage imageNamed:@"星期按钮-选择"] forState:UIControlStateNormal];
                        cell.WeekdayBtn.enabled=NO;
                    }
         }
        
}
     return cell;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREENHEIGHT*0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return SCREENHEIGHT*0.28;
    }else{
        return SCREENHEIGHT*0.5;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

//#pragma mark - 预约时间校准
//-(void)setUpTimeCalibration{
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//     [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE HH:mm:ss"];
////    NSString *yearByte =[dateFormatter stringFromDate:[NSDate date]];
//    
//     NSInteger yearFront =[[dateFormatter stringFromDate:[NSDate date]] integerValue];
//// NSString *hourStr =[dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setDateFormat:@"MM"];
//    NSString *monthStr =[dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setDateFormat:@"dd"];
//    NSString *dayStr = [dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setDateFormat:@"EEEE"];
//    NSString *weekStr = [dateFormatter stringFromDate:[NSDate date]];
//    NSInteger newWeekStr;
//    
//    if ([weekStr isEqualToString:NSLocalizedString(@"Monday", nil)]) {
//        
//        newWeekStr = 01;
//    }
//    else if ([weekStr isEqualToString:NSLocalizedString(@"Tuesday", nil)]) {
//        
//        newWeekStr = 02;
//    }else if ([weekStr isEqualToString:NSLocalizedString(@"Wednesday", nil)]) {
//        
//        newWeekStr = 03;
//    }else if ([weekStr isEqualToString:NSLocalizedString(@"Thursday", nil)]) {
//        
//        newWeekStr = 04;
//    }else if ([weekStr isEqualToString:NSLocalizedString(@"Friday", nil)]) {
//        
//        newWeekStr = 05;
//    }else if ([weekStr isEqualToString:NSLocalizedString(@"Saturday", nil)]) {
//        
//        newWeekStr = 06;
//    }else{
//        newWeekStr = 07;
//    }
//    
//    [dateFormatter setDateFormat:@"HH"];
//    NSString *hourStr =[dateFormatter stringFromDate:[NSDate date]];
//      [dateFormatter setDateFormat:@"mm"];
//    NSString *minStr =[dateFormatter stringFromDate:[NSDate date]];
//     [dateFormatter setDateFormat:@"ss"];
//    NSString *secStr = [dateFormatter stringFromDate:[NSDate date]];
//    _FirstYearByte =  (yearFront &0xff00) >>8;
//    _SecondYearByte = yearFront &0x00ff;
//    _ThirdMonthByte =[monthStr intValue];
//    _ForthDayByte = [dayStr intValue];
//    _FifthWeekByte = newWeekStr;
//    _SixthHourByte = [hourStr intValue];
//    _SeventhMinByte = [minStr intValue];
//    _EighthSecByte = [secStr intValue];
//    Byte content[] = {_FirstYearByte,_SecondYearByte,_ThirdMonthByte,_ForthDayByte,_FifthWeekByte,_SixthHourByte,_SeventhMinByte,_EighthSecByte};
//    
//    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
//    
//    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:76 binaryData:data];
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
//        if (!error) {
//            NSLog(@"%@",responseMsg.payload);
//            NSLog(@"校准时间");
//            
//        }
//    }];
//}

#pragma mark - 获取选择的时间
-(void)datePickerValueChanged:(UIDatePicker *)sender
{
    changed =1;
    ZJMTimerReverCell *cell = (ZJMTimerReverCell *)[self.reserTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    self.selectedDate = [cell.clockDatePicker date];
    NSLog(@"%@",self.selectedDate);
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSArray *languages = [NSLocale preferredLanguages]; //系统偏好语言
    NSString *language = languages.firstObject;
    NSLocale * locale;
    if ([language hasPrefix:@"zh-Hans"]) {
        locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
    }else{
        locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    }
    formatter.locale=locale;
   
    //将日期转为格式化好的字符串
    [formatter setDateFormat:@"HH"];
    _reserHourByte = [[formatter stringFromDate:self.selectedDate]integerValue];
    [formatter setDateFormat:@"mm"];
    _reserMinByte =[[formatter stringFromDate:self.selectedDate]integerValue];
    
    [self.reserTableView reloadData];
}

#pragma mark - 按钮事件
-(void)select:(UIButton *)sender{
    self.type=1;
     ZJMWeekChoiceCell *cell  = (ZJMWeekChoiceCell *)[_reserTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        if (sender.selected==YES) {
            sender.selected = NO;
            if (cell.MondayBtn.selected==NO &&cell.TuesdayBtn.selected==NO&&cell.WednesdayBtn.selected==NO &&cell.ThursdayBtn.selected==NO&&cell.FridayBtn.selected==NO &&cell.SaturdayBtn.selected==NO&&cell.WeekdayBtn.selected==NO) {
                cell.OnceBtn.selected = YES;
                
                selected= sender.selected;
            }
            
        }else{
            sender.selected = YES;
            cell.OnceBtn.selected = NO;
            
        }
        if (self.cellDidSelect==YES) {
            for (UIButton *btn in self.view.subviews) {
                
                switch (sender.tag) {
                        
                    case 2:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:0 withObject:NSLocalizedString(@"MON", nil)];
                            sender.selected=YES;
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:0 withObject:@""];
                        }
                        
                    }
                        break;
                    case 3:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:1 withObject:NSLocalizedString(@"TUE", nil)];
                            
                        }
                        else{
                            
                            [_reserWeekStrArrM replaceObjectAtIndex:1 withObject:@""];
                            NSLog(@"%@",_reserWeekStrArrM);
                        }
                    }
                        break;
                    case 4:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:2 withObject:NSLocalizedString(@"Wed",nil)];
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:2 withObject:@""];
                        }
                        
                    }
                        break;
                    case 5:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:3 withObject:NSLocalizedString(@"THUR",nil)];
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:3 withObject:@""];
                        }
                        
                    }
                        break;
                    case 6:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:4 withObject:NSLocalizedString(@"FRI",nil)];
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:4 withObject:@""];
                        }
                        
                    }
                        break;
                    case 7:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:5 withObject:NSLocalizedString(@"SAT",nil)];
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:5 withObject:@""];
                        }
                        
                    }
                        break;
                    case 8:{
                        if (sender.selected == YES) {
                            [_reserWeekStrArrM replaceObjectAtIndex:6 withObject:NSLocalizedString(@"SUN",nil)];
                        }
                        else{
                            [_reserWeekStrArrM replaceObjectAtIndex:6 withObject:@""];
                        }
                        
                    }
                        break;
                        
                    default:
                        break;
                        
                }
                
            }
            [_reserWeekStrArrM replaceObjectAtIndex:7 withObject:@""];
            NSLog(@"%@",_reserWeekStrArrM);
        }
        
        else{
          
            for (UIButton *btn in self.view.subviews) {
                
                switch (sender.tag) {
                        
                    case 2:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:0 withObject:NSLocalizedString(@"MON", nil)];
                            sender.selected=YES;
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:0 withObject:@""];
                        }
                        
                    }
                        break;
                    case 3:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:1 withObject:NSLocalizedString(@"TUE", nil)];
                            
                        }
                        else{
                            
                            [_weekArrM replaceObjectAtIndex:1 withObject:@""];
                        }
                    }
                        break;
                    case 4:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:2 withObject:NSLocalizedString(@"Wed",nil)];
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:2 withObject:@""];
                        }
                        
                    }
                        break;
                    case 5:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:3 withObject:NSLocalizedString(@"THUR",nil)];
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:3 withObject:@""];
                        }
                        
                    }
                        break;
                    case 6:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:4 withObject:NSLocalizedString(@"FRI",nil)];
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:4 withObject:@""];
                        }
                        
                    }
                        break;
                    case 7:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:5 withObject:NSLocalizedString(@"SAT",nil)];
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:5 withObject:@""];
                        }
                        
                    }
                        break;
                    case 8:{
                        if (sender.selected == YES) {
                            [_weekArrM replaceObjectAtIndex:6 withObject:NSLocalizedString(@"SUN",nil)];
                        }
                        else{
                            [_weekArrM replaceObjectAtIndex:6 withObject:@""];
                        }
                        
                    }
                        break;
                        
                    default:
                        break;
                        
                }
                
            }
            [_weekArrM replaceObjectAtIndex:7 withObject:NSLocalizedString(@"",nil)];
        }
          [_reserTableView reloadData];
    }
    else{
        sender.selected = !sender.selected;
        [_weekArrM removeAllObjects];
        if (cell.MondayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every MON", nil)];
        }
        if (cell.TuesdayBtn.selected) {
             [_weekArrM addObject:NSLocalizedString(@"Every TUE", nil)];
        }
        if (cell.WednesdayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every WED", nil)];
        }
        if (cell.ThursdayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every THUR", nil)];
        }
        if (cell.FridayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every FRI", nil)];
        }
        if (cell.SaturdayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every SAT", nil)];
        }
        if (cell.WeekdayBtn.selected) {
            [_weekArrM addObject:NSLocalizedString(@"Every SUN", nil)];
        }
        _oneWeekText = [[NSMutableString alloc] initWithString:@""];
        for (NSString * weekStr in _weekArrM) {
            if ([weekStr isEqualToString:_weekArrM[_weekArrM.count-1]]) {
                [_oneWeekText appendFormat:@"%@",weekStr];
            }else{
                [_oneWeekText appendFormat:@"%@,",weekStr];
            }
        }
        
        [_reserTableView reloadData];
    }
    
}

#pragma mark - 全选状态
-(void)allSelect{
     ZJMWeekChoiceCell *cell  = (ZJMWeekChoiceCell *)[_reserTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.MondayBtn.selected = NO;
    cell.TuesdayBtn.selected = NO;
    cell.WednesdayBtn.selected = NO;
    cell.ThursdayBtn.selected = NO;
    cell.FridayBtn.selected = NO;
    cell.SaturdayBtn.selected = NO;
    cell.WeekdayBtn.selected = NO;
    cell.OnceBtn.selected = YES;
    
    
}

#pragma mark - 只选仅一次
-(void)onceSelect:(UIButton *)sender{
    sender.selected = YES;
    [self allSelect];
    if (self.cellDidSelect==YES) {
        _reserWeekStrArrM =[@[@"",@"",@"",@"",@"",@"",@"",NSLocalizedString(@"Once", nil)]mutableCopy];
    }else{
        _weekArrM =  [@[@"",@"",@"",@"",@"",@"",@"",NSLocalizedString(@"Once", nil)]mutableCopy];
        
    }
    [_reserTableView reloadData];
}

#pragma mark - 保存预约
- (IBAction)saveRever:(UIButton *)sender {
    
    NSInteger MondayByte = 0;
    NSInteger TuesdayByte = 0;
    NSInteger WednesdayByte = 0;
    NSInteger ThursdayByte = 0;
    NSInteger FridayByte = 0;
    NSInteger SaturdayByte = 0;
    NSInteger WeekdayByte = 0;
    NSInteger OnceByte = 0;
    
    /* 已经预约的总数**/
    NSInteger _reserCount = 0;
    NSData *data = _receiveData;
    NSLog(@"%@",_receiveData);
    Byte reserByte[50];
    for (int i = 0; i< data.length; i++) {
        Byte *byte= (Byte *)[data bytes];
        reserByte[i]=byte[i];
        dataByte[i] = reserByte[i]; 
        
    }
    NSMutableArray *lastWeekArrM = [NSMutableArray array];
    NSMutableArray *lastTimeAndWeekArrM = [NSMutableArray array];
    NSMutableArray *lastTimeArrM = [NSMutableArray array];
    
    for (int i = 0; i<_receiveData.length; i++) {
        
        if (i % 5==0 &&(reserByte[i+2] != 0)) {
            _reserCount ++;
            index = @(i/5+1);
            week = dataByte[i+2];
            hour = dataByte[i+3];
            min = dataByte[i+4];
        }
        
        NSString *lastWeek = [NSString stringWithFormat:@"%@",[self ToHex:week]];
        NSString *lastTime = [NSString stringWithFormat:@"%@:%@",[self ToHex:hour],[self ToHex:min]];
        NSString *lastTimeAndWeek = [NSString stringWithFormat:@"%@%@:%@",lastWeek,[self ToHex:hour],[self ToHex:min]];
        [lastTimeAndWeekArrM addObject:lastTimeAndWeek];
        [lastTimeArrM addObject:lastTime];
        [lastWeekArrM addObject:lastWeek];
        if (_numberArrM.count !=0) {
            [_numberArrM removeObject:index];
            
            if (_numberArrM.count >0) {
                neverReserNum = [_numberArrM[0] integerValue];
            }
        }
    }
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]){
      
        if ([_weeksStr containsString:NSLocalizedString(@"Mon",nil)]) {
            MondayByte = 1;
        }
        if ([_weeksStr containsString:NSLocalizedString(@"Tue",nil)]){
            TuesdayByte = 2;
        }
        if ([_weeksStr containsString:NSLocalizedString(@"Wed",nil)]){
            WednesdayByte = 4;
        }
        if ([_weeksStr containsString:NSLocalizedString(@"THUR",nil)]){
            ThursdayByte = 8;
        }
        if ([_weeksStr containsString:NSLocalizedString(@"FRI",nil)]){
            FridayByte = 16;
            
        }
        if ([_weeksStr containsString:NSLocalizedString(@"SAT",nil)]){
            SaturdayByte = 32;
        }
        if ([_weeksStr containsString:NSLocalizedString(@"SUN",nil)]){
            WeekdayByte = 64;
        }else if([_weeksStr containsString:NSLocalizedString(@"Once",nil)]){
            OnceByte = 128;
        }
        _MoreSelectByte = MondayByte+TuesdayByte+WednesdayByte+ThursdayByte+FridayByte+SaturdayByte+ WeekdayByte+OnceByte;
        NSString *moreSelectStr = [self ToHex:_MoreSelectByte];
        NSString *currentTime = [NSString stringWithFormat:@"%@%@",moreSelectStr,_reserTime];
        
        if ([lastTimeAndWeekArrM containsObject:currentTime]&&(self.cellDidSelect==YES)) {
            [self showHudWithString:NSLocalizedString(@"Same Planning Already Exist", nil)];
            
        }
        //添加预约
        else if ([lastTimeArrM containsObject:_reserTime]&&(self.cellDidSelect==NO)){
            [self showHudWithString:NSLocalizedString(@"Same Planning Already Exist", nil)];
        }
        else if(_reserCount == 10){
            
            [self showHudWithString:NSLocalizedString(@"You Could Add Maximum 7 Plannings", nil)];
        }
        else{
            if (self.cellDidSelect ==YES) {
                dataByte[((_reserNumber-1)*5)+1] =1;
                dataByte[((_reserNumber-1)*5)+2] =_MoreSelectByte;
                dataByte[((_reserNumber-1)*5)+3] =_reserHourByte;
                dataByte[((_reserNumber-1)*5)+4] =_reserMinByte;
                sendData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
                
            }
            else{
                for (int i = 0; i<_receiveData.length; i++) {
                    if (i % 5==0 &&(reserByte[i+2] != 0)) {
                        dataByte[((neverReserNum-1)*5)+1] = 1;
                        dataByte[((neverReserNum-1)*5)+2] = _MoreSelectByte;
                        dataByte[((neverReserNum-1)*5)+3] = _reserHourByte;
                        dataByte[((neverReserNum-1)*5)+4] = _reserMinByte;
                        sendData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
                        
                    } else{
                        neverReserNum = [_numberArrM[0] integerValue];
                        dataByte[((neverReserNum-1)*5)+1] = 1;
                        dataByte[((neverReserNum-1)*5)+2] = _MoreSelectByte;
                        dataByte[((neverReserNum-1)*5)+3] = _reserHourByte;
                        dataByte[((neverReserNum-1)*5)+4] = _reserMinByte;
                        sendData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
                    }
                }
            }
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ACDeviceMsg *deviceMsg = [[ACDeviceMsg alloc]initWithCode:74 binaryData:sendData];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    
                    [self showHudWithString:NSLocalizedString(@"Planning Failed, Please Add Again", nil)];
                }
            }];
        }
    }else{
        if (self.cellDidSelect == YES && self.type == 1) {
            for (NSString * reserNumber in self.reserNumArr) {
                dataByte[([reserNumber integerValue]*5)+1]= 0;
                dataByte[([reserNumber integerValue]*5)+2] = 0;
                dataByte[([reserNumber integerValue]*5)+3] = 0;
                dataByte[([reserNumber integerValue]*5)+4] = 0;
            }
        }
        
        for (NSString * str in _weekArrM) {
            NSInteger MondayByte = 0;
            NSInteger TuesdayByte = 0;
            NSInteger WednesdayByte = 0;
            NSInteger ThursdayByte = 0;
            NSInteger FridayByte = 0;
            NSInteger SaturdayByte = 0;
            NSInteger WeekdayByte = 0;
            NSInteger OnceByte = 0;
            if ([str containsString:NSLocalizedString(@"Every MON",nil)]) {
                MondayByte = 1;
            }
            if ([str containsString:NSLocalizedString(@"Every TUE",nil)]){
                TuesdayByte = 2;
            }
            if ([str containsString:NSLocalizedString(@"Every WED",nil)]){
                WednesdayByte = 4;
            }
            if ([str containsString:NSLocalizedString(@"Every THUR",nil)]){
                ThursdayByte = 8;
            }
            if ([str containsString:NSLocalizedString(@"Every FRI",nil)]){
                FridayByte = 16;
            }
            if ([str containsString:NSLocalizedString(@"Every SAT",nil)]){
                SaturdayByte = 32;
            }
            if ([str containsString:NSLocalizedString(@"Every SUN",nil)]){
                WeekdayByte = 64;
            }
            _MoreSelectByte = MondayByte+TuesdayByte+WednesdayByte+ThursdayByte+FridayByte+SaturdayByte+ WeekdayByte+OnceByte;
//            NSString *moreSelectStr = [self ToHex:_MoreSelectByte];
//            NSString *currentTime = [NSString stringWithFormat:@"%@%@",moreSelectStr,_reserTime];
           
            if ((changed == YES && self.cellDidSelect == YES) || (self.type == 1 &&(self.cellDidSelect==YES)) || self.cellDidSelect == NO) {
                NSInteger count;
                if (_MoreSelectByte==1) {
                    
                    count=0;
                }
                else if (_MoreSelectByte==2){
                    count=1;
                }
                else if (_MoreSelectByte==4){
                    count=2;
                }
                else if(_MoreSelectByte ==8){
                    count=3;
                }
                else if (_MoreSelectByte==16){
                    count=4;
                }
                else if(_MoreSelectByte==32){
                    count=5;
                }
                else{
                    count=6;
                }
                
                dataByte[(count*5)+1]= 1;
                dataByte[(count*5)+2] = _MoreSelectByte;
                dataByte[(count*5)+3] = _reserHourByte;
                dataByte[(count*5)+4] = _reserMinByte;
                sendData = [NSData dataWithBytes:dataByte length:sizeof(dataByte)];
            }else {
                [self showHudWithString:NSLocalizedString(@"Same Planning Already Exist", nil)];
                return;
            }
            
        }
        if (_weekArrM.count == 0) {
            [self showHudWithString:NSLocalizedString(@"Please Select The Repeat Date", nil)];
        }else{
            [self showHudWithRound];
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            ACDeviceMsg *deviceMsg = [[ACDeviceMsg alloc]initWithCode:74 binaryData:sendData];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:deviceMsg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                [self hideHud];
                if (!error) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    switch (error.code) {
                        case 3807:
                            [self showHudWithString:NSLocalizedString(@"Device Offline", nil)];
                            break;
                            
                        default: [self showHudWithString:NSLocalizedString(@"Planning Failed, Please Add Again", nil)];
                            break;
                    }
                    
                }
            }];
        }
       
    }
   
  
    
}

#pragma mark - 取消预约
- (IBAction)cancelRever:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
