//
//  ZJMConsumablesSituationVC.m
//  llifeRobot
//
//  Created by Yannis on 24/10/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMConsumablesSituationVC.h"
#import "ZJMConsumablesCell.h"
#import "ZJMConsumablesModel.h"

@interface ZJMConsumablesSituationVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *consumablessTableView;
@property (strong,nonatomic)NSMutableArray *imageList;
@property (strong,nonatomic)NSMutableArray *textList;
@property (strong,nonatomic)NSMutableArray *numberArrM;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;

@end

@implementation ZJMConsumablesSituationVC

#pragma mark - 懒加载
-(NSMutableArray *)imageList{
    if (_imageList == nil) {
        _imageList = [NSMutableArray array];
    }
    return _imageList;
}

-(NSMutableArray *)textList{
    if (_textList == nil) {
        _textList = [NSMutableArray array];
    }
    return _textList;
}
-(void)viewWillAppear:(BOOL)animated{
    
     [self.consumablessTableView registerNib:[UINib nibWithNibName:@"ZJMConsumablesCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    _numberArrM = [NSMutableArray array];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Byte content[] = {0};
    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:68 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        NSData *data = responseMsg.payload;
        Byte dataByte[7];
        if (!error) {
            for(int i=0;i<[data length];i++){
                Byte *byte= (Byte *)[data bytes];
                dataByte[i]=byte[i];
            }
            for (int i = 0; i <[data length]; i++) {
                if (i>1&&i<6) {
                     ZJMConsumablesModel *consumModel = [[ZJMConsumablesModel alloc]init];
                    consumModel.number = dataByte[i];
                    
                    [_numberArrM addObject:consumModel];
                    
                    [self.consumablessTableView reloadData];
                }
            }

            
        } else {
            NSLog(@"查询成功");
        }
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    
    _textList = [@[NSLocalizedString(@"Side Brush Life", nil),NSLocalizedString(@"Main Brush Life", nil),NSLocalizedString(@"Filter Life", nil)]mutableCopy];
    _imageList = [@[@"边刷",@"滚刷",@"滤网"]mutableCopy];
    _tipsLab.text = NSLocalizedString(@"Tips: Long Press to Reset Spare Parts Life", nil);
    _tipsLab.font = [UIFont systemFontOfSize:16];
//     _tipsLab.font = [UIFont fontWithName:@"PingFangSC-Light" size:17];
    _tipsLab.font =  [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREENHEIGHT*0.15;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _textList.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZJMConsumablesModel  *consumablesModel;
    ZJMConsumablesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (self.numberArrM.count >0) {
    consumablesModel = self.numberArrM[indexPath.row];
        float progressText = [[NSString stringWithFormat:@"%.2f",consumablesModel.number/100.0]floatValue];
        if (progressText >1.00) {
            cell.pregressView.progress = 0;
            cell.numberLab.text = @"0%";
            
        }else{
            cell.pregressView.progress = progressText;
            
            //转成百分比
            CFLocaleRef currentLocale = CFLocaleCopyCurrent();
            
            CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterPercentStyle);
            
            CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &progressText);
            
            CFStringRef numberString = CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
            cell.numberLab.text = [NSString stringWithFormat:@"%@",numberString];
            
            CFRelease(currentLocale);
            CFRelease(numberFormatter);
            CFRelease(number);
            CFRelease(numberString);
        }
       
    }
    else{
        cell.pregressView.progress = 0;
        cell.numberLab.text = @"0%";
        
    }
    cell.lifeImage.image= [UIImage imageNamed:_imageList[indexPath.row]];
    cell.lifeLab.text = _textList[indexPath.row];
    cell.lifeLab.font = [UIFont systemFontOfSize:18.0];
    if (consumablesModel.number>=20) {
        cell.pregressView.progressTintColor = HexColor(0x12BEB8);
        
    }else if (consumablesModel.number>=5&&consumablesModel.number<20){
        cell.pregressView.progressTintColor = HexColor(0xFFCC22);
    }else {
       cell.pregressView.progressTintColor = HexColor(0xFF5511);
    }
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(reset:)];
    
    [cell addGestureRecognizer:longPress];
    return cell;
}

#pragma mark - 长按重置**寿命
-(void)reset:(UIGestureRecognizer *)longPress{
    if (longPress.state==UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        CGPoint location = [longPress locationInView:self.consumablessTableView];
        NSIndexPath *indexPath = [self.consumablessTableView indexPathForRowAtPoint:location];
      
        NSString *title = self.textList[indexPath.row];
        NSString *reset = NSLocalizedString(@"Are You Sure To Reset", nil);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@?",reset,title] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            Byte byte[5] = {};
            for (int i = 0; i< 5; i++) {
                byte[indexPath.row] = 1;
            }

            NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
            ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:75 binaryData:data];
            [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                Byte secondByte[7];
                if (!error) {
                    for(int i=0;i<[data length];i++){
                        Byte *byte= (Byte *)[data bytes];
                        secondByte[i]=byte[i];
                    }
                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    Byte content[] = {0};
                    NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
                    ACDeviceMsg *msg = [[ACDeviceMsg alloc] initWithCode:68 binaryData:data];
                    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:_subDomain physicalDeviceId:delegate.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
                        NSData *data = responseMsg.payload;
                        NSMutableArray *cellNumberArrM = [NSMutableArray array];
                        Byte dataByte[7];
                         ZJMConsumablesModel *consumModel = [[ZJMConsumablesModel alloc]init];
                        if (!error) {
                            for(int i=0;i<[data length];i++){
                                Byte *byte= (Byte *)[data bytes];
                                dataByte[i]=byte[i];
                            }
                            for (int i = 0; i <[data length]; i++) {
                                if (i>1&&i<6) {
                                   
                                    consumModel.number = dataByte[i];
                                    
                                    [cellNumberArrM addObject:consumModel];
                                    
                                }
                                
                            }
                            if (cellNumberArrM.count >0) {
                                NSLog(@"%ld",indexPath.row);
                                consumModel = cellNumberArrM[indexPath.row];
                                float progressText = [[NSString stringWithFormat:@"%.2f",consumModel.number/100.0]floatValue];
                                 ZJMConsumablesCell *cell = [self.consumablessTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                                cell.pregressView.progress = progressText;
                                
                                //转成百分比
                                CFLocaleRef currentLocale = CFLocaleCopyCurrent();
                                
                                CFNumberFormatterRef numberFormatter = CFNumberFormatterCreate(NULL, currentLocale, kCFNumberFormatterPercentStyle);
                                
                                CFNumberRef number = CFNumberCreate(NULL, kCFNumberFloatType, &progressText);
                                
                                CFStringRef numberString = CFNumberFormatterCreateStringWithNumber(NULL, numberFormatter, number);
                                cell.numberLab.text = [NSString stringWithFormat:@"%@",numberString];
                                
                            }
                            
                            
                        } else {
                            NSLog(@"查询成功");
                        }
                    }];

                    [self showHudWithString:NSLocalizedString(@"Reset Done", nil)];
                    
                    
                } else {
                    NSLog(@"重置失败");
 
                }
            }];

        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
}

#pragma mark -FirstResponder
-(BOOL)canBecomeFirstResponder{
    return YES;
}
@end
