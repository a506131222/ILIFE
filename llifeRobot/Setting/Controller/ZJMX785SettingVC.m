//
//  ZJMX785SettingVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/4/12.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMX785SettingVC.h"
#import "ZJMAddReserVC.h"
#import "ZJMConsumablesSituationVC.h"
#import "ZJMCleanModeCell.h"
#import "ZJMDeviceNameVC.h"
#import "ZJMCleanRecordVC.h"
#import "ZJMWaterModelCell.h"
#import "timeoutManager.h"

@interface ZJMX785SettingVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *setTableView;
@property (strong,nonatomic)NSMutableArray *LabelList;
@property (assign, nonatomic) BOOL isExpand;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)  UIButton  *selectedBtn;
@property (nonatomic,copy)ACUserDevice *userDevice;
@property (nonatomic,retain)UISwitch *switchView;
@property (nonatomic,assign)BOOL status;
@property (nonatomic,copy)NSString *robotName;
@property (nonatomic,copy)NSString *Name;
@property (nonatomic,copy)NSString *maxStr;
@property(nonatomic,strong) NSMutableArray<DeviceMsg *> *deviceList;
@property (nonatomic,copy)NSString *cleanModel;
@property (nonatomic,copy)NSString *workModel;
@property (nonatomic)BOOL waterExpand;
@property (nonatomic) NSInteger currentRow;
@property (nonatomic)BOOL allExpand;
@property (nonatomic,copy)NSString *waterMode;
@property (nonatomic)BOOL isOn;
@property (nonatomic)BOOL isClick;
@property (nonatomic)BOOL isPlanMode;
@property(nonatomic)BOOL mode;
@property (nonatomic)BOOL hideExpand;
@property (nonatomic,strong)NSMutableArray *cleanModeList;
@property (nonatomic,strong)NSMutableArray *waterModeList;
@property (nonatomic)BOOL oneShow;
@property (nonatomic,strong)AppDelegate *appDele;
@end


@implementation ZJMX785SettingVC
{
    
    NSString *cleanText;
    Byte  byte [1];
    int _downTime;
    NSInteger type;
    NSString *_statusStr;
    dispatch_source_t timer;
    BOOL select;
    NSInteger tag;
    NSString *waterStr;
    NSInteger waterTag;
    NSInteger row;
}
static  dispatch_source_t timer;
-(NSMutableArray *)deviceList{
    if (_deviceList==nil) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}
-(NSMutableArray *)cleanModeList{
    if (!_cleanModeList) {
        _cleanModeList = [NSMutableArray array];
    }
    return _cleanModeList;
}
-(NSMutableArray *)waterModeList{
    if (!_waterModeList) {
        _waterModeList = [NSMutableArray array];
    }
    return _waterModeList;
}
//-(UISwitch *)switchView{
//    if (!_switchView) {
//
//    }
//    return _switchView;
//}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_downTime > 0 && _downTime!=10) {
        timeoutManager *manager = [timeoutManager sharedTimerManager];
        manager.timeout = _downTime;
        [manager countDown];
        
        
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    timeoutManager *manager = [timeoutManager sharedTimerManager];
    int temp = manager.timeout;
    if (temp > 0) {
        _downTime= temp; //倒计时时间
        [self countDown];
        
    }else{
        _downTime=10;
    }
    [self listenPropertyValueChange];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    Byte byte[] = {0};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    [self demandDeviceStatusdata:data];
    
    
}

