//
//  ZJMSettingVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/9/18.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMSettingVC.h"
#import "ZJMAddReserVC.h"
#import "ZJMConsumablesSituationVC.h"
#import "ZJMCleanModeCell.h"
#import "ZJMDeviceNameVC.h"
#import "ZJMCleanRecordVC.h"
#import "ZJMWaterModelCell.h"
#import "timeoutManager.h"
#import "ACOTAManager.h"
#import "OTAUpdateVC.h"
#import "ZJMOTAUpateVC.h"
#import "ZJMVolumeSettingVC.h"
@interface ZJMSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *setTableView;
@property (strong,nonatomic)NSMutableArray *LabelList;
@property (assign, nonatomic) BOOL isExpand;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)  UIButton  *selectedBtn;
@property (nonatomic,copy)ACUserDevice *userDevice;
@property (nonatomic,strong)UISwitch *switchView;
@property (nonatomic,strong)UISwitch *pressSwitch;
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
@property (nonatomic,copy)NSString *carpetStr;
@property(nonatomic)BOOL mode;
@property (nonatomic,strong)UISwitch *soundSwitch;
@property (nonatomic)BOOL soundOn;
@property (nonatomic,copy)NSString *currentVersion;
@property (nonatomic)NSInteger batteryPower;
@property (nonatomic)NSInteger volume;

@end

@implementation ZJMSettingVC
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
    NSInteger row;
    BOOL isOpen;
}
static  dispatch_source_t timer;
-(NSMutableArray *)deviceList{
    if (_deviceList==nil) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_downTime > 0 && _downTime!=10) {
        timeoutManager *manager = [timeoutManager sharedTimerManager];
        manager.timeout = _downTime;
        [manager countDown];
        
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    self.errorType = @"";
    timeoutManager *manager = [timeoutManager sharedTimerManager];
    int temp = manager.timeout;
    if (temp > 0) {
        _downTime= temp; //倒计时时间
        [self countDown];
        
    }else{
        _downTime=10;
    }
    Byte byte[] = {0};
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    [self demandDeviceStatusdata:data];
    [self listenPropertyValueChange];

}

