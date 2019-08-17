//
//  ZJMMyDeviceVC.m
//  
//
//  Created by 张佳满 on 2017/8/16.
//
//

#import "ZJMMyDeviceVC.h"
#import "ZJMLoginVC.h"
#import "ZJMChoiceRobotVC.h"
#import "ZJMDeviceCell.h"
#import "ZJMRechargeVC.h"
#import "ZJMX786RechargeVC.h"
#import "MGJRouter.h"

@interface ZJMMyDeviceVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myDeviceTableView;

@property (strong, nonatomic) IBOutlet UIView *subbView;

@property (nonatomic,assign)ACDeviceStatus *deviceStatus;

@property (nonatomic,copy)NSString *robotName;

@property(nonatomic,strong) NSMutableArray<DeviceMsg *> *deviceList;

@property(nonatomic,strong)NSIndexPath *selectIndexPath;
@property (assign,atomic) NSUInteger deviceId;
@property(nonatomic,strong)DeviceMsg *device;
@property (weak, nonatomic) IBOutlet UILabel *neverLab;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (copy,nonatomic)NSString *subDomain;
@property (atomic,assign)NSInteger ownerID;
@property (copy,nonatomic)NSString *titleName;
@property (nonatomic,assign)BOOL isManager;
@property(nonatomic,copy)NSString *ss;
@end

@implementation ZJMMyDeviceVC
{
    UIBarButtonItem *_commonaddItem;
    AVAudioPlayer *player;

}
#pragma mark - 数组懒加载
- (NSMutableArray<DeviceMsg *> *)deviceList {
    if (_deviceList == nil) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loginInvalid];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _ownerID =[userDefaults integerForKey:@"userID"];
    [self showHudWithRound];
    [self getDevicelist];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self setRightBtn];
    self.neverLab.text = NSLocalizedString(@"No ILIFE Robot Found", nil);
    self.neverLab.font = [UIFont systemFontOfSize:17];
    [self.addBtn setTitle:NSLocalizedString(@"Add New Robot", nil) forState:UIControlStateNormal];
    [self.myDeviceTableView registerNib:[UINib nibWithNibName:@"ZJMDeviceCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self setUpdataTableView];

}

-(void)viewDidDisappear:(BOOL)animated{
    [self.myDeviceTableView.mj_header endRefreshing];
}
#pragma mark - 登录失效
-(void)loginInvalid{
    [ACAccountManager setRefreshTokenInvalidCallback:^(NSError *error) {
        if (error.code==3516||error.code==3514) {
            UIAlertController *alert= [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Log In Failed, Please Log In Again", nil) message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction= [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [ACAccountManager logout];
                ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
                loginVc.title = NSLocalizedString(@"Log In", nil);
                loginVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:loginVc animated:YES];
            }];
            
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            
        }
    }];
}
#pragma mark - 获取设备
-(void)getDevicelist{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ACBindManager listDevicesWithStatusCallback:^(NSArray<ACUserDevice *> *devices, NSError *error) {
           [self hideHud];
           [self.deviceList removeAllObjects];
        if (!error) {
            
            if (devices.count >0) {
                for (ACUserDevice *device in devices) {
                    DeviceMsg *deviceMsg = [[DeviceMsg alloc] init];
                    deviceMsg.userDevice = device;
                    [self.deviceList addObject:deviceMsg];
                    [delegate.deviceList addObjectsFromArray:self.deviceList];
                    delegate.deviceNameList = [NSMutableArray array];
                    delegate.ownerDeviceList = [NSMutableArray array];
                    for (int i = 0; i<self.deviceList.count; i++) {

                        if (self.ownerID ==[self.deviceList[i].userDevice ownerId]) {

                            [delegate.ownerDeviceList addObject:self.deviceList[i].userDevice];
                        }
                    }
                }
                self.myDeviceTableView.backgroundView = nil;
                [self.myDeviceTableView reloadData];

            }else{
                delegate.ownerDeviceList=nil;
                self.myDeviceTableView.backgroundView = self.subbView;
                [self.myDeviceTableView reloadData];
            }
        }else{
            [ACAccountManager updateAccessTokenCallback:^(BOOL success, NSError *error) {

                if (!error) {

                    [self getDevicelist];
                }else{
                    if (error.code == 3501) {
                        ZJMLoginVC *loginVC = [[ZJMLoginVC alloc]init];
                        loginVC.title = NSLocalizedString(@"Log In", nil);
                        loginVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:loginVC animated:YES];
                    }else{
                        [self loginInvalid];
                    }
                }

            }];
            self.myDeviceTableView.backgroundView = self.subbView;
            [self.myDeviceTableView reloadData];
        }

    }];
}
#pragma mark - 上下拉刷新
-(void)setUpdataTableView{
    Weakself;
    self.myDeviceTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDevicelist];
            [weakSelf.myDeviceTableView.mj_header endRefreshing];
        });
    }];
    
}

