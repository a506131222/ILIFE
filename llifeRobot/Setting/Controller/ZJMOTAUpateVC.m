//
//  ZJMOTAUpateVC.m
//  llifeRobot
//
//  Created by 魏青青 on 2019/2/22.
//  Copyright © 2019年 ZJM. All rights reserved.
//

#import "ZJMOTAUpateVC.h"
#import "ACOTAManager.h"
#import "ZJMUpgradingVC.h"

@interface ZJMOTAUpateVC ()
@property (nonatomic,strong)NSTimer *proTimer;
@property (weak, nonatomic) IBOutlet UILabel *oldVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (nonatomic,copy)NSString *newsVersion;
@property (nonatomic)BOOL update;

@end

@implementation ZJMOTAUpateVC
{
    NSInteger type;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_proTimer invalidate];
    _proTimer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Firmware Update", nil);
    [_updateBtn setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    _oldVersionLabel.text=NSLocalizedString(@"Currently the latest version", nil);
    [self showHudWithRound];
    if ([self.subDomain isEqualToString:X790SubDomain]) {
        ACOTACheckInfo * checkInfo = [ACOTACheckInfo checkInfoWithDeviceId:self.deviceId otaType:ACOTACheckInfoTypeSystem];
        [ACOTAManager checkUpdateWithSubDomain:self.subDomain OTACheckInfo:checkInfo callback:^(ACOTAUpgradeInfo *checkInfo, NSError *error) {
            [self hideHud];
            if (error) {
                [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
            }else{
                NSLog(@"%d",checkInfo.update);
                if (!checkInfo.targetVersion) {
                    _newsVersionLabel.hidden=YES;
                    [_updateBtn setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
                     _update=NO;
                }else{
                    _newsVersion=checkInfo.targetVersion;
                    _newsVersionLabel.hidden=NO;
                    _oldVersionLabel.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"The Current Version", nil), checkInfo.oldVersion];
                    _newsVersionLabel.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"The Latest Version", nil),_newsVersion];
                    [_updateBtn setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
                    _update=YES;
                }
            }
        }];
    }else{
            Byte content[] = {0};
            NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:84 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                [self hideHud];
                if (error) {
                    [self showHudWithString:NSLocalizedString(@"Connecting Timeout", nil)];
                    
                }else{
                    NSData * statuData = [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(0, 1)];
                    NSString * statuStr = [self convertDataToHexStr:statuData];
                    self.oldVersionLabel.text = [NSString stringWithFormat:@"%@: %@.%@.%@.%@",
                                             NSLocalizedString(@"The Current Version", nil),[NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(2, 1)]]  UTF8String], 0, 16)],
                                             [NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(3, 1)]]  UTF8String], 0, 16)],
                                             [NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(4, 1)]] substringToIndex:2] UTF8String], 0, 16)],
                                             [NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(5, 1)]] substringToIndex:2] UTF8String], 0, 16)] ];
                    if([statuStr isEqualToString:@"01"]){
                        //有更新
                        self.newsVersionLabel.hidden = NO;
                        self.newsVersionLabel.text = [NSString stringWithFormat:@"%@: %@.%@.%@.%@",
                                               NSLocalizedString(@"The Latest Version", nil),[NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(6, 1)]]  UTF8String], 0, 16)],
                                               [NSString stringWithFormat:@"%lu",strtoul([[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(7, 1)]]  UTF8String], 0, 16)],
                                               [NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(8, 1)]] substringToIndex:2] UTF8String], 0, 16)],
                                               [NSString stringWithFormat:@"%lu",strtoul([[[self convertDataToHexStr: [[responseMsg getBinaryData] subdataWithRange:NSMakeRange(9, 1)]] substringToIndex:2] UTF8String], 0, 16)] ];
                        [_updateBtn setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
                        _newsVersion = self.newsVersionLabel.text;
                        _update = YES;
                        
                    }else if ([statuStr isEqualToString:@"02"]){
                         //正在更新
                        
                    }else{
                        _newsVersionLabel.hidden=YES;
                        [_updateBtn setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
                        _update=NO;
                    }
                    
                }
            }];
    }
}


#pragma mark - 响应事件

- (IBAction)confirmBtnDidClick:(UIButton *)sender {
    if (_update == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if ([self.subDomain isEqualToString:X790SubDomain]) {
            [self showHudWithRound];
            [ACOTAManager confirmUpdateWithSubDomain:_subDomain deviceId:_deviceId newVersion:_newsVersion otaType:ACOTACheckInfoTypeSystem callback:^(NSError *error) {
                [self hideHud];
                if (!error) {
                    type=0;
                }else{
                    type=1;
                }
                ZJMUpgradingVC *upgragdingVc=[[ZJMUpgradingVC alloc]init];
                upgragdingVc.title=NSLocalizedString(@"Firmware Update", nil);
                upgragdingVc.sudDomain=self.subDomain;
                upgragdingVc.deviceId=self.deviceId;
                upgragdingVc.type=type;
                upgragdingVc.lastVersion=_newsVersion;
                [self.navigationController pushViewController:upgragdingVc animated:YES];
                
            }];
            
        }else{
            Byte content[] = {1};
            NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:85 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:_physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                if (!error) {
                    type = 0;
                }else{
                    type = 1;
                }
                ZJMUpgradingVC *upgragdingVc=[[ZJMUpgradingVC alloc]init];
                upgragdingVc.title=NSLocalizedString(@"Firmware Update", nil);
                upgragdingVc.physicalDeviceId = self.physicalDeviceId;
                upgragdingVc.sudDomain=self.subDomain;
                upgragdingVc.deviceId=self.deviceId;
                upgragdingVc.type=type;
                upgragdingVc.lastVersion=_newsVersion;
                [self.navigationController pushViewController:upgragdingVc animated:YES];
                
            }];
        }
        
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



@end
