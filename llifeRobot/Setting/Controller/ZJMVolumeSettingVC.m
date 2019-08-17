//
//  ZJMVolumeSettingVC.m
//  llifeRobot
//
//  Created by 魏青青 on 2019/8/9.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMVolumeSettingVC.h"

@interface ZJMVolumeSettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISlider *sld;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;


@end

@implementation ZJMVolumeSettingVC{
    Byte dataByte[2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sld.value = _volume;
    self.saveBtn.layer.cornerRadius = 5;
    if (_isOpen) {
        _soundSwitch.on = YES;
    }else{
        _soundSwitch.on = NO;
    }
    [_soundSwitch addTarget:self action:@selector(switchDidClick:) forControlEvents:UIControlEventValueChanged];
    [_sld addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - 音量的开关
-(void)switchDidClick:(UISwitch *)sw{
    if (sw.on) {
        _isOpen = YES;
    }else{
        _isOpen = NO;
    }
}
#pragma mark - 音量大小的调节
-(void)sliderValueChange:(UISlider *)slider{
    _volume = slider.value;

}
#pragma mark - 保存音量设置
- (IBAction)save:(UIButton *)sender {
    [self showHudWithRound];
    NSData * data;
    if (_isOpen) {
        dataByte[0] = (_volume << 1) + 1;
        data =[NSData dataWithBytes:dataByte length:sizeof(dataByte)];
    }else{
        dataByte[0] = (_volume << 1) + 0;
        data =[NSData dataWithBytes:dataByte length:sizeof(dataByte)];
    }
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:78 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        [self hideHud];
        if (!error) {
            [self showHudWithString:@"下发成功"];
        }else{
            [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
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