#pragma mark - 右边按钮
-(void)setRightBtn{
    UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [rightButton setImage:[UIImage imageNamed:@"＋图标"]forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"＋图标-选中"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(addRobot:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
}

#pragma mark - 添加机器人
- (IBAction)addRobot:(UIButton *)sender {
    if ([ACAccountManager isLogin] ==NO){
        ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
        loginVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginVc animated:YES];
    }else{
        NSString *url =@"link://router/choiceRobot";
        [MGJRouter openURL:url withUserInfo:@{@"navVc":self.navigationController} completion:^(id result) {
            
        }];
//        JMChoiceRobotVC *choiceRobotVc = [[ZJMChoiceRobotVC alloc]init];
//        choiceRobotVc.hidesBottomBarWhenPushed = YES;
//        choiceRobotVc.title = NSLocalizedString(@"Choose Your Robot", nil);
//        [self.navigationController pushViewController:choiceRobotVc animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.deviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZJMDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.rightBtn setImage:[UIImage imageNamed:@"右键"] forState:UIControlStateNormal];
        if (self.deviceList.count>0) {
            self.subDomain =[self.deviceList[indexPath.row].userDevice subDomain];
            if ([[self.deviceList[indexPath.row].userDevice deviceName]isEqualToString:@""]) {
                cell.deviceNameLab.text = [self.deviceList[indexPath.row].userDevice physicalDeviceId];
            }else{
                cell.deviceNameLab.text = [self.deviceList[indexPath.row].userDevice deviceName];
            }
            if ([self.deviceList[indexPath.row].userDevice status] ==0||[self.deviceList[indexPath.row].userDevice status] ==2) {
                
                cell.deviceStatus.text = NSLocalizedString(@"Status: Robot Offline", nil);
            }else{
                cell.deviceStatus.text = NSLocalizedString(@"Status: Robot Online", nil);
            }
            if ([self.subDomain isEqualToString:X430SubDomain]){
                cell.iconImage.image = [UIImage imageNamed:@"机型X430"];
            }else{
               cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"机型%@",[self.subDomain substringWithRange:NSMakeRange(5, 4)].uppercaseString]];
            }
           
        }
    });
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREENHEIGHT*0.15;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectIndexPath = indexPath;
    if (self.deviceList.count>0) {
        //设备离线处理
        if ([self.deviceList[self.selectIndexPath.row].userDevice status] == 0 ||[self.deviceList[self.selectIndexPath.row].userDevice status] == 2) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Offline", nil) message:NSLocalizedString(@"Please Check If Your Robot is Connected to WIFI, If Yes, Please Refresh My Robot Page", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSLog(@"好的");
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            //设备在线处理
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.physicalDeviceId =  [self.deviceList[self.selectIndexPath.row].userDevice physicalDeviceId];
            self.subDomain =  [self.deviceList[indexPath.row].userDevice subDomain];
            delegate.subDomain = self.subDomain;
            delegate.deviceId = [self.deviceList[indexPath.row].userDevice deviceId];
            if ([self.subDomain isEqualToString:X430SubDomain]) {
                self.titleName= NSLocalizedString(@"ILIFE Robotic Cleaner X430", nil);
            }else{
                NSString * str = [NSString stringWithFormat:@"ILIFE Robotic Cleaner %@",[self.subDomain substringWithRange:NSMakeRange(5, 4)].uppercaseString];
                self.titleName = NSLocalizedString(str, nil);
            }
           
            if (_ownerID ==[self.deviceList[indexPath.row].userDevice ownerId]) {
                _isManager=1;
            }else{
                _isManager=0;
            }
           
            [self pushToRechargeVCWithIndexPath:indexPath];
            
            
            
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSLocalizedString(@"Unbind", nil);
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (self.deviceList.count>0) {
            self.device = self.deviceList[indexPath.row];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Unbind Your Robot", nil) message:NSLocalizedString(@"Are You Sure To Unbind Your Robot?", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self showHudWithRound];
                [ACBindManager unbindDeviceWithSubDomain:[self.deviceList[indexPath.row].userDevice subDomain] deviceId:  delegate.deviceId = [self.deviceList[indexPath.row].userDevice deviceId] callback:^(NSError *error) {
                    if(error){
                        NSLog(@"unbindDevice--error:%@",error);
                        if (error.code ==3812) {

                            [self getDevicelist];
                        }else{
                            [self hideHud];
                            [self showHudWithString:NSLocalizedString(@"Unbinding Failed", nil)];
                        }
                    }else{
                        [self getDevicelist];
                    }
                }];
                
            }];

            [alertController addAction:cancelAction];
            [alertController addAction:confirmAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

-(void)pushToRechargeVCWithIndexPath:(NSIndexPath *)indexPath{
     AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self.subDomain isEqualToString:X786SubDomain]) {
        ZJMX786RechargeVC *x786rechargeVc = [[ZJMX786RechargeVC alloc]init];
        if ([[self.deviceList[indexPath.row].userDevice deviceName]isEqualToString:@""]) {
            x786rechargeVc.deviceName = [self.deviceList[indexPath.row].userDevice physicalDeviceId];
        }else{
            x786rechargeVc.deviceName = [self.deviceList[indexPath.row].userDevice deviceName];
        }
        x786rechargeVc.physicalDeviceId = delegate.physicalDeviceId;
        x786rechargeVc.deviceID = delegate.deviceId;
        x786rechargeVc.subDomain=self.subDomain;
        x786rechargeVc.title=self.titleName;
        x786rechargeVc.isManager = _isManager;
        x786rechargeVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:x786rechargeVc animated:YES];
        
    }else{
        ZJMRechargeVC *rechargeVc = [[ZJMRechargeVC alloc]init];
        if ([[self.deviceList[indexPath.row].userDevice deviceName]isEqualToString:@""]) {
            rechargeVc.deviceName = [self.deviceList[indexPath.row].userDevice physicalDeviceId];
            
        }else{
            rechargeVc.deviceName = [self.deviceList[indexPath.row].userDevice deviceName];
        }
        rechargeVc.physicalDeviceId = delegate.physicalDeviceId;
        rechargeVc.deviceID = delegate.deviceId;
        rechargeVc.subDomain=self.subDomain;
        rechargeVc.title=self.titleName;
        rechargeVc.isManager = _isManager;
        rechargeVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rechargeVc animated:YES];
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

#pragma mark - 获取项目版本
-(NSString *)getCurrentVersion{
    NSDictionary *dictionary = [[NSBundle mainBundle]infoDictionary];
    CFShow((__bridge CFTypeRef)(dictionary));
    NSString *currentVersion = [dictionary objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}


@end
