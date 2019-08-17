//
//  ZJMConnectionVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2018/9/18.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMConnectionVC.h"
#import "ZJMConnectionCell.h"
#import "ZJMTwoConnectionCell.h"
#import "ZJMAPNetworkVC.h"
#import "ZJMConnectVC.h"
@interface ZJMConnectionVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *connectionTableView;
@property (nonatomic,strong)NSMutableArray *stepArrM;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic,strong)NSMutableArray *imageArrM;
@end

@implementation ZJMConnectionVC

-(NSMutableArray *)stepArrM{
    if (!_stepArrM) {
        _stepArrM = [NSMutableArray array];
    }
    return _stepArrM;
}
-(NSMutableArray *)imageArrM{
    if (!_imageArrM) {
        _imageArrM = [NSMutableArray array];
    }
    return _imageArrM;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.connectionTableView registerNib:[UINib nibWithNibName:@"ZJMTwoConnectionCell" bundle:nil] forCellReuseIdentifier:@"ZJMTwoConnectionCell"];
    self.title = NSLocalizedString(@"Connection Wizard", nil);
    [self.nextBtn setTitle:NSLocalizedString(@"Next Step", nil) forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain]|| [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        return 2;
    }
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X800SubDomain] || [self.subDomain isEqualToString:X430SubDomain] || [self.subDomain isEqualToString:X420SubDomain] || [self.subDomain isEqualToString:X620SubDomain] || [self.subDomain isEqualToString:X610SubDomain]) {
        if (indexPath.row==0) {
            ZJMConnectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell == nil) {
                cell= (ZJMConnectionCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"ZJMConnectionCell" owner:self options:nil]  lastObject];
            }
                cell.stepLabel.text = NSLocalizedString(@"Step One", nil);
                cell.tipsLabel.text = NSLocalizedString(@"Power on the machine and the device enters the standby mode", nil);
                cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导1",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
            return cell;
        }else{
            ZJMTwoConnectionCell *TwoCell = [tableView dequeueReusableCellWithIdentifier:@"ZJMTwoConnectionCell"];
            NSString * tipStr;
            if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
                tipStr = NSLocalizedString(@"After pressing  and holding for 5 seconds in the standby mode, you will hear a buzz, Do not release until voice announcement says \"Start WiFi pairing\", Robot enters APLink mode and network signal light starts blinking。", nil);
            }else{
               
                tipStr = NSLocalizedString(@"After pressing and holding for 5 seconds in the standby mode, you will hear two beeps and release", nil);
            }
            NSMutableAttributedString *attri=[[NSMutableAttributedString alloc] initWithString:tipStr];
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            attch.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导2图标",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
            TwoCell.scendImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导2",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
            NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            NSString *languageName = [appLanguages objectAtIndex:0];
            if ([self.subDomain isEqualToString:X610SubDomain]) {
                 attch.bounds = CGRectMake(0,-2,13,16);
            }else{
                 attch.bounds = CGRectMake(0,-2,15,15);
            }
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            //中文
            if ([languageName containsString:@"Han"]==YES) {
                [attri insertAttributedString:string atIndex:9];
            }else{
                //英文
                [attri insertAttributedString:string atIndex:15];
            }
            
            TwoCell.bottomLabel.attributedText=attri;
            return TwoCell;
        }
    }else{
        if (indexPath.row==0||indexPath.row==2) {
            
            ZJMConnectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell == nil) {
                
                cell= (ZJMConnectionCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"ZJMConnectionCell" owner:self options:nil]  lastObject];
                
            }
            if (indexPath.row==0) {
                cell.stepLabel.text = NSLocalizedString(@"Step One", nil);
                cell.tipsLabel.text = NSLocalizedString(@"Power on the machine and the device enters the standby mode", nil);
                if ([self.subDomain isEqualToString:X782SubDomain]) {
                    cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导1",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
                }else{
                    cell.iconImage.image = [UIImage imageNamed:@"第一步图"];
                }
                
                
            } else {
                cell.stepLabel.text = NSLocalizedString(@"Step Three", nil);
                cell.tipsLabel.text = NSLocalizedString(@"The robot enters the network configuration mode and the network indicator blinks", nil);
                if ([self.subDomain isEqualToString:X782SubDomain]) {
                    cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导3",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
                }else{
                   cell.iconImage.image = [UIImage imageNamed:@"第三步图"];
                }
                
            }
            return cell;
        }else{
            ZJMTwoConnectionCell *TwoCell = [tableView dequeueReusableCellWithIdentifier:@"ZJMTwoConnectionCell"];
            NSMutableAttributedString *attri =[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"After pressing and holding for 5 seconds in the standby mode, you will hear two beeps and release", nil)];
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
              attch.bounds = CGRectMake(0,-2,8,13);
            if ([self.subDomain isEqualToString:X782SubDomain]) {
                  attch.bounds = CGRectMake(0,-2,20,13);
                attch.image = [UIImage imageNamed:@"782连接向导2图标"];
            }else{
                 attch.image = [UIImage imageNamed:@"配网图标"];
            }
            if ([self.subDomain isEqualToString:X782SubDomain]) {
                TwoCell.scendImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@连接向导2",[self.subDomain substringWithRange:NSMakeRange(6, 3)]]];
            }else{
               TwoCell.scendImageView.image = [UIImage imageNamed:@"第二步图"];
            }
           
            NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            NSString *languageName = [appLanguages objectAtIndex:0];
          
            NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
            //中文
            if ([languageName containsString:@"Han"]==YES) {
                [attri insertAttributedString:string atIndex:9];
            }else{
                //英文
                [attri insertAttributedString:string atIndex:15];
            }
            
            TwoCell.bottomLabel.attributedText=attri;
            return TwoCell;
        }
    }
    
   
  
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREENHEIGHT*0.3;
}

#pragma mark - 下一步
- (IBAction)Next:(UIButton *)sender {
    if ([[self returnNetworkState]isEqualToString:@"WIFI"]) {
        ZJMAPNetworkVC *apNetWorkVc = [[ZJMAPNetworkVC alloc]init];
        apNetWorkVc.title = NSLocalizedString(@"AP Networking Mode", nil);
        apNetWorkVc.subDomain = self.subDomain;
        apNetWorkVc.robotName = self.robotName;
        [self.navigationController pushViewController:apNetWorkVc animated:YES];
    }else{
        
        ZJMConnectVC *connectVc = [[ZJMConnectVC alloc]init];
        connectVc.subDomain=self.subDomain;
        [self.navigationController pushViewController:connectVc animated:YES];
        
    }
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
