//
//  ZJMOTAUpdateVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2019/2/25.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "OTAUpdateVC.h"
#import "ACOTAManager.h"
@interface OTAUpdateVC ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic)NSInteger progressNumber;

@end

@implementation OTAUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.progressView.transform=CGAffineTransformMakeScale(1, 5);
}

- (IBAction)updateFirmware:(UIButton *)sender {
    [ACOTAManager confirmUpdateWithSubDomain:_subDomain deviceId:_deviceId newVersion:_lastVersion otaType:ACOTACheckInfoTypeSystem callback:^(NSError *error) {
       
        if (!error) {
             [self showHudWithString:@"升级中"];
             [self listenStautusWithSubDomain:_subDomain DeviceId:_deviceId];
        }else{
             [self showHudWithString:@"超时"];
        }
    }];
    
}

#pragma mark - 状态属性监听
-(void)listenStautusWithSubDomain:(NSString *)subDomain DeviceId:(NSInteger)deviceId{
    [ACDeviceDataManager subscribePropDataWithSubDomain:subDomain deviceId:deviceId callback:^(NSError *error) {
        
        if (!error) {
            [ACDeviceDataManager setPropertyMessageHandler:^(NSString *subDomain, NSInteger deviceId, ACObject *properties) {
                _progressView.progress = [[properties get:@"update_progress"]integerValue];
            
            }];
            
        }else{
            [self showHudWithString:NSLocalizedString(@"Connection Timeout", nil)];
        }
    }];
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
