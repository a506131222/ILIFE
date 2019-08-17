//
//  ZJMPersonalVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/16.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMPersonalVC.h"
#import "ZJMLoginVC.h"
#import "ZJMUserNameVC.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "ZJMQRCodeScanningVC.h"
#import "ZJMShareNameCell.h"
#import "ZJMShareCodeVC.h"
#import "ZJMProblemFeedbackVC.h"
#import "RHScanViewController.h"
@interface ZJMPersonalVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) IBOutlet UIView *headView;

@property (strong,nonatomic)NSMutableArray *LabelList;
@property (strong,nonatomic)NSMutableArray *imageList;

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong,nonatomic)NSString *buttonText;

@property(nonatomic,strong) NSMutableArray<DeviceMsg *> *deviceList;

@property(nonatomic,strong)DeviceMsg *device;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)NSMutableArray *deviceNameArrM;
@property (assign, atomic) BOOL isExpand;
@property (nonatomic,strong)UIImageView *arrowImage;
@property (atomic,assign)NSInteger deviceId;

@end

@implementation ZJMPersonalVC
{
    NSString  *base64Sting;
    NSIndexPath *path;
     NSString *appVersion;
}

#pragma mark - 懒加载
-(NSMutableArray *)LabelList{
    
    if (_LabelList == nil) {
        
        _LabelList = [NSMutableArray array];
    }
    return  _LabelList;
    
}

-(NSMutableArray *)imageList{
    
    if (_imageList == nil) {
        
        _imageList = [NSMutableArray array];
    }
    return _imageList;
    
}

#pragma mark - 数组懒加载
- (NSMutableArray<DeviceMsg *> *)deviceList {
    if (_deviceList == nil) {
        _deviceList = [NSMutableArray array];
      
        
    }
    return _deviceList;
}

-(NSIndexPath *)selectIndexPath {
    if (_selectedIndexPath == nil) {
        _selectedIndexPath = [[NSIndexPath alloc]init];
    }
    return _selectedIndexPath;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loginStatus];
    self.tabBarController.tabBar.hidden = NO;
    _deviceNameArrM = [NSMutableArray array];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.ownerDeviceList.count >0) {
        for (int i = 0; i < delegate.ownerDeviceList.count; i++) {
            
            ACUserDevice *userDevice =delegate.ownerDeviceList[i];
            _deviceId = userDevice.deviceId;
            if ([userDevice.deviceName isEqualToString:@""]) {
                [_deviceNameArrM addObject:userDevice.physicalDeviceId];
            }else{
                [_deviceNameArrM addObject:userDevice.deviceName];
            }
        }
    }
    if ([[self returnNetworkState]isEqualToString:@"无网络"]) {
        appVersion = [[NSUserDefaults standardUserDefaults]objectForKey:@"appVersion"];
        
    }else{
        appVersion = delegate.appVersion;
    }
    
    _isExpand=NO;
    _selectedIndexPath=nil;
    [self.myTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    [_myTableView registerNib:[UINib nibWithNibName:@"ZJMShareNameCell" bundle:nil] forCellReuseIdentifier:@"ZJMShareNameCell"];
    _LabelList = [@[NSLocalizedString(@"Scan QR Code", nil),
                    NSLocalizedString(@"Share Your Robot",nil),
                    NSLocalizedString(@"Feedback",nil),
                    NSLocalizedString(@"Delete Your Account", nil),
                    NSLocalizedString(@"Version", nil),
                    NSLocalizedString(@"Log Out", nil)]mutableCopy];
    _imageList = [@[@"扫描二维码",@"设备共享",@"问题反馈",@"删除图标",@"版本",@"退出"]mutableCopy];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    _loginBtn.titleLabel.numberOfLines=0;
    [_avaterImage cornerRadius:_avaterImage.frame.size.height/2];
    [self.myTableView setTableHeaderView:_headView];
    
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.loginBtn setTitle:_buttonText forState:UIControlStateNormal];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAvater:)];
    [self.avaterImage addGestureRecognizer:tapGesture];
    
    

    
}


