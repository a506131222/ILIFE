//
//  ZJMChoiceRobotVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/26.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMChoiceRobotVC.h"
#import "ZJMConnectVC.h"
#import "ZJMChoiceRobotCell.h"
#import "Product.h"
#import "ZJMConnectionVC.h"

@interface ZJMChoiceRobotVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *choiceRobotTableView;
@property (strong,nonatomic)NSMutableArray *productArrM;
@property (copy,nonatomic)NSString *subDomain;
@property (strong,nonatomic)NSMutableArray *imageArrM;
@property (strong,nonatomic)NSMutableArray *labelArrM;
@property (strong,nonatomic)NSMutableArray *subDomainArrM;
@property (nonatomic,strong)NSMutableArray *subIDArrM;
@end

@implementation ZJMChoiceRobotVC

#pragma mark - 懒加载
-(NSMutableArray *)productArrM{
    if (_productArrM ==nil) {
        _productArrM =[NSMutableArray array];
    }
    return _productArrM;
}

-(NSMutableArray *)LabelList{
    
    if (_labelArrM == nil) {
        
        _labelArrM = [NSMutableArray array];
    }
    return  _labelArrM;
    
}

-(NSMutableArray *)imageList{
    
    if (_imageArrM == nil) {
        
        _imageArrM = [NSMutableArray array];
    }
    return _imageArrM;
    
}
-(NSMutableArray *)subDomainArrM{
    
    if (_subDomainArrM == nil) {
        
       _subDomainArrM = [NSMutableArray array];
    }
    return _subDomainArrM;
    
}
-(NSMutableArray *)subIDArrM{
    
    if (_subIDArrM == nil) {
        
        _subIDArrM = [NSMutableArray array];
    }
    return _subIDArrM;
    
}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _imageArrM = [@[@"机型X420",@"机型X430",@"机型X660",@"机型X660",@"机型X610",@"机型X620",@"机型X780",@"机型X785",@"机型X786",@"机型X786",@"机型X786",@"机型X800",@"机型X900",@"机型X910"]mutableCopy];
    _labelArrM = [@[@"X420",@"X430",@"X660",@"X660HF",@"X610",@"X620",@"X782",@"X785",@"X786",@"X787",@"X790",@"X800",@"X900",@"X910"]mutableCopy];
    _subDomainArrM = [@[X420SubDomain,X430SubDomain,X660SubDomain,X660SubDomain,X610SubDomain,X620SubDomain,X782SubDomain,X785SubDomain,X786SubDomain, X787SubDomain,X790SubDomain,X800SubDomain,X900SubDomain,X910SubDomain]mutableCopy];
    _subIDArrM = [@[@"6396",@"5789",@"6555",@"6555",@"6793",@"6768",@"6234",@"6231",@"6370", @"6422",@"6640",@"6312",@"6369",@"6822"]mutableCopy];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.labelArrM = [NSMutableArray array];
    [delegate.labelArrM addObject:_labelArrM];
    [_choiceRobotTableView registerNib:[UINib nibWithNibName:@"ZJMChoiceRobotCell" bundle:nil] forCellReuseIdentifier:@"cell"];

}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJMChoiceRobotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.robotLab.text = _labelArrM[indexPath.row];
    cell.textLabel.textColor = HexColor(0x333333);
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
    cell.robotImage.image= [UIImage imageNamed:_imageArrM[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     return _labelArrM.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
        ZJMConnectionVC *connectionVc = [[ZJMConnectionVC alloc]init];
        connectionVc.title = NSLocalizedString(@"Connection Wizard", nil);
        connectionVc.subDomain = _subDomainArrM[indexPath.row];
        [self.navigationController pushViewController:connectionVc animated:YES];
    
}   

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SCREENHEIGHT*0.15;
}
@end
