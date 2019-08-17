//
//  ZJMCleanRecordVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMCleanRecordVC.h"
#import "ZJMCleanRecordCell.h"
#import "ZJMCleanRecordModel.h"
#import "ZJMRecordDetailVC.h"
@interface ZJMCleanRecordVC ()
@property (weak, nonatomic) IBOutlet UITableView *cleanRecordTableView;

@property (atomic,assign)int index;
@property(nonatomic,strong)NSMutableArray *cleanRecordArrM;
@property (nonatomic,copy)NSString *cleanArea;
@property (strong, nonatomic) IBOutlet UIView *neverRecordView;
@property (weak, nonatomic) IBOutlet UILabel *neverRecordLab;
@property (strong,nonatomic)ZJMCleanRecordModel *model;
@property (strong,nonatomic)NSMutableData *mapData;
@property (nonatomic)NSInteger start;
@property (nonatomic)NSInteger end;
@end

@implementation ZJMCleanRecordVC
{
    NSMutableData *cleanData;
    NSString *serviceName;
}

-(void)viewWillAppear:(BOOL)animated{
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.index=1;
    
    [self.cleanRecordTableView registerNib:[UINib nibWithNibName:@"ZJMCleanRecordCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    _cleanRecordArrM = [NSMutableArray array];
    self.neverRecordLab.text = NSLocalizedString(@"No History Record", nil);
    [self getCleanHistoryData];
    
}



#pragma mark - 清扫历史记录数据
-(void)getCleanHistoryData{
    Weakself;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (delegate.appRegion) {
        case 0:
            if ([self.subDomain isEqualToString:X420SubDomain]) {
                serviceName = Service_Name_X420_CN;
            }else if ([self.subDomain isEqualToString:X430SubDomain]) {
                serviceName = Service_Name_X430_CN;
            } else if ([self.subDomain isEqualToString:X660SubDomain]){
                serviceName = Service_Name_X660_CN;
            }else if ([self.subDomain isEqualToString:X610SubDomain]){
                serviceName = Service_Name_X610_CN;
            }else if ([self.subDomain isEqualToString:X620SubDomain]){
                serviceName = Service_Name_X620_CN;
            }else if ([self.subDomain isEqualToString:X782SubDomain]){
                serviceName = Service_Name_X782_CN;
            }
            else if ([self.subDomain isEqualToString:X785SubDomain]){
                serviceName = Service_Name_X785_CN;
            }else if ([self.subDomain isEqualToString:X786SubDomain]){
                serviceName = Service_Name_X786_CN;
            }
            else if ([self.subDomain isEqualToString:X787SubDomain]){
                serviceName = Service_Name_X787_CN;
            }if ([self.subDomain isEqualToString:X790SubDomain]) {
                serviceName = Service_Name_X790_CN;
            }
            else if ([self.subDomain isEqualToString:X800SubDomain]){
                serviceName = Service_Name_X800_CN;
            }
            else if ([self.subDomain isEqualToString:X900SubDomain]){
                serviceName = Service_Name_X900_CN;
            }else if ([self.subDomain isEqualToString:X910SubDomain]){
                serviceName = Service_Name_X910_CN;
            }
            break;
        case 1:
            if ([self.subDomain isEqualToString:X420SubDomain]) {
                serviceName = Service_Name_X420_SA;
            }else if ([self.subDomain isEqualToString:X430SubDomain]) {
                serviceName = Service_Name_X430_SA;
            } else if ([self.subDomain isEqualToString:X660SubDomain]){
                serviceName = Service_Name_X660_SA;
            }else if ([self.subDomain isEqualToString:X610SubDomain]){
                serviceName = Service_Name_X610_SA;
            }else if ([self.subDomain isEqualToString:X620SubDomain]){
                serviceName = Service_Name_X620_SA;
            }else if ([self.subDomain isEqualToString:X782SubDomain]){
                serviceName = Service_Name_X782_SA;
            }
            else if ([self.subDomain isEqualToString:X785SubDomain]){
                serviceName = Service_Name_X785_SA;
            }else if ([self.subDomain isEqualToString:X786SubDomain]){
                serviceName = Service_Name_X786_SA;
            }
            else if ([self.subDomain isEqualToString:X787SubDomain]){
                serviceName = Service_Name_X787_SA;
            }else if ([self.subDomain isEqualToString:X790SubDomain]){
                serviceName = Service_Name_X790_SA;
            }
            else if ([self.subDomain isEqualToString:X800SubDomain]){
                serviceName = Service_Name_X800_SA;
            }else if ([self.subDomain isEqualToString:X900SubDomain]){
                serviceName = Service_Name_X900_SA;
            } else if ([self.subDomain isEqualToString:X910SubDomain]){
                serviceName = Service_Name_X910_SA;
            }
            break;
        case 2:
            if ([self.subDomain isEqualToString:X420SubDomain]) {
                serviceName = Service_Name_X420_EU;
            }else if ([self.subDomain isEqualToString:X430SubDomain]) {
                serviceName = Service_Name_X430_EU;
            } else if ([self.subDomain isEqualToString:X660SubDomain]){
                serviceName = Service_Name_X660_EU;
            }else if ([self.subDomain isEqualToString:X610SubDomain]){
                serviceName = Service_Name_X610_EU;
            }else if ([self.subDomain isEqualToString:X620SubDomain]){
                serviceName = Service_Name_X620_EU;
            }
            else if ([self.subDomain isEqualToString:X782SubDomain]){
                serviceName = Service_Name_X782_EU;
            }
            else if ([self.subDomain isEqualToString:X785SubDomain]){
                serviceName = Service_Name_X785_EU;
            }else if ([self.subDomain isEqualToString:X786SubDomain]){
                serviceName = Service_Name_X786_EU;
            }
            else if ([self.subDomain isEqualToString:X787SubDomain]){
                serviceName = Service_Name_X787_EU;
            }else if ([self.subDomain isEqualToString:X790SubDomain]){
                serviceName = Service_Name_X790_EU;
            }
            else if ([self.subDomain isEqualToString:X800SubDomain]){
                serviceName = Service_Name_X800_EU;
            }else if ([self.subDomain isEqualToString:X900SubDomain]){
                serviceName = Service_Name_X900_EU;
            }else if ([self.subDomain isEqualToString:X910SubDomain]){
                serviceName = Service_Name_X910_EU;
            }
            break;
        case 3:
            if ([self.subDomain isEqualToString:X420SubDomain]) {
                serviceName = Service_Name_X420_NA;
            }else if ([self.subDomain isEqualToString:X430SubDomain]) {
                serviceName = Service_Name_X430_NA;
            } else if ([self.subDomain isEqualToString:X660SubDomain]){
                serviceName = Service_Name_X660_NA;
            }else if ([self.subDomain isEqualToString:X610SubDomain]){
                serviceName = Service_Name_X610_NA;
            }else if ([self.subDomain isEqualToString:X620SubDomain]){
                serviceName = Service_Name_X620_NA;
            }
            else if ([self.subDomain isEqualToString:X782SubDomain]){
                serviceName = Service_Name_X782_NA;
            }
            else if ([self.subDomain isEqualToString:X785SubDomain]){
                serviceName = Service_Name_X785_NA;
            }else if ([self.subDomain isEqualToString:X786SubDomain]){
                serviceName = Service_Name_X786_NA;
            }
            else if ([self.subDomain isEqualToString:X787SubDomain]){
                serviceName = Service_Name_X787_NA;
            } else if ([self.subDomain isEqualToString:X790SubDomain]){
                serviceName = Service_Name_X790_NA;
            }
            else if ([self.subDomain isEqualToString:X800SubDomain]){
                serviceName = Service_Name_X800_NA;
            }else if ([self.subDomain isEqualToString:X900SubDomain]){
                serviceName = Service_Name_X900_NA;
            }else if ([self.subDomain isEqualToString:X910SubDomain]){
                serviceName = Service_Name_X910_NA;
            }
            break;
        default:
            break;
    }
    [weakSelf showHudWithRound];
    
    __block NSMutableArray *dataArrM = [NSMutableArray array];
    __block void (^blocks)(int);
    blocks = ^(int _index){
        if(_index< 8){
            ACMsg *msg = [ACMsg msgWithName:@"searchCleanHistory"];
            [msg putInteger:@"device_id" value:_deviceID];
            [msg putInteger:@"record_index" value:_index];
            
            [ACloudLib sendToService:serviceName version:1 msg:msg callback:^(ACMsg *responseMsg, NSError *error) {
                [weakSelf hideHud];
                if (!error) {
                    _mapData = [[NSMutableData alloc]init];
                    NSMutableData * tempData = [[NSMutableData alloc] init];
                    ZJMCleanRecordModel *cleanRecordModel = [[ZJMCleanRecordModel alloc]init];
                    blocks(_index + 1);
                    NSDictionary *dict =[responseMsg getObjectData];
                    dataArrM = dict[@"data"];
                    NSString *cleanStr;
                    NSString *firstStr;
                    if (dataArrM.count>0) {
                        NSString *start_time= dataArrM[0][@"start_time"];
                        int cleanArea = [dataArrM[0][@"clean_area"]intValue];
                        int workTime;
                        NSData * firstData;
                        if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
                            workTime = [dataArrM[0][@"clean_time"]intValue];
                            cleanRecordModel.slam_x_min = [dataArrM[0][@"slam_x_min"]intValue];
                            cleanRecordModel.slam_x_max = [dataArrM[0][@"slam_x_max"]intValue];
                            cleanRecordModel.slam_y_min = [dataArrM[0][@"slam_y_min"]intValue];
                            cleanRecordModel.slam_y_max = [dataArrM[0][@"slam_y_max"]intValue];
                            _end = [dataArrM[0][@"stop_reason"]integerValue];
                            _start = [dataArrM[0][@"start_reason"]integerValue];
                            for (int i = 0; i<dataArrM.count; i++) {
                                cleanStr = [NSString stringWithFormat:@"%@",dataArrM[i][@"clean_slam"]];
                                firstStr = [NSString stringWithFormat:@"%@",dataArrM[i][@"clean_road"]];
                                if (![cleanStr isEqualToString:@""]) {
                                    if (i == 0) {
                                        cleanData = [[NSMutableData alloc] initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                        [_mapData appendData:cleanData];
                                    }else{
                                        cleanData = [[NSMutableData alloc] initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                        NSData *data = [cleanData subdataWithRange:NSMakeRange(2, [cleanData length] -2)];
                                        [_mapData appendData:data];
                                        
                                    }
                                }
                                if (![firstStr isEqualToString:@""]) {
                                    cleanData = [[NSMutableData alloc] initWithBase64EncodedString:firstStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                    [tempData appendData:cleanData];
                                    
                                }
                                
                            }
                        }else{
                            if ([self.subDomain isEqualToString:X785SubDomain]||[self.subDomain isEqualToString:X787SubDomain]||[self.subDomain isEqualToString:X782SubDomain]) {
                                workTime=[dataArrM[0][@"work_time"]intValue]+10;
                            } else {
                                workTime =[dataArrM[0][@"work_time"]intValue];
                            }
                            firstStr =[NSString stringWithFormat:@"%@",dataArrM[0][@"clean_data"]];
                            if (![firstStr isEqualToString:@""]) {
                                firstData= [[NSMutableData alloc]initWithBase64EncodedString:firstStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            }
                            if ([self.subDomain isEqualToString:X790SubDomain]) {
                                _start = [dataArrM[0][@"start_reason"]integerValue];
                                _end=[dataArrM[0][@"stop_reason"]integerValue];
                                for (int i = 0; i<dataArrM.count; i++) {
                                    cleanStr = [NSString stringWithFormat:@"%@",dataArrM[i][@"clean_data"]];
                                    if (![cleanStr isEqualToString:@""]) {
                                        if (i == 0) {
                                            cleanData = [[NSMutableData alloc] initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                            [_mapData appendData:cleanData];
                                        }else{
                                            cleanData = [[NSMutableData alloc] initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                            NSData *data = [cleanData subdataWithRange:NSMakeRange(2, [cleanData length] -2)];
                                            [_mapData appendData:data];
                                            
                                        }
                                    }
                                    
                                }
                            }else{
                                for (int i = 0; i< dataArrM.count;i++) {
                                    cleanStr = [NSString stringWithFormat:@"%@", dataArrM[i][@"clean_data"]];
                                    if (![cleanStr isEqualToString:@""]) {
                                        cleanData= [[NSMutableData alloc]initWithBase64EncodedString:cleanStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                        NSData *data = [cleanData subdataWithRange:NSMakeRange(1, [cleanData length]-1)];
                                        [_mapData appendData:data];
                                    }
                                    
                                }
                            }
                        }
                        if (start_time) {
                            NSTimeInterval time=[start_time doubleValue];
                            NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
                            NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
                            NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
                            NSString *languageName = [appLanguages objectAtIndex:0];
                            
                            //中文
                            if ([languageName containsString:@"Han"]==YES) {
                                [dateFormater setDateFormat:@"MM月dd日"];
                            }else{
                                //英文
                                [dateFormater setDateFormat:@"MM/dd"];
                            }
                            cleanRecordModel.day =[dateFormater stringFromDate:date];
                            [dateFormater setDateFormat:@"HH:mm"];
                            cleanRecordModel.time =[dateFormater stringFromDate:date];
                            cleanRecordModel.clean_area = cleanArea;
                            cleanRecordModel.clean_time = workTime;
                            cleanRecordModel.data = _mapData;
                            cleanRecordModel.roadData = tempData;
                            cleanRecordModel.firstData=firstData;
                            cleanRecordModel.start=_start;
                            cleanRecordModel.end=_end;
                            
                        }
                        [self.cleanRecordArrM addObject:cleanRecordModel];
                        [self.cleanRecordTableView reloadData];
                    }
                    if (self.cleanRecordArrM.count==0){
                        _cleanRecordTableView.backgroundView= _neverRecordView;
                    }else{
                        
                        _cleanRecordTableView.backgroundView=nil;
                    }
                    
                }else{
                    [weakSelf hideHud];
                    _cleanRecordTableView.backgroundView= _neverRecordView;
                }
                
            }];
        }
        
    };
    
    blocks(1);
    
    
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREENHEIGHT*0.1;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cleanRecordArrM.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZJMCleanRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSSortDescriptor *scoreTime=[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO];
    NSSortDescriptor *scoreDay=[NSSortDescriptor sortDescriptorWithKey:@"day" ascending:NO];
    self.cleanRecordArrM = [[self.cleanRecordArrM sortedArrayUsingDescriptors:@[scoreDay,scoreTime]] mutableCopy];
    
    ZJMCleanRecordModel *cleanRecordModel = self.cleanRecordArrM[indexPath.row];
    cell.dayLab.text=cleanRecordModel.day;
    cell.timeLab.text =cleanRecordModel.time;
    NSDictionary *dic = @{NSKernAttributeName:@2.f};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cell.dayLab.text attributes:dic];
    
    cell.dayLab.attributedText = attributedString;
    NSString *clean = NSLocalizedString(@"Cleaning", nil);
    NSString *duration =NSLocalizedString(@"Duration", nil);
    cell.cleanareaLab.text=[NSString stringWithFormat:@"%@%dm²",clean,cleanRecordModel.clean_area];
    cell.cleantimeLab.text = [NSString stringWithFormat:@"%@%dmin",duration,cleanRecordModel.clean_time/60];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.cleanRecordArrM.count>0) {
        ZJMCleanRecordModel *model =self.cleanRecordArrM[indexPath.row];
        ZJMRecordDetailVC *recordDetailVc=  [[ZJMRecordDetailVC alloc]init];
        recordDetailVc.title =NSLocalizedString(@"Record Detail", nil);
        recordDetailVc.mapData = model.data;
        recordDetailVc.firstData=model.firstData;
        recordDetailVc.subDomain = _subDomain;
        recordDetailVc.startReason = model.start;
        recordDetailVc.endReanson = model.end;
        if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
            recordDetailVc.roadData = model.roadData;
            recordDetailVc.slam_x_min = model.slam_x_min;
            recordDetailVc.slam_x_max=model.slam_x_max;
            recordDetailVc.slam_y_min = model.slam_y_min;
            recordDetailVc.slam_y_max=model.slam_y_max;
           
            
        }
        [self.navigationController pushViewController:recordDetailVc animated:YES];
    }
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