#pragma mark - 判断是否登录
-(void)loginStatus{
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
//    UIImage *savedImage = [UIImage imageWithContentsOfFile:fullPath];
    if ([ACAccountManager isLogin] ==YES) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [ACAccountManager getUserProfile:^(ACObject *profile, NSError *error) {
                if (!error) {
                    NSDictionary *ObjectDic = [profile getObjectData];
//                    NSString *imageUrl = ObjectDic[@"_avatar"];
                    NSString *userName = ObjectDic[@"nick_name"];
                    
                    if (![userName isEqualToString:@""]) {
                        [self.loginBtn setTitle:userName forState:UIControlStateNormal];
                        
                    }else{
                        [_loginBtn setTitle:NSLocalizedString(@"Set User Name", nil)  forState:UIControlStateNormal];
                    }
                     self.avaterImage.image = [UIImage imageNamed:@"头像"];
//                    if (imageUrl)
//                    {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:savedImage];
//                        });
//                    }
                    
                }else{
                    
                    [_loginBtn setTitle:NSLocalizedString(@"Set User Name", nil)  forState:UIControlStateNormal];
                }
            }];
        });
    }
    else{
         self.avaterImage.image = [UIImage imageNamed:@"头像"];
        [_loginBtn setTitle:NSLocalizedString(@"Log In\\Sign Up", nil) forState:UIControlStateNormal];
    }
}
#pragma mark - 登录/注册
- (IBAction)gotoLoginVC:(UIButton *)sender {
    
    if ([ACAccountManager isLogin] ==YES) {
        
        ZJMUserNameVC *userNameVC = [[ZJMUserNameVC alloc]init];
        userNameVC.backUserNameBlock = ^(NSString *userName) {
            if (userName.length > 12) {
                NSRange range = [userName rangeOfComposedCharacterSequenceAtIndex:12];
                 _buttonText = [userName substringToIndex:range.location];

            }else{
                _buttonText = userName;
            }
           
            [self.loginBtn setTitle:_buttonText forState:UIControlStateNormal];
        };
        userNameVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:userNameVC animated:YES completion:nil];
    }
    else{
        ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
        loginVc.title = NSLocalizedString(@"Log In", nil);
        loginVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginVc animated:YES];
        
    }
}
#pragma mark - 右边按钮
-(void)setRightBtn{
    
    UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
    [rightButton setImage:[UIImage imageNamed:@"消息"]forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"消息"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(pushInformationVC)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
}
#pragma mark - 修改头像
- (void)changeAvater:(UIGestureRecognizer *)gestureRecognizer {
    if ([ACAccountManager isLogin]) {
         [self showHudWithString:NSLocalizedString(@"Modification of avatars is not supported", nil)];
    }
    else{
        //未登录时处理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please Log In First", nil) message:NSLocalizedString(@"Log in?",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
            loginVc.title = NSLocalizedString(@"Please Log In First", nil);
            loginVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVc animated:YES];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 保存图片至本地沙盒

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.8);
    
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return _LabelList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (_isExpand && _selectedIndexPath.section == section) {

        return 1 + _deviceNameArrM.count;
       
    }
    else{
    
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isExpand && _selectedIndexPath.section == indexPath.section &&indexPath.row >0) {
          ZJMShareNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZJMShareNameCell"];// Expand Cell

        [cell.deviceNameBtn setTitle:_deviceNameArrM[indexPath.row-1] forState:UIControlStateNormal];
        return cell;
      
    } else {
        static NSString *cellId = @"cell";

        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
         float arrowImageH = cell.bounds.size.height/4;
        _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
        _arrowImage.image = [UIImage imageNamed:@"右键"];
        cell.accessoryView = _arrowImage;
        cell.textLabel.text = _LabelList[indexPath.section];
        cell.textLabel.textColor = HexColor(0x333333);
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
        cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
        cell.imageView.image= [UIImage imageNamed:_imageList[indexPath.section]];
      
        if (indexPath.section == 4) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSString *version =NSLocalizedString(@"Version", nil);
//            if (appVersion==nil) {
//                 cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 1.0",version];
//            }else{
//               cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",version,appVersion];
//            }
           
            cell.detailTextLabel.text= [NSString stringWithFormat:@"%@ V%@" ,version,[self getCurrentVersion]];
            cell.accessoryView = nil;
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREENHEIGHT*0.08;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch (indexPath.section) {
        case 0:{
            if ([ACAccountManager isLogin] ==NO){
                  [self showHudWithString:NSLocalizedString(@"Please Log In First", nil)];
            }else{
            
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
           
                if (device) {
             
                    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
              
                    if (status == AVAuthorizationStatusNotDetermined) {
                
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                     
                            if (granted) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                RHScanViewController *scanVc = [RHScanViewController new];
                                scanVc.title = NSLocalizedString(@"Scan QR Code", nil);
                                scanVc.isOpenInterestRect = YES;
                                scanVc.isVideoZoom = YES;
                                scanVc.hidesBottomBarWhenPushed = YES;
                                [self.navigationController pushViewController:scanVc animated:YES];
                            });
                           
                            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    
                            } else {
                           
                            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        }
                    }];
                } else if (status == AVAuthorizationStatusAuthorized) {
                    RHScanViewController *scanVc = [RHScanViewController new];
                    scanVc.title = NSLocalizedString(@"Scan QR Code", nil);
                    scanVc.isOpenInterestRect = YES;
                    scanVc.isVideoZoom = YES;
                    scanVc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:scanVc animated:YES];

                } else if (status == AVAuthorizationStatusDenied) {
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Allow \"ILIFE Robot\" to Access Camera", nil) preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                    
                    [alertC addAction:alertA];
                    [self presentViewController:alertC animated:YES completion:nil];
                    
                } else if (status == AVAuthorizationStatusRestricted) {
                    NSLog(@"因为系统原因, 无法访问相册");
                }
            } else {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Camera Error", nil) preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                
            } 
            
        }
             break;
        case 1:{
              UITableViewCell *cell  = (UITableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
             AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([ACAccountManager isLogin] ==NO){
                [self showHudWithString:NSLocalizedString(@"Please Log In First", nil)];
            }else{
            
                if (_selectedIndexPath==nil) {
                self.isExpand = YES;
                _selectedIndexPath = indexPath;
                [self.myTableView beginUpdates];
                [self.myTableView insertRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                
                            if (indexPath.section==1) {
                                float arrowImageH = cell.bounds.size.height/6;
                                 _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*35/24,arrowImageH)];
                                _arrowImage.image = [UIImage imageNamed:@"箭头-向下"];
                                 cell.accessoryView = _arrowImage;
                            }
            
                [self.myTableView endUpdates];
                    if (delegate.ownerDeviceList.count==0) {
                        [self showHudWithString:NSLocalizedString(@"No Shareable Robots",nil)];
                    }
            }
            else {
               
                if (self.isExpand) {
                    if (_selectedIndexPath == indexPath) {
                        self.isExpand = NO;
                        [self.myTableView beginUpdates];
                        [self.myTableView deleteRowsAtIndexPaths:[self indexPathsForExpandSection:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
                        [self.myTableView endUpdates];
                        _selectedIndexPath = nil;
                         float arrowImageH = cell.bounds.size.height/4;
                        _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,arrowImageH*18/27,arrowImageH)];
                        _arrowImage.image = [UIImage imageNamed:@"右键"];
                       
                        cell.accessoryView = _arrowImage;
                        if (delegate.ownerDeviceList.count==0) {
                            [self showHudWithString:NSLocalizedString(@"No Shareable Robots",nil)];
                        }
                        
                    }else {
                        
                        ACUserDevice *user =[[ACUserDevice alloc]init];
                        if (delegate.ownerDeviceList.count>0) {
                            user =delegate.ownerDeviceList[indexPath.row-1];
                            ZJMShareCodeVC *shareCodeVC = [[ZJMShareCodeVC alloc]init];
                            shareCodeVC.receiveDeviceId = user.deviceId;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                shareCodeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                [self presentViewController:shareCodeVC animated:YES completion:nil];
                            });
                        }else{
                          
                        }
                   }
                }
            }
        }
    }
            break;
        case 2:{
            if ([ACAccountManager isLogin] ==NO){
                [self showHudWithString:NSLocalizedString(@"Please Log In First", nil)];
            }else{
                ZJMProblemFeedbackVC *problemFeedbackVc = [[ZJMProblemFeedbackVC alloc]init];
                problemFeedbackVc.title =NSLocalizedString(@"Feedback", nil);
                problemFeedbackVc.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:problemFeedbackVc animated:YES];
            }
    
        }
            break;
        case 3:{
            if ([ACAccountManager isLogin] ==NO){
                [self showHudWithString:NSLocalizedString(@"Please Log In First", nil)];
            }else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Delete Your Account", nil) message:NSLocalizedString(@"Please Use Your Register Email To Send \" Apply For Account Deletion\" to XXX@abc.com. Your Account Will Be Deleted Soon. Thank You For Your Support.", nil) preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
        }
            break;
        case 4:{
              UITableViewCell *cell  = (UITableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
            break;
        case 5:{
            if ([ACAccountManager isLogin] ==NO){
                [self showHudWithString:NSLocalizedString(@"Please Log In First", nil)];
            }else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"The History Record Will Remain After Log-out, You Can Use Same Account In Next Log-in", nil) preferredStyle: UIAlertControllerStyleActionSheet];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Log Out", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.avaterImage.image = [UIImage imageNamed:@"头像"];
                });
                ZJMLoginVC *loginVc = [[ZJMLoginVC alloc]init];
                loginVc.title = NSLocalizedString(@"Log In", nil);
                loginVc.hidesBottomBarWhenPushed = YES;
                [ACAccountManager logout];
                [self.navigationController pushViewController:loginVc animated:YES];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:deleteAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
            break;
        default:
            break;
        }
    }
}


- (NSArray *)indexPathsForExpandSection:(NSInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 1; i <= _deviceNameArrM.count; i++) {
        path = [NSIndexPath indexPathForRow:i inSection:section];
        
        [indexPaths addObject:path];
    
    }
    return [indexPaths copy];
}
-(NSString *)getCurrentVersion{
    NSDictionary *dictionary = [[NSBundle mainBundle]infoDictionary];
    CFShow((__bridge CFTypeRef)(dictionary));
    NSString *currentVersion = [dictionary objectForKey:@"CFBundleShortVersionString"];
    return currentVersion;
}

@end