#pragma mark - 查询设备状态
-(void)demandDeviceStatusdata:(NSData *)data{
    [self showHudWithRound];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:65 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            if ([responseMsg getBinaryData]) {
                _statusStr = [NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr:responseMsg.payload] substringToIndex:2] UTF8String], 0, 16)];
                NSData *pressData=[[responseMsg getBinaryData]subdataWithRange:NSMakeRange(1, 1)];
                _carpetStr=[self convertDataToHexStr:pressData];
                NSData *waterData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(4, 1)];
                waterStr = [self convertDataToHexStr:waterData];
                NSData *maxData = [[responseMsg getBinaryData]subdataWithRange:NSMakeRange(3, 1)];
                _maxStr = [self convertDataToHexStr:maxData];
                NSData * soundData = [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(6, 1)];
                NSString * soundStr = [self convertDataToHexStr:soundData];
                NSString *dataStr = [[self convertDataToHexStr:responseMsg.payload] substringWithRange:NSMakeRange(10, 2)];
                NSLog(@"电量 == %@",dataStr);
                self.batteryPower = [[NSString stringWithFormat:@"%lu",strtoul([dataStr UTF8String],0,16)]integerValue];
                if ([self.subDomain isEqualToString:X790SubDomain]) {
                    if ([_statusStr isEqualToString:@"5"]||[_statusStr isEqualToString:@"05"]){
                        self.isOn = YES;
                        
                    }else if ([_statusStr isEqualToString:@"8"]||[_statusStr isEqualToString:@"08"]){
                        self.isOn=NO;
                        
                    }else{
                        if ([_maxStr isEqualToString:@"01"]) {
                            _isOn=YES;
                        }else{
                            _isOn=NO;
                        }
                    }
                    
                }else{
                    if ([_maxStr isEqualToString:@"01"]) {
                        _isOn=YES;
                    }else{
                        _isOn=NO;
                    }
                    if ([self.subDomain isEqualToString:X910SubDomain]) {
                       _volume = [[NSString stringWithFormat:@"%lu",strtoul([soundStr UTF8String], 0, 16)] integerValue];
                        Byte * soundByte = (Byte *)[soundData bytes];
                        int n0 = (soundByte[0] & 0x01) == 0x01 ? 1 : 0;
                        if (n0 == 1) {
                            isOpen = YES;
                            _volume = (_volume-1) >> 1;
                        }else{
                            _volume = _volume >> 1;
                            isOpen = NO;
                        }
                    }
                }
                
                if ([_carpetStr isEqualToString:@"00"]) {
                    _pressSwitch.on=NO;
                }else if ([_carpetStr isEqualToString:@"01"]){
                    _pressSwitch.on=YES;
                }
                if ([waterStr isEqualToString:@"00"]) {
                    _waterMode = NSLocalizedString(@"Soft", nil);
                }else if ([waterStr isEqualToString:@"01"]){
                    _waterMode = NSLocalizedString(@"Normal", nil);
                }else if ([waterStr isEqualToString:@"02"]){
                    _waterMode = NSLocalizedString(@"Strong", nil);
                }
                if ([soundStr isEqualToString:@"01"]) {
                    _soundOn = YES;
                }else{
                    _soundOn = NO;
                }
                
            }
        }else{
            switch (error.code) {
                case 3807:
                    self.errorType = NSLocalizedString(@"Device Offline", nil);
                    break;
                    
                default:  self.errorType = NSLocalizedString(@"Connecting Timeout", nil);
                    break;
            }
            
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
        [self.setTableView reloadData];
    }];
}
#pragma mark - 状态属性监听
-(void)listenPropertyValueChange{
    [ACDeviceDataManager subscribePropDataWithSubDomain:_subDomain deviceId:_deviceID callback:^
     (NSError *error) {
         if (!error) {
             [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                 _cleanModel = [[properties get:@"vacuum_cleaning"] stringValue];
                 _statusStr = [[properties get:@"work_pattern"]stringValue];
                self.batteryPower = [[properties get:@"battery_level"]integerValue];
                 if ([self.subDomain isEqualToString:X790SubDomain]) {
                     if ([_statusStr isEqualToString:@"5"]||[_statusStr isEqualToString:@"05"]){
                         _switchView.on = YES;
                         self.isOn = YES;
                         
                     }else if ([_statusStr isEqualToString:@"8"]||[_statusStr isEqualToString:@"08"]){
                         _switchView.on = NO;
                         self.isOn=NO;
                         
                     }else{
                         if ([_cleanModel isEqualToString:@"1"]) {
                             _isOn = YES;
                             _switchView.on=YES;
                         }else{
                             _isOn = NO;
                             _switchView.on=NO;
                         }
                     }
                 }else{
                     if ([_cleanModel isEqualToString:@"1"]) {
                         _isOn = YES;
                         _switchView.on=YES;
                     }else{
                         _isOn = NO;
                         _switchView.on=NO;
                     }
                 }
                 
                
                 
             }];
         }
     }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    _switchView.onTintColor = [UIColor whiteColor];
    _soundSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];

    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Cleaning Mode", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else if([self.subDomain isEqualToString:X900SubDomain]){
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil),
                          NSLocalizedString(@"Tone Switch", nil)],

                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Firmware Update", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else if([self.subDomain isEqualToString:X910SubDomain]){
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil),
                          NSLocalizedString(@"Volume Setting", nil)],
                        
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Firmware Update", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else if ([self.subDomain isEqualToString:X790SubDomain]){
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil),
                          NSLocalizedString(@"Carpet pressurization", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Firmware Update", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else if ([self.subDomain isEqualToString:X800SubDomain]){
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Firmware Update", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }else{
        _LabelList = [@[@[NSLocalizedString(@"Planning", nil),
                          NSLocalizedString(@"Cleaning Records", nil),
                          NSLocalizedString(@"Spare Parts Condition", nil),
                          NSLocalizedString(@"Water Tank Control", nil),
                          NSLocalizedString(@"Max Mode", nil)],
                        @[NSLocalizedString(@"Searching For Robot", nil),
                          NSLocalizedString(@"Robot Name", nil),
                          NSLocalizedString(@"Reset All Settings", nil)]]mutableCopy];
    }
    [self.setTableView registerNib:[UINib nibWithNibName:@"ZJMWaterModelCell" bundle:nil] forCellReuseIdentifier:@"ZJMWaterModelCell"];
    [self.setTableView registerNib:[UINib nibWithNibName:@"ZJMCleanModeCell" bundle:nil] forCellReuseIdentifier:@"ZJMCleanModeCell"];
    type=1;
    select=YES;
    _isExpand=NO;
    _selectedIndexPath=nil;
    _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switchView.on=YES;
    _pressSwitch=[[UISwitch alloc]initWithFrame:CGRectZero];
    
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return SCREENHEIGHT*0.08;
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
        if (_isExpand==YES && _selectedIndexPath.section == section) {
            if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
                return [_LabelList[section] count] + 2;
            }else{
                return [_LabelList[section] count] + 3;
            }
        }
        else{
            return [_LabelList[section]count];
        }
    }
    else {
        return [_LabelList[1] count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {

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
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.accessoryView = _switchView;
                    _switchView.onTintColor = HexColor(0x00BDB5);
                    _switchView.on=_isOn;
                    [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                }
                
            }
            
            return cell;
        }
    }else{
        if (_isExpand==YES && indexPath.row>3&&indexPath.row<7) {
            ZJMWaterModelCell *cell =[self.setTableView dequeueReusableCellWithIdentifier:@"ZJMWaterModelCell" forIndexPath:indexPath];
            
            if (indexPath.row==4) {
                [cell.waterBtn setImage:[UIImage imageNamed:@"water1"] forState:UIControlStateNormal];
                cell.waterModeLab.text=NSLocalizedString(@"Soft", nil);
                if ([waterStr isEqualToString:@"00"]) {
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                    
                }else{
                    
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                }
            }else if (indexPath.row==5){
                [cell.waterBtn setImage:[UIImage imageNamed:@"water2"] forState:UIControlStateNormal];
                cell.waterModeLab.text=NSLocalizedString(@"Normal", nil);
                if ([waterStr isEqualToString:@"01"]) {
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                    
                }else{
                    
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                }
                cell.waterModeLab.text=NSLocalizedString(@"Normal", nil);
            }else if (indexPath.row==6){
                [cell.waterBtn setImage:[UIImage imageNamed:@"water3"] forState:UIControlStateNormal];
                cell.waterModeLab.text=NSLocalizedString(@"Strong", nil);
                if ([waterStr isEqualToString:@"02"]) {
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_selected_"] forState:UIControlStateNormal];
                    
                }else{
                    
                    [cell.selectBtn setImage:[UIImage imageNamed:@"radio_bt_normal_"] forState:UIControlStateNormal];
                }
            }
            return cell;
            
        }else{
            
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
                }else{
                    cell.textLabel.textColor = HexColor(0x333333);
                    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    if (indexPath.section==0&&indexPath.row==7) {
                        _switchView.onTintColor = HexColor(0x00BDB5);
                        cell.textLabel.text = NSLocalizedString(@"Max Mode",nil);
                        cell.accessoryView = _switchView;
                        _switchView.on=_isOn;
                        [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
                    }if ([self.subDomain isEqualToString:X790SubDomain]) {
                        if (indexPath.section==0&&indexPath.row==8){
                            _pressSwitch.onTintColor = HexColor(0x00BDB5);
                            cell.textLabel.text = NSLocalizedString(@"Carpet pressurization",nil);
                            cell.accessoryView = _pressSwitch;
                            [_pressSwitch addTarget:self action:@selector(sendDevicePressSwitch:) forControlEvents:UIControlEventValueChanged];
                        }
                    }else if ([self.subDomain isEqualToString:X900SubDomain]){
                        if (indexPath.section == 0 && indexPath.row == 8){
                            cell.textLabel.text = NSLocalizedString(@"Tone Switch", nil);
                            _soundSwitch.onTintColor = HexColor(0x00BDB5);
                            cell.accessoryView = _soundSwitch;
                            _soundSwitch.on=_soundOn;
                            [_soundSwitch addTarget:self action:@selector(soundSwitch:) forControlEvents:UIControlEventValueChanged];
                        }
                    }
                   
                }
                
            }
            if (indexPath.row == 3) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.accessoryView = nil;
                cell.detailTextLabel.text = _waterMode;
            }
             if (indexPath.section==0&&indexPath.row==4){
                _switchView.onTintColor = HexColor(0x00BDB5);
                 cell.accessoryType = UITableViewCellAccessoryNone;
                 cell.accessoryView = nil;
                cell.accessoryView = _switchView;
                _switchView.on=_isOn;
                [_switchView addTarget:self action:@selector(swithAction:) forControlEvents:UIControlEventValueChanged];
            }

            if (indexPath.section==0&&indexPath.row==5){
                if ([self.subDomain isEqualToString:X900SubDomain]) {
                    _soundSwitch.onTintColor = HexColor(0x00BDB5);
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.accessoryView = _soundSwitch;
                    _soundSwitch.on=_soundOn;
                    [_soundSwitch addTarget:self action:@selector(soundSwitch:) forControlEvents:UIControlEventValueChanged];
                }else if ([self.subDomain isEqualToString:X790SubDomain]){
                    _pressSwitch.onTintColor = HexColor(0x00BDB5);
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.accessoryView = nil;
                    cell.accessoryView = _pressSwitch;
                    [_pressSwitch addTarget:self action:@selector(sendDevicePressSwitch:) forControlEvents:UIControlEventValueChanged];
                }
                
           }
            if (indexPath.section == 1 && indexPath.row == 3){
                float arrowImageH = cell.bounds.size.height/4;
                cell.detailTextLabel.text = @"";
                UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                arrowImage.image = [UIImage imageNamed:@"右键"];
                cell.accessoryView = arrowImage;
            }
            
            return cell;
        }
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _allExpand=YES;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                ZJMAddReserVC *timerReserVc = [[ZJMAddReserVC alloc]init];
                timerReserVc.title = NSLocalizedString(@"Planning", nil);
                timerReserVc.subDomain =self.subDomain;
                [self.navigationController pushViewController:timerReserVc animated:YES];
            }
                break;
            case 1:{
                ZJMCleanRecordVC *cleanRecordVc = [[ZJMCleanRecordVC alloc]init];
                cleanRecordVc.title = NSLocalizedString(@"History Record", nil);
                cleanRecordVc.deviceID = self.deviceID;
                cleanRecordVc.subDomain = self.subDomain;
                cleanRecordVc.physicalDeviceId =self.physicalDeviceId;
                [self.navigationController pushViewController:cleanRecordVc animated:YES];
                
            }
                break;
            case 2:{
                
                ZJMConsumablesSituationVC *consumablesituationVc = [[ZJMConsumablesSituationVC alloc]init];
                consumablesituationVc.subDomain = self.subDomain;
                consumablesituationVc.title = NSLocalizedString(@"Spare Parts Condition", nil);
                [self.navigationController pushViewController:consumablesituationVc  animated:YES];
                
            }
                break;
            case 3:{
                if (_selectedIndexPath==nil) {
                    _isExpand=YES;
                    _selectedIndexPath = indexPath;
                    [self.setTableView beginUpdates];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    [self.setTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                    [self.setTableView endUpdates];
                }
                else {
                    if (self.isExpand) {
                        if (_selectedIndexPath == indexPath) {
                            _isExpand = NO;
                            [self.setTableView beginUpdates];
                            [self.setTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                            [self.setTableView endUpdates];
                            _selectedIndexPath = nil;
                            
                        }
                    }
                }
            }
                break;
            case 4:{
                if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
                    if (_selectedIndexPath==nil) {
                        [self sendCleanUp];
                    }else{
                        byte[0] = 6;
                        _isPlanMode=NO;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        row = indexPath.row;
                    }
                }else{
                    
                    if (_selectedIndexPath==nil) {
                        [self sendCleanUp];
                    }else{
                        tag=0;
                        row = indexPath.row;
                        [self sendWaterModel];
                    }
                }
                
                
            }
                break;
            case 5:{
                if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
                    if (_selectedIndexPath != nil) {
                        byte[0] =3;
                        _isPlanMode=YES;
                        _data =[NSData dataWithBytes:byte length:sizeof(byte)];
                        NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
                        [userDafaults setBool:_isPlanMode forKey:@"planMode"];
                        [userDafaults synchronize];
                    }
                    
                }else if ([self.subDomain isEqualToString:X790SubDomain]){
                    if (_selectedIndexPath == nil) {
                        if (_pressSwitch.on==YES) {
                            byte[0]=0;
                        }else{
                            byte[0]=1;
                        }
                        
                        _data=[NSData dataWithBytes:byte length:sizeof(byte)];
                        [self sendDeviceCarpetPressWithCode:71 Data:_data];
                    }else{
                        tag=1;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                    
                    
                }else if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]){
                    if (_selectedIndexPath == nil) {
                        if ([self.subDomain isEqualToString:X900SubDomain]) {
                              [self sendSoundModel];
                        }else{
                            [self pushToVolumeSettingVC];
                        }
                      
                    }else{
                        tag=1;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                    
                }else{
                    if (_selectedIndexPath != nil) {
                        tag=1;
                        [self sendWaterModel];
                        row = indexPath.row;
                    }
                }
                
                
            }
                break;
            case 6:{
                if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
                    [self sendCleanUp];
                }else{
                    tag=2;
                    [self sendWaterModel];
                    row = indexPath.row;
                }
            }
                break;
            case 7:
            {
                [self sendCleanUp];
            }
                break;
            case 8:
            {
                if ([self.subDomain isEqualToString:X790SubDomain]) {
                    if (_pressSwitch.on==YES) {
                        byte[0]=0;
                    }else{
                        byte[0]=1;
                    }
                    
                    _data=[NSData dataWithBytes:byte length:sizeof(byte)];
                    [self sendDeviceCarpetPressWithCode:71 Data:_data];
                }else if ([self.subDomain isEqualToString:X900SubDomain]){
                     [self sendSoundModel];
                }else if ([self.subDomain isEqualToString:X910SubDomain]){
                    [self pushToVolumeSettingVC];
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
                ACDeviceMsg *msg;
                if ([self.subDomain isEqualToString:X790SubDomain]) {
                    Byte byte[] = {1};
                    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
                    msg = [[ACDeviceMsg alloc] initWithCode:81 binaryData:data];
                }else{
                    Byte byte[] = {11};
                    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
                    msg = [[ACDeviceMsg alloc] initWithCode:70 binaryData:data];
                }
                [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                    
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
                if ([self.subDomain isEqualToString:X790SubDomain] || [self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
                    if ([self.errorType isEqualToString:NSLocalizedString(@"Device Offline", nil)]) {
                        [self showHudWithString:NSLocalizedString(@"Device Offline", nil)];
                    }else if ([self.errorType isEqualToString:NSLocalizedString(@"Connecting Timeout", nil)]){
                        [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    }else{
                        if (self.batteryPower<20) {
                            [self showHudWithString:NSLocalizedString(@"Please charge the battery to 20% or more and try again", nil)];
                        }else{
                            ZJMOTAUpateVC * OTAVc = [[ZJMOTAUpateVC alloc] init];
                            OTAVc.subDomain = self.subDomain;
                            OTAVc.physicalDeviceId = self.physicalDeviceId;
                            OTAVc.deviceId=self.deviceID;
                            [self.navigationController pushViewController:OTAVc animated:YES];
                        }
                    }
                }else{
                    if (_isManager ==1) {
                        __block NSData *renewData;
                        AppDelegate*delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are You Sure to Reset All Settings?", nil) message:NSLocalizedString(@"All Cleaning Data Will Be Deleted", nil) preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                            Byte renewContent[] = {1};
                            renewData = [NSData dataWithBytes:renewContent length:sizeof(renewContent)];
                            ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:79 binaryData:renewData];
                            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                                if (!error) {
                                    NSLog(@"下发恢复出厂设置成功");
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }else{
                                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
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
            }
                break;
            case 3:{
                if (_isManager ==1) {
                    __block NSData *renewData;
                    AppDelegate*delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are You Sure to Reset All Settings?", nil) message:NSLocalizedString(@"All Cleaning Data Will Be Deleted", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        Byte renewContent[] = {1};
                        renewData = [NSData dataWithBytes:renewContent length:sizeof(renewContent)];
                        ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:79 binaryData:renewData];
                        [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                            if (!error) {
                                NSLog(@"下发恢复出厂设置成功");
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            }else{
                               [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
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
            dispatch_async(mainQueue, ^{
                NSString *second = NSLocalizedString(@"Seconds", nil);
                NSString *btnInfo = [NSString stringWithFormat:@"%ld %@",(long)_downTime,second];
                UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                cell.detailTextLabel.text = btnInfo;
                [[NSUserDefaults standardUserDefaults]setObject:btnInfo forKey:@"btnInfo"];
                
                if (_downTime ==0) {
                    UITableViewCell *cell = [self.setTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    cell.detailTextLabel.text =@"";
                }
            });
        }
        
    });
    dispatch_source_set_cancel_handler(timer, ^{
        
    });
    dispatch_resume(timer);
}

#pragma mark - 下发清洁力度
-(void)sendWaterModel{
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    NSInteger waterByte;
    [self showHudWithRound];
    ACDeviceMsg *msg;
    if ([self.subDomain isEqualToString:X790SubDomain]) {
        Byte byte[] = {tag};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
        msg = [[ACDeviceMsg alloc]initWithCode:80 binaryData:data];
    }else{
        if (_isClick ==YES) {
            BOOL maxStatus = [[NSUserDefaults standardUserDefaults]boolForKey:@"status"];
            waterByte = (maxStatus<<8) + tag;
        }else{
            NSInteger maxInt =[_maxStr integerValue];
            
            waterByte = (maxInt<<8) + tag;
        }
        
        Byte byte[] = {(waterByte&0xff00) >> 8,waterByte&0x00ff};
         data =[NSData dataWithBytes:byte length:sizeof(byte)];
        msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
    }

    if (tag==0) {
        
        _waterMode=NSLocalizedString(@"Soft", nil);
        waterStr=@"00";
        
    }else if (tag==1){
        waterStr=@"01";
        _waterMode = NSLocalizedString(@"Normal", nil);
    }else if (tag==2){
        waterStr=@"02";
        _waterMode=NSLocalizedString(@"Strong", nil);
    }
    
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
    
        }else{
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
}
#pragma mark -PressSwitch事件
-(void)sendDevicePressSwitch:(UISwitch *)pressSwitch{
    
    if (_pressSwitch.on==NO) {
        byte[0]=0;
    }else{
        byte[0]=1;
    }
    
    _data=[NSData dataWithBytes:byte length:sizeof(byte)];
    [self sendDeviceCarpetPressWithCode:71 Data:_data];
}
#pragma mark - 下发Carpet pressurization
-(void)sendDeviceCarpetPressWithCode:(NSInteger)code Data:(NSData *)data{
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:code binaryData:data];
    [self showHudWithRound];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            if ([responseMsg getBinaryData]) {
                NSString *dataStr=[self convertDataToHexStr:[responseMsg getBinaryData]];
                if ([dataStr isEqualToString:@"00"]) {
                    _pressSwitch.on=NO;
                }else if ([dataStr isEqualToString:@"01"]){
                    _pressSwitch.on=YES;
                }
            }else{
                return ;
            }
        }else{
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
    
}
#pragma mark - cell的switch事件
-(void)sendCleanUp{
    NSInteger waterInt = [waterStr integerValue];
    
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        if ([_statusStr isEqualToString:@"3"]||[_statusStr isEqualToString:@"6"]||[_statusStr isEqualToString:@"7"]) {
            [self showHudWithRound];
            if (_switchView.on ==NO) {
                
                Byte byte[] = {1,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 1;
            }else{
                Byte byte[] = {0,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 0;
            }
            
            ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                [self hideHud];
                if (!error) {
                    if ([responseMsg getBinaryData]) {
                        NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                        if ([dataStr isEqualToString:@"00"]) {
                            _switchView.on=NO;
                            _isOn = NO;
                        }else{
                            _switchView.on=YES;
                            _isOn = YES;
                        }
                    }
                    NSLog(@"下发吸尘成功");
                }else{
                    NSLog(@"下发吸尘失败");
                }
            }];
            
        }else{
            [self hideHud];
            [_switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
        }
    }else{
         _isClick=YES;
        if ([self.subDomain isEqualToString:X790SubDomain] && ([_statusStr isEqualToString:@"8"]||[_statusStr isEqualToString:@"5"])) {
            [self.switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
           
        }else{
            [self showHudWithRound];
            _switchView.enabled = YES;
            if (_switchView.on ==NO) {
                Byte byte[] = {1,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 1;
            }else{
                
                Byte byte[] = {0,waterInt};
                data =[NSData dataWithBytes:byte length:sizeof(byte)];
                _status = 0;
            }
            
            ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                [self hideHud];
                
                if (!error) {
                    if ([responseMsg getBinaryData]) {
                        NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                        if ([dataStr isEqualToString:@"00"]) {
                            _switchView.on=NO;
                            _isOn = NO;
                        }else{
                            _switchView.on=YES;
                            _isOn = YES;
                        }
                    }
                    
                    
                }else{
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                }
            }];
        }
    }
    NSUserDefaults *userDafaults = [NSUserDefaults standardUserDefaults];
    [userDafaults setBool:_status forKey:@"status"];
    [userDafaults synchronize];
    
}
#pragma mark - switch事件
-(void)swithAction:(UISwitch *)sender{
    
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        if ([_statusStr isEqualToString:@"3"]||[_statusStr isEqualToString:@"6"]) {
            [self switchAction];
        }
        else{
            [self hideHud];
            [_switchView setOn:_isOn animated:YES];
            [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
            
        }
    }else{
        if ([self.subDomain isEqualToString:X790SubDomain]) {
            if ([_statusStr isEqualToString:@"8"] || [_statusStr isEqualToString:@"5"]){
                [_switchView setOn:_isOn animated:YES];
                [self showHudWithString:NSLocalizedString(@"Can't Change Suction In This Mode", nil)];
            }else{
                [self switchAction];
            }
        }else{
             [self switchAction];
        }
        
       
    }
}

#pragma mark - 下发吸力
-(void)switchAction{
    NSInteger waterInt = [waterStr integerValue];
    AppDelegate *delegate =(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSData *data;
    [self showHudWithRound];
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
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:72 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            NSLog(@"下发吸尘成功");
            if ([responseMsg getBinaryData]) {
                NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                if ([dataStr isEqualToString:@"00"]) {
                    _switchView.on=NO;
                    _isOn = NO;
                }else{
                    _switchView.on=YES;
                    _isOn = YES;
                }
            }
            
            
        }else{
            NSLog(@"下发吸尘失败");
        }
    }];
}

#pragma mark - X900提示音开关
-(void)soundSwitch:(UISwitch *)soundSwitch{
    [self showHudWithRound];
    NSData * data;
    if (_soundSwitch.on ==NO) {
        Byte byte[] = {0,0};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
    }else{
        
        Byte byte[] = {1,0};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
    }
    
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:78 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        
        if (!error) {
            NSLog(@"下发提示音成功");
            if ([responseMsg getBinaryData]) {
                NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                if ([dataStr isEqualToString:@"00"]) {
                    _soundSwitch.on=NO;
                    _soundOn = NO;
                }else{
                    _soundSwitch.on=YES;
                    _soundOn = YES;
                }
            }
        }else{
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
    
}
-(void)sendSoundModel{
    [self showHudWithRound];
    NSData * data;
    if (_soundSwitch.on ==NO) {
        Byte byte[] = {1,0};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
    }else{
        
        Byte byte[] = {0,0};
        data =[NSData dataWithBytes:byte length:sizeof(byte)];
    }
    
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:78 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        
        if (!error) {
            NSLog(@"下发提示音成功");
            if ([responseMsg getBinaryData]) {
                NSString *dataStr=[[self convertDataToHexStr:[responseMsg getBinaryData]]substringWithRange:NSMakeRange(0, 2)];
                if ([dataStr isEqualToString:@"00"]) {
                    _soundSwitch.on=NO;
                    _soundOn = NO;
                }else{
                    _soundSwitch.on=YES;
                    _soundOn = YES;
                }
            }
            
            
        }else{
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
        }
    }];
}

#pragma mark - 跳转到音量设置界面
-(void)pushToVolumeSettingVC{
    ZJMVolumeSettingVC * settingVC = [[ZJMVolumeSettingVC alloc] init];
    settingVC.subDomain = _subDomain;
    settingVC.physicalDeviceId = _physicalDeviceId;
    settingVC.isOpen = isOpen;
    settingVC.volume = _volume;
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - 返回
- (void)back{
    if (select==YES) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(returnData:)]) {
            [self.delegate returnData:_randomData];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(returnName:)]) {
            [self.delegate returnName:_deviceName];
            
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - cell的增添
- (NSArray *)indexPathsForExpandSection:(NSInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray array];
    if ([self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        for (int i = 4; i <=5; i++) {
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
            
            [indexPaths addObject:path];
        }
    }else{
        for (int i = 4; i <=6; i++) {
            
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:section];
            
            [indexPaths addObject:path];
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