#pragma mark - 查询设备状态
-(void)demandDeviceStatusdata:(NSData *)data{
    Weakself;
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:65 binaryData:data];
    [self showHudWithRound];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        StrongSelf;
        [weakSelf hideHud];
        if (!error) {
            if ([responseMsg getBinaryData]) {
                NSData *statusData =[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(0, 1)];
                _statusStr = [self convertDataToHexStr:statusData];
                NSData *waterData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(4, 1)];
                waterStr = [self convertDataToHexStr:waterData];
                NSData *maxData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(3, 1)];
                _maxStr = [self convertDataToHexStr:maxData];
                if ([_statusStr isEqualToString:@"5"]||[_statusStr isEqualToString:@"05"]){
                    self.isOn = YES;
                    
                }else if ([_statusStr isEqualToString:@"8"]||[_statusStr isEqualToString:@"08"]){
                    self.isOn=NO;
                    
                }else{
                    if ([_maxStr isEqualToString:@"01"]) {
                        self.isOn=YES;
                        
                    }else{
                        self.isOn=NO;
                        
                    }
                    
                }
                if ([waterStr isEqualToString:@"00"]) {
                    weakSelf.waterMode = NSLocalizedString(@"Soft", nil);
                }else if ([waterStr isEqualToString:@"01"]){
                    weakSelf.waterMode = NSLocalizedString(@"Normal", nil);
                }else if ([waterStr isEqualToString:@"02"]){
                    weakSelf.waterMode = NSLocalizedString(@"Strong", nil);
                }
            }
        }else{
            [weakSelf hideHud];
        }
        [weakSelf.setTableView reloadData];
    }];
}
#pragma mark - 状态属性监听
-(void)listenPropertyValueChange{
    [ACDeviceDataManager subscribePropDataWithSubDomain:_subDomain deviceId:_deviceID callback:^
     (NSError *error) {
         
         if (!error) {
             
             [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                 
                 _cleanModel = [[properties get:@"vacuum_cleaning"] stringValue];
                 _workModel = [[properties get:@"work_pattern"]stringValue];
                 if ([_workModel isEqualToString:@"5"]||[_workModel isEqualToString:@"05"]){
                     _switchView.on = YES;
                     self.isOn = YES;
                     
                 }else if ([_workModel isEqualToString:@"8"]||[_workModel isEqualToString:@"08"]){
                     _switchView.on = NO;
                     self.isOn=NO;
                     
                 }else{
                     if ([_cleanModel isEqualToString:@"01"]) {
                         self.isOn=YES;
                         _switchView.on = YES;
                     }else{
                         self.isOn=NO;
                         _switchView.on = NO;
                         
                     }
                     
                 }
             }];
         }
     }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
      _appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
     _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    _switchView.onTintColor = [UIColor whiteColor];
    if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1)  {
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Cleaning Mode", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else if ([self.subDomain isEqualToString:X786SubDomain]){
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Cleaning Mode", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else{
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Cleaning Mode", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }
    
    _cleanModeList =[@[NSLocalizedString(@"Auto Mode", nil),
                       NSLocalizedString(@"Classic Mode", nil)]mutableCopy];
    _waterModeList = [@[NSLocalizedString(@"Soft", nil),
                        NSLocalizedString(@"Normal", nil),
                        NSLocalizedString(@"Strong", nil)]mutableCopy];
    [self.setTableView registerNib:[UINib nibWithNibName:@"ZJMCleanModeCell" bundle:nil] forCellReuseIdentifier:@"ZJMCleanModeCell"];
    [self.setTableView registerNib:[UINib nibWithNibName:@"ZJMWaterModelCell" bundle:nil] forCellReuseIdentifier:@"ZJMWaterModelCell"];
    
    type=1;
    select=YES;
    
    //    _waterExpand=YES;
    _isExpand=NO;
    _allExpand=NO;
    _selectedIndexPath=nil;
    _switchView = [[UISwitch alloc]init];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhone5)
    {
        
        return 50;
    }
    else if(iPhone6)
    {
        
        return 60;
    }else
    {
        
        return 70;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_LabelList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        
        if (_isExpand == YES)
        {
            if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1) {
                return [_LabelList[0] count]+_cleanModeList.count;
            }else{
                if (self.waterExpand==YES)
                {
                    return [_LabelList[0] count]+_cleanModeList.count+_waterModeList.count;
                }
                else
                {
                    return [_LabelList[0] count]+_cleanModeList.count;
                }
            }
            
        }
        else
        {
            if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1) {
                return [_LabelList[0] count];
            }else{
                if (self.waterExpand==YES)
                {
                    return [_LabelList[0] count]+_waterModeList.count;
                }
                else
                {
                    return [_LabelList[0] count];
                }
            }
            
        }
    }
    else {
        return 3;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1) {
        if (_isExpand==YES&& (indexPath.row==4 ||indexPath.row==5)){
            ZJMCleanModeCell *cell =[self.setTableView dequeueReusableCellWithIdentifier:@"ZJMCleanModeCell" forIndexPath:indexPath];
            
            if (indexPath.row==4) {
                cell.starCleanText.text=NSLocalizedString(@"Nav", nil);
                
            }else if (indexPath.row==5){
                cell.starCleanText.text = NSLocalizedString(@"Random", nil);
            }
            cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
            if (_mode==NO){
                if (indexPath.row==4) {
                    
                    cell.starCleanBtn.selected=YES;
                    
                }else if (indexPath.row==5){
                    cell.starCleanBtn.selected=NO;
                    
                }
            }else{
                if (indexPath.row==4) {
                    cell.starCleanBtn.selected=NO;
                }else if (indexPath.row==5){
                    cell.starCleanBtn.selected=YES;
                }
            }
            
            return cell;
            
        }else{
            _mode= [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
            NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld",indexPath.row];
            // 通过唯一标识创建cell实例
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                if (_isExpand==NO) {
                    cell.textLabel.text = _LabelList[indexPath.section][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                    float arrowImageH = cell.bounds.size.height/3;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    
                    if (indexPath.section ==1 && indexPath.row ==0){
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.accessoryView = nil;
                        
                    }else if(indexPath.section ==1 &&indexPath.row ==1){
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.accessoryView = nil;
                        cell.detailTextLabel.text = _deviceName;
                        
                    }
                }
                
            }
            if (indexPath.section==0) {
                if (indexPath.row == 3) {
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    if (_mode==NO) {
                        cell.detailTextLabel.text=NSLocalizedString(@"Nav", nil);
                        
                    }else{
                        cell.detailTextLabel.text=NSLocalizedString(@"Random", nil);
                    }
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
                }
                if (indexPath.row == 4 || indexPath.row == 6) {
                    cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                    cell.accessoryView = _switchView;
                    _switchView.onTintColor = HexColor(0x00BDB5);
                    _switchView.on=_isOn;
                    [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                }
                
            }
            
            return cell;
        }
    }else{
        if ([self.subDomain isEqualToString:X786SubDomain]) {
            if (_isExpand==YES&& (indexPath.row==3 ||indexPath.row==4)){
                ZJMCleanModeCell *cell =[self.setTableView dequeueReusableCellWithIdentifier:@"ZJMCleanModeCell" forIndexPath:indexPath];
                
                if (indexPath.row==3) {
                    cell.starCleanText.text=NSLocalizedString(@"Nav", nil);
                    if (_mode == NO) {
                        cell.starCleanBtn.selected = YES;
                    }else{
                        cell.starCleanBtn.selected = NO;
                    }
                    
                }else if (indexPath.row==4){
                    cell.starCleanText.text = NSLocalizedString(@"Random", nil);
                    if (_mode == YES) {
                        cell.starCleanBtn.selected = YES;
                    }else{
                        cell.starCleanBtn.selected = NO;
                    }
                }
                cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];

                return cell;
                
                
            }else if (_isExpand==NO&&_waterExpand==YES&& (indexPath.row==4 ||indexPath.row==5 ||indexPath.row==6)){
                ZJMWaterModelCell *cell = [self.setTableView dequeueReusableCellWithIdentifier:@"ZJMWaterModelCell" forIndexPath:indexPath];
                if (indexPath.row==4) {
                    cell.waterModeLab.text = NSLocalizedString(@"Soft", nil),
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water1"] forState:UIControlStateNormal];
                    
                    if ([waterStr isEqualToString:@"00"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }else if (indexPath.row==5){
                    cell.waterModeLab.text = NSLocalizedString(@"Normal", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water2"] forState:UIControlStateNormal];
                    
                    if ([waterStr isEqualToString:@"01"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }else if (indexPath.row==6){
                    cell.waterModeLab.text = NSLocalizedString(@"Strong", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water3"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"02"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                    
                }
                
                return cell;
            }else if (_isExpand==YES&&_waterExpand==YES &&(indexPath.row==6 ||indexPath.row==7||indexPath.row==8)){
                ZJMWaterModelCell *cell = [self.setTableView dequeueReusableCellWithIdentifier:@"ZJMWaterModelCell" forIndexPath:indexPath];
                if (indexPath.row==6) {
                    cell.waterModeLab.text = NSLocalizedString(@"Soft", nil),
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water1"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"00"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }if (indexPath.row==7){
                    cell.waterModeLab.text =  NSLocalizedString(@"Normal", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water2"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"01"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                }if (indexPath.row==8){
                    cell.waterModeLab.text = NSLocalizedString(@"Strong", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water3"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"02"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }
                
                return cell;
            }
            
            else{
                _mode= [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
                NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld",indexPath.row];
                // 通过唯一标识创建cell实例
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.accessoryType=UITableViewCellAccessoryNone;
                    if (_isExpand==NO&&_waterExpand==NO) {
                        if (_LabelList.count>0) {
                            cell.textLabel.text = _LabelList[indexPath.section][indexPath.row];
                            cell.textLabel.textColor = HexColor(0x333333);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            
                        }
                    }
                    else  if (_isExpand==YES&&_waterExpand==NO){
                        
                        if (indexPath.row==5) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        else if (indexPath.row==6) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                    
                    else  if (_waterExpand==YES&&_isExpand==NO) {
                        if (indexPath.row == 3) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        if (indexPath.row==7) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                    else if (_isExpand==YES&&_waterExpand==YES){
                        
                        if (indexPath.row==5) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        else if (indexPath.row==9) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                }
                if (indexPath.row == 0 && indexPath.section == 0) {
                    float arrowImageH = cell.bounds.size.height/4;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    cell.detailTextLabel.text = @"";
                    cell.textLabel.text = _LabelList[0][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }else if (indexPath.row==1) {
                    float arrowImageH = cell.bounds.size.height/4;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    cell.detailTextLabel.text = @"";
                    cell.textLabel.text = _LabelList[0][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }else if (indexPath.row==2){
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    NSLog(@"tt----%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"]);
                    if (_mode==NO) {
                        cell.detailTextLabel.text=NSLocalizedString(@"Nav", nil);
                        
                    }else{
                        cell.detailTextLabel.text=NSLocalizedString(@"Random", nil);
                    }
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                }
                
               if (indexPath.row==3 || indexPath.row == 5) {
                    cell.accessoryType=UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = _waterMode;
                    
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                }
                if (indexPath.row ==4 || indexPath.row == 9 || indexPath.row == 6 || indexPath.row == 7){
                    cell.accessoryView = _switchView;
                    _switchView.on=_isOn;
                    _switchView.onTintColor = HexColor(0x00BDB5);
                    [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                }
                if (indexPath.section ==1 && indexPath.row ==0){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                    if (_downTime != 10&&_downTime != 0) {
                        NSString *second = NSLocalizedString(@"Second", nil);
                        NSString *btnInfo = [NSString stringWithFormat:@"%ld %@",(long)_downTime,second];
                        cell.detailTextLabel.text = btnInfo;
                    }else{
                        cell.detailTextLabel.text = @"";
                    }
                    
                }else if(indexPath.section ==1 &&indexPath.row ==1){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = _deviceName;
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }
                if(indexPath.section ==1 &&indexPath.row ==2){
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                    float arrowImageH = cell.bounds.size.height/4;
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = arrowImage;
                }
                
                return cell;
                
                
                
            }
        }else{
            if (_isExpand==YES&& (indexPath.row==4 ||indexPath.row==5)){
                ZJMCleanModeCell *cell =[self.setTableView dequeueReusableCellWithIdentifier:@"ZJMCleanModeCell" forIndexPath:indexPath];
                
                if (indexPath.row==4) {
                    cell.starCleanText.text=NSLocalizedString(@"Nav", nil);
                    
                }else if (indexPath.row==5){
                    cell.starCleanText.text = NSLocalizedString(@"Random", nil);
                }
                cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
                if (_mode==NO){
                    if (indexPath.row==4) {
                        
                        cell.starCleanBtn.selected=YES;
                        
                    }else if (indexPath.row==5){
                        cell.starCleanBtn.selected=NO;
                        
                    }
                }else{
                    if (indexPath.row==4) {
                        cell.starCleanBtn.selected=NO;
                    }else if (indexPath.row==5){
                        cell.starCleanBtn.selected=YES;
                    }
                }
                
                return cell;
                
                
            }else if (_isExpand==NO&&_waterExpand==YES&& (indexPath.row==5 ||indexPath.row==6 ||indexPath.row==7)){
                ZJMWaterModelCell *cell = [self.setTableView dequeueReusableCellWithIdentifier:@"ZJMWaterModelCell" forIndexPath:indexPath];
                if (indexPath.row==5) {
                    cell.waterModeLab.text = NSLocalizedString(@"Soft", nil),
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water1"] forState:UIControlStateNormal];
                    
                    if ([waterStr isEqualToString:@"00"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }else if (indexPath.row==6){
                    cell.waterModeLab.text = NSLocalizedString(@"Normal", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water2"] forState:UIControlStateNormal];
                    
                    if ([waterStr isEqualToString:@"01"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }else if (indexPath.row==7){
                    cell.waterModeLab.text = NSLocalizedString(@"Strong", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water3"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"02"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                    
                }
                
                return cell;
            }else if (_isExpand==YES&&_waterExpand==YES &&(indexPath.row==7 ||indexPath.row==8||indexPath.row==9)){
                ZJMWaterModelCell *cell = [self.setTableView dequeueReusableCellWithIdentifier:@"ZJMWaterModelCell" forIndexPath:indexPath];
                if (indexPath.row==7) {
                    cell.waterModeLab.text = NSLocalizedString(@"Soft", nil),
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water1"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"00"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }if (indexPath.row==8){
                    cell.waterModeLab.text =  NSLocalizedString(@"Normal", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water2"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"01"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                }if (indexPath.row==9){
                    cell.waterModeLab.text = NSLocalizedString(@"Strong", nil);
                    [cell.waterBtn setImage:[UIImage imageNamed:@"water3"] forState:UIControlStateNormal];
                    if ([waterStr isEqualToString:@"02"]) {
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                        
                    }else{
                        
                        [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                    }
                    
                    
                }
                
                return cell;
            }
            
            else{
                _mode= [[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"];
                NSString *CellIdentifier = [NSString stringWithFormat:@"cell%ld",indexPath.row];
                // 通过唯一标识创建cell实例
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                    cell.accessoryType=UITableViewCellAccessoryNone;
                    if (_isExpand==NO&&_waterExpand==NO) {
                        if (_LabelList.count>0) {
                            cell.textLabel.text = _LabelList[indexPath.section][indexPath.row];
                            cell.textLabel.textColor = HexColor(0x333333);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            
                        }
                    }
                    else  if (_isExpand==YES&&_waterExpand==NO){
                        
                        if (indexPath.row==6) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        else if (indexPath.row==7) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                    
                    else  if (_waterExpand==YES&&_isExpand==NO) {
                        if (indexPath.row == 4) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        if (indexPath.row==8) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                    else if (_isExpand==YES&&_waterExpand==YES){
                        
                        if (indexPath.row==6) {
                            cell.textLabel.text = NSLocalizedString(@"Water Tank Control", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.detailTextLabel.text = _waterMode;
                        }
                        else if (indexPath.row==10) {
                            cell.textLabel.text = NSLocalizedString(@"Max Mode", nil);
                            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                            cell.accessoryView = _switchView;
                            _switchView.on=_isOn;
                            [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                }
                if (indexPath.row == 0 && indexPath.section == 0) {
                    float arrowImageH = cell.bounds.size.height/4;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    cell.detailTextLabel.text = @"";
                    cell.textLabel.text = _LabelList[0][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }else if (indexPath.row==1) {
                    float arrowImageH = cell.bounds.size.height/4;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    cell.detailTextLabel.text = @"";
                    cell.textLabel.text = _LabelList[0][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }else if (indexPath.row==2){
                    float arrowImageH = cell.bounds.size.height/4;
                    
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                    cell.detailTextLabel.text = @"";
                    cell.textLabel.text = _LabelList[0][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }
                
                if (indexPath.row == 3) {
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    NSLog(@"tt----%d",[[NSUserDefaults standardUserDefaults]boolForKey:@"planMode"]);
                    if (_mode==NO) {
                        cell.detailTextLabel.text=NSLocalizedString(@"Nav", nil);
                        
                    }else{
                        cell.detailTextLabel.text=NSLocalizedString(@"Random", nil);
                    }
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                }if (indexPath.row==4 || indexPath.row == 6) {
                    cell.accessoryType=UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = _waterMode;
                    
                    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                }
                if (indexPath.row ==5 || indexPath.row == 10 || indexPath.row == 7 || indexPath.row == 8){
                    cell.accessoryView = _switchView;
                    _switchView.on=_isOn;
                    _switchView.onTintColor = HexColor(0x00BDB5);
                    [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                }
                if (indexPath.section ==1 && indexPath.row ==0){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                    if (_downTime != 10&&_downTime != 0) {
                        NSString *second = NSLocalizedString(@"Second", nil);
                        NSString *btnInfo = [NSString stringWithFormat:@"%ld %@",(long)_downTime,second];
                        cell.detailTextLabel.text = btnInfo;
                    }else{
                        cell.detailTextLabel.text = @"";
                    }
                    
                }else if(indexPath.section ==1 &&indexPath.row ==1){
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = _deviceName;
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                }else if(indexPath.section ==1 &&indexPath.row ==2){
                    cell.textLabel.text = _LabelList[1][indexPath.row];
                    cell.textLabel.textColor = HexColor(0x333333);
                    float arrowImageH = cell.bounds.size.height/4;
                    UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                    arrowImage.image = [UIImage imageNamed:@"右键"];
                    cell.accessoryView = arrowImage;
                }
                
                return cell;
                
                
                
            }
        }
       
    }
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:{
                
                ZJMAddReserVC *addReserVc = [[ZJMAddReserVC alloc]init];
                addReserVc.title = NSLocalizedString(@"Planning", nil);
                addReserVc.subDomain =self.subDomain;
                [self.navigationController pushViewController:addReserVc animated:YES];
            }
                break;
            case 1:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    ZJMConsumablesSituationVC *consumablesituationVc = [[ZJMConsumablesSituationVC alloc]init];
                    consumablesituationVc.subDomain = self.subDomain;
                    consumablesituationVc.title = NSLocalizedString(@"Spare Parts Condition", nil);
                    [self.navigationController pushViewController:consumablesituationVc  animated:YES];
                }else{
                    ZJMCleanRecordVC *cleanRecordVc = [[ZJMCleanRecordVC alloc]init];
                    cleanRecordVc.title = NSLocalizedString(@"History Record", nil);
                    cleanRecordVc.deviceID = self.deviceID;
                    cleanRecordVc.subDomain = self.subDomain;
                    cleanRecordVc.physicalDeviceId =self.physicalDeviceId;
                    [self.navigationController pushViewController:cleanRecordVc animated:YES];
                }
               
            }
                break;
            case 2:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    tag=indexPath.row;
                    self.isExpand = !self.isExpand;
                    if(self.isExpand == YES)
                    {
                        [self.setTableView beginUpdates];
                        [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                        [self.setTableView endUpdates];
                    }
                    else
                    {
                        [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                        [self.setTableView endUpdates];
                    }
                }else{
                    ZJMConsumablesSituationVC *consumablesituationVc = [[ZJMConsumablesSituationVC alloc]init];
                    consumablesituationVc.subDomain = self.subDomain;
                    consumablesituationVc.title = NSLocalizedString(@"Spare Parts Condition", nil);
                    [self.navigationController pushViewController:consumablesituationVc  animated:YES];
                }
               
                
            }
                break;
            case 3:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                     tag=indexPath.row;
                    if (self.isExpand == YES)
                    {
                        
                        byte[0] = 6;
                        _isPlanMode=NO;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        
                    }
                    else
                    {
                        self.waterExpand = !self.waterExpand;
                        
                        if (self.waterExpand==YES)
                        {
                            [self.setTableView beginUpdates];
                            [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                            [self.setTableView endUpdates];
                        }
                        else
                        {
                            [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                            [self.setTableView endUpdates];
                        }
                      
                    }
                }else{
                    tag=indexPath.row;
                    self.isExpand = !self.isExpand;
                    if(self.isExpand == YES)
                    {
                        [self.setTableView beginUpdates];
                        [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                        [self.setTableView endUpdates];
                    }
                    else
                    {
                        [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                        [self.setTableView endUpdates];
                    }
                }
               
                
            }
                break;
            case 4:{
               
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    if (self.isExpand == YES)
                    {
                        byte[0] =3;
                        _isPlanMode=YES;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        [userDafaults synchronize];
                        
                    }
                    else
                    {
                       
                        if (self.waterExpand==YES)
                        {   waterTag=0;
                            row = indexPath.row;
                            [self sendWaterModel];
                        }else{
                            [self sendCleanUp];
                        }
                       
                    }
                }else{
                    
                     tag=indexPath.row;
                    if (self.isExpand == YES)
                    {
                        
                        byte[0] = 6;
                        _isPlanMode=NO;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        
                    }
                    else
                    {
                        if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1) {
                            [self sendCleanUp];
                        }else{
                            self.waterExpand = !self.waterExpand;
                            
                            if (self.waterExpand==YES)
                            {
                                [self.setTableView beginUpdates];
                                [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                                [self.setTableView endUpdates];
                            }
                            else
                            {
                                [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                                [self.setTableView endUpdates];
                            }
                        }
                        
                    }
                }
                
                
            }
                break;
            case 5:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                      tag = indexPath.row;
                        if (self.isExpand == YES)
                        {
                            
                            self.waterExpand = !self.waterExpand;
                            
                            if (self.waterExpand==YES)
                            {
                                [self.setTableView beginUpdates];
                                [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                                [self.setTableView endUpdates];
                            }
                            else
                            {
                                [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                                [self.setTableView endUpdates];
                            }
                        }
                        else
                        {
                            if (self.waterExpand==YES)
                            {   waterTag=1;
                                [self sendWaterModel];
                                row = indexPath.row;
                            }
                            else
                            {
                                
                            }
                        }
                }else{
                    if (self.isExpand == YES)
                    {
                        
                        byte[0] =3;
                        _isPlanMode=YES;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        [userDafaults synchronize];
                        
                    }
                    else
                    {
                        if ([self.subDomain isEqualToString:X782SubDomain]&&_appDele.appRegion == -1 ) {
                            [self sendCleanUp];
                            
                        }else{
                            if (self.waterExpand==YES)
                            {   waterTag=0;
                                row = indexPath.row;
                                [self sendWaterModel];
                            }else{
                                [self sendCleanUp];
                            }
                        }
                        
                    }
                }
                
                
                
            }
                break;
            case 6:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    if (_isExpand==YES&&_waterExpand==NO) {
                        [self sendCleanUp];
                    }
                    if (self.waterExpand==YES&&self.isExpand==NO)
                    {   waterTag=2;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }else if (self.waterExpand==YES&&self.isExpand==YES){
                        waterTag=0;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }else{
                    tag=indexPath.row;
                    if ([self.subDomain isEqualToString:X782SubDomain] && _appDele.appRegion == -1) {
                        [self sendCleanUp];
                    }else{
                        if (self.isExpand == YES)
                        {
                            
                            self.waterExpand = !self.waterExpand;
                            
                            if (self.waterExpand==YES)
                            {
                                [self.setTableView beginUpdates];
                                [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                                [self.setTableView endUpdates];
                            }
                            else
                            {
                                [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                                [self.setTableView endUpdates];
                            }
                        }
                        else
                        {
                            if (self.waterExpand==YES)
                            {   waterTag=1;
                                [self sendWaterModel];
                                row = indexPath.row;
                            }
                            else
                            {
                                
                            }
                        }
                    }
                    
                }
               
            }
                break;
            case 7:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    if (_waterExpand==YES&&_isExpand==NO) {
                        [self sendCleanUp];
                    }else if (_waterExpand==YES&&_isExpand==YES){
                        waterTag=1;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }else{
                    if (_isExpand==YES&&_waterExpand==NO) {
                        [self sendCleanUp];
                    }
                    if (self.waterExpand==YES&&self.isExpand==NO)
                    {   waterTag=2;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }else if (self.waterExpand==YES&&self.isExpand==YES){
                        waterTag=0;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }
                
            }
                break;
            case 8:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    if (_waterExpand==YES&&_isExpand==YES){
                        waterTag=2;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }else{
                    if (_waterExpand==YES&&_isExpand==NO) {
                        [self sendCleanUp];
                    }else if (_waterExpand==YES&&_isExpand==YES){
                        waterTag=1;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }
               
            }
                break;
            case 9:{
                if ([self.subDomain isEqualToString:X786SubDomain]) {
                    if (_isExpand&&_waterExpand) {
                        [self sendCleanUp];
                    }
                }else{
                    if (_waterExpand==YES&&_isExpand==YES){
                        waterTag=2;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }
               
            }
                break;
            case 10:{
                
                if (_isExpand&&_waterExpand) {
                    [self sendCleanUp];
                }
            }
                break;
        }
        [self.setTableView reloadData];
    }
    
    else{
        
        switch (indexPath.row) {
                
            case 0:{
                UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                Byte byte[] = {11};
//                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    if (!error) {
                        
                        [self countDown];
                        
                    }else{
                        [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    }
                }];
                
                cell.userInteractionEnabled=NO;
                
            }
                break;
            case 1:{
                
                if (_isManager ==1) {
                    ZJMDeviceNameVC *deviceNameVC = [[ZJMDeviceNameVC alloc]init];
                    deviceNameVC.backType = type;
                    deviceNameVC.backDeviceName = ^(NSString *deviceName) {
                        
                        if (deviceName.length > 12) {
                            NSRange range = [deviceName rangeOfComposedCharacterSequenceAtIndex:12];
                            _robotName = [deviceName substringToIndex:range.location];
                        }else{
                            _robotName=deviceName;
                        }
                        UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                        [ACBindManager changNameWithSubDomain:_subDomain deviceId:_deviceID name:_robotName callback:^(NSError *error) {
                            
                            if (!error) {
                                cell.detailTextLabel.text = _robotName;
                                _deviceName = _robotName;
                                [self dismissViewControllerAnimated:YES completion:nil];
                                [self showHudWithString:NSLocalizedString(@"Name successfully changed", nil)];
                            }
                        }];
                    };
                    
                    deviceNameVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:deviceNameVC animated:YES completion:nil];
                    
                }else{
                    [self showHudWithString:NSLocalizedString(@"Only Administrator Have Access", nil)];
                }
                
            }
                break;
            case 2:{
                if (_isManager ==1) {
                    __block NSData *renewData;
//                    AppDelegate*delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are You Sure to Reset All Settings?", nil) message:NSLocalizedString(@"All Cleaning Data Will Be Deleted", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        Byte renewContent[] = {1};
                        renewData = [NSData dataWithBytes:renewContent length:sizeof(renewContent)];
                        ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:79 binaryData:renewData];
                        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                            if (!error) {
                                NSLog(@"下发恢复出厂设置成功");
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            }else{
                                NSLog(@"下发恢复出厂设置失败");
                            }
                        }];
                    }];
                    
                    [alertController addAction:cancelAction];
                    [alertController addAction:confirmAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }else{
                    [self showHudWithString:NSLocalizedString(@"Only Administrator Have Access", nil)];
                }
                
            }
                break;
                
        }
    }
}

#pragma mark - 倒计时
-(void)countDown{
    if (_downTime>0) {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            if (_downTime <= 0) {
                _downTime = 10;
                dispatch_source_cancel(timer);
                dispatch_async(mainQueue, ^{
                    UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    cell.userInteractionEnabled = YES;
                });
                
            } else{
                _downTime--;
                NSLog(@"_downTime == %d",_downTime);
                dispatch_async(mainQueue, ^{
                    UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    NSString *second = NSLocalizedString(@"Seconds", nil);
                    NSString *btnInfo = [NSString stringWithFormat:@"%ld %@",(long)_downTime,second];
                    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Searching For Robot", nil)]) {
                        cell.detailTextLabel.text = btnInfo;
                    }
                    if (_downTime ==0) {
                        cell.detailTextLabel.text =@"";
                        
                    }
                });
            }
            
        });
        dispatch_resume(timer);
    }
    
}

#pragma mark - 下发清洁力度
-(void)sendWaterModel{
    //    NSString *waterStr;
    __weak typeof(self) weakself = self;
//    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    NSInteger waterByte;
    
    if (_isClick ==YES) {
        BOOL maxStatus = [[NSUserDefaults standardUserDefaults]boolForKey:@"status"];
        waterByte = (maxStatus<<8) + waterTag;
    }else{
        NSInteger maxInt =[_maxStr integerValue];
        
        waterByte = (maxInt<<8) + waterTag;
    }
    
    Byte byte[] = {(waterByte&0xff00) >> 8,waterByte&0x00ff};
    
    data =[NSData dataWithBytes:byte length:sizeof(byte)];
    
    if (waterTag==0) {
        
        _waterMode=NSLocalizedString(@"Soft", nil);
        waterStr=@"00";
    }else if (waterTag==1){
        waterStr=@"01";
        _waterMode= NSLocalizedString(@"Normal", nil);
    }else if (waterTag==2){
        waterStr=@"02";
        _waterMode=NSLocalizedString(@"Strong", nil);
    }
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            [weakself hideHud];
            NSLog(@"下发水箱模式成功");
            
        }else{
            [weakself hideHud];
            NSLog(@"下发水箱模式失败");
        }
    }];
    [self.setTableView reloadData];
}

#pragma mark - cell的switch事件
-(void)sendCleanUp{
    NSInteger waterInt = [waterStr integerValue];
    Weakself;
//    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    if ([self.subDomain isEqualToString:X430SubDomain]) {
        if ([_statusStr isEqualToString:@"03"]||[_statusStr isEqualToString:@"06"]||[_statusStr isEqualToString:@"07"]) {
            
            _switchView.enabled = YES;
            if (_switchView.on ==NO) {
                Byte byte[] = {1,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 1;
            }else{
                _switchView.on =NO;
                Byte byte[] = {0,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 0;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self showHudWithRound];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    StrongSelf;
                    [weakSelf hideHud];
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([responseMsg getBinaryData]) {
                                NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                                
                                if ([dataStr isEqualToString:@"01"]) {
                                    _switchView.on=YES;
                                    [strongSelf hideHud];
                                }else{
                                    _switchView.on=NO;
                                    [strongSelf hideHud];
                                    
                                }
                            }
                        });
                    }else{
                        
                        [strongSelf showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                        [strongSelf hideHud];
                    }
                    
                }];
            });
            
        }else{
            
            if ([_workModel isEqualToString:@"2"]){
                
                _switchView.enabled = NO;
                [_switchView setOn:NO animated:YES];
                [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
                [self hideHud];
            }
            else if ([_statusStr isEqualToString:@"05"]){
                _switchView.enabled = NO;
                [_switchView setOn:YES animated:YES];
                [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
                [self hideHud];
            }
            else{
                
                _switchView.enabled = NO;
                [_switchView setOn:NO animated:YES];
                [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
                [self hideHud];
            }
        }
    }else{
        
        if ([self.workModel isEqualToString:@"8"]||[_statusStr isEqualToString:@"08"]){
            [self.switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
            
        }else if ([self.workModel isEqualToString:@"5"]||[_statusStr isEqualToString:@"05"]){
            [self.switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }else{
            self.isClick =YES;
            
            self.switchView.enabled = YES;
            if (self.switchView.on ==NO) {
                Byte byte[] = {1,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                self.status = 1;
            }else{
                Byte byte[] = {0,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                self.status = 0;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self showHudWithRound];
                ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:self.subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    StrongSelf;
                    [strongSelf hideHud];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (!error) {
                            NSString *dataStr;
                            if ([responseMsg getBinaryData]) {
                                dataStr=[[strongSelf convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                            }
                            if ([dataStr isEqualToString:@"01"]) {
                                strongSelf.switchView.on=YES;
                                _isOn = YES;
                                
                            }else{
                                strongSelf.switchView.on=NO;
                                _isOn = NO;
                            }
                        }else{
                            
                            [strongSelf showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                            
                        }
                    });
                }];
            });
        }
        
    }
    NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
    [userDafaults setBool:self.status forKey:@"status"];
    
}
#pragma mark - switch事件
-(void)swithAction:(UISwitch *)sender{
    
    if ([self.subDomain isEqualToString:X430SubDomain]) {
        if ([_statusStr isEqualToString:@"03"]||[_statusStr isEqualToString:@"06"]||[_statusStr isEqualToString:@"07"]) {
            [self switchAction];
        }
        if ([_cleanModel isEqualToString:@"2"]){
            [self hideHud];
            _switchView.enabled = NO;
            [_switchView setOn:NO animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }
        else if ([_statusStr isEqualToString:@"05"]){
            _switchView.enabled = NO;
            [_switchView setOn:YES animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }
        else{
            [self hideHud];
            _switchView.enabled = NO;
            [_switchView setOn:NO animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
            
        }
    }else{
        if ([_workModel isEqualToString:@"8"]||[_statusStr isEqualToString:@"08"]){
            [_switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }else if ([_workModel isEqualToString:@"5"]||[_statusStr isEqualToString:@"05"]){
            [_switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }else{
            
            [self switchAction];
        }
    }
}

#pragma mark - 下发吸力
-(void)switchAction{
    NSInteger waterInt = [waterStr integerValue];
//    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    _switchView.enabled = YES;
    
    if (_switchView.on ==NO) {
        Byte byte[] = {0,waterInt};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
        _status=0;
        
    }else{
        Byte byte[] = {1,waterInt};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
        _status=1;
    }
    NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
    [userDafaults setBool:_status forKey:@"status"];
    [userDafaults synchronize];
    _isClick=YES;
    [self showHudWithRound];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_appDele.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            NSLog(@"下发吸尘成功");
            NSString *dataStr;
            if ([responseMsg getBinaryData]) {
                dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
            }
            if ([dataStr isEqualToString:@"01"]) {
                self.switchView.on=YES;
                _isOn = YES;
                
            }else{
                self.switchView.on=NO;
                _isOn = NO;
            }
            
        }else{
            NSLog(@"下发吸尘失败");
        }
    }];
}
- (void)back{
    if (self.delegate && [self.delegate respondsToSelector:@selector(returnName:)]) {
        [self.delegate returnName:_deviceName];
        
    }
    if (select==YES) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(returnData:)]) {
            [self.delegate returnData:_data];
            
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
//
- (NSArray *)indexPathsForExpandSection:(NSInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSIndexPath *path;
    if ([self.subDomain isEqualToString:X786SubDomain]) {
        if (tag==2) {
            for (int i = 3; i <=4; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (tag==3){
            for (int i = 4; i <=6; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (tag==5){
            
            for (int i = 6; i <=8; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (_waterExpand==YES&&_isExpand==NO){
            for (int i = 3; i <=4; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }
        
    }else{
        if (tag==3) {
            for (int i = 4; i <=5; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (tag==4){
            for (int i = 5; i <=7; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (tag==6){
            
            for (int i = 7; i <=9; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }else if (_waterExpand==YES&&_isExpand==NO){
            for (int i = 4; i <=5; i++) {
                
                path = [NSIndexPath indexPathForRow:i inSection:section];
                
                [indexPaths addObject:path];
            }
        }
        
    }
    
    return [indexPaths copy];
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

