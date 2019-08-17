//
//  ZJMRecordDetailVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/30.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMRecordDetailVC.h"
#import "ACloudLib.h"
#import "CleanView.h"
#import "PointModel.h"
#import "PreHeader.h"
#import "SlamView.h"
#define MAXLAYERSPACE 3.0

@interface ZJMRecordDetailVC ()

@property (strong,nonatomic)CleanView *cleanView;
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*pathArr;
@property (weak, nonatomic) IBOutlet UIView *mapView;


@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (assign, nonatomic) CGFloat scale;//记录上次手势结束的放大倍数
@property (assign, nonatomic) CGFloat realScale;//当前手势应该放大的倍数
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong)NSMutableArray *pointArrM;
@property (nonatomic,strong)SlamView *slamView;
@property (weak, nonatomic) IBOutlet UILabel *startCleanLab;
@property (weak, nonatomic) IBOutlet UILabel *endCleanLab;
@property (weak, nonatomic) IBOutlet UIView *resaonView;

@end

@implementation ZJMRecordDetailVC
{
    NSData *byteData;
    int length;
    Byte *cleanByte;
    NSData *cleanData;
    NSInteger x;
    NSInteger y;
    CGImageRef inputCGImage;
    unsigned char *data;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    _slamView.hidden = YES;
    _mapView.hidden = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]) {
        _slamView = [[SlamView alloc] initWithFrame: CGRectMake(0, 0, SCREENWEIGHT,SCREENHEIGHT*0.83)];
        [self.mapView addSubview:_slamView];
        [_slamView modifyAlphaData:_mapData];
        CGFloat distance = self.slam_x_max-self.slam_x_min;
        CGFloat distanceY = (MAPWIDTH-self.slam_y_min)-(MAPWIDTH-self.slam_y_max);
        NSInteger X= ((self.slam_x_max-self.slam_x_min)/2-(MAPWIDTH/2-(self.slam_x_min)))/(MAPWIDTH/SCREENWEIGHT);
        NSInteger Y =((MAPWIDTH - self.slam_y_min-(MAPWIDTH-self.slam_y_max))/2-(MAPWIDTH/2-(MAPWIDTH-self.slam_y_max)))/(MAPWIDTH/SCREENWEIGHT);
        CGFloat scale;
        if (distanceY<distance) {
            scale = MAPWIDTH/distance;
            if (scale>=8) {
                scale = 8;
            }
        }else{
            scale = MAPWIDTH/distanceY;
        }
        if (scale>=10) {
            scale = 10;
        }
        _slamView.type = NSLocalizedString(@"Record Detail", nil);
        [_slamView setScale:scale withTranslateByX:X andY:Y];
        Byte *mapByte = (Byte *)[_roadData bytes];
        NSMutableArray * historyArr = [[NSMutableArray alloc] init];
        for (int i = 0; i<[_roadData length]; i+=2) {
            int16_t point =((mapByte[i]<<8)+mapByte[i+1]);
            point=point*SlamPathRadio+MAPWIDTH/2;
            [historyArr addObject:[NSString stringWithFormat:@"%d",point]];
        }
        if (historyArr.count>=4&&historyArr.count%2==0) {
            [_slamView drawLineByPathArr:historyArr type:0];
        }
    }else{
        if (isIphoneX_Series==1) {
            
            _cleanView = [[CleanView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT-_resaonView.height-NavBar_Height-Status_Height-Bottom_Safe_Height)];
        }else{
            _cleanView = [[CleanView alloc]initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT-_resaonView.height-NavBar_Height-Status_Height)];
        }
        [self.view addSubview:_cleanView];
        [self getCleanData:_mapData];
    }
    if ([self.subDomain isEqualToString:X900SubDomain] || [self.subDomain isEqualToString:X910SubDomain]|| [self.subDomain isEqualToString:X790SubDomain]) {
        self.resaonView.layer.cornerRadius = 10;
        _startCleanLab.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Start Reason", nil),[self getStartReasonNumber:_startReason]];
        _endCleanLab.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Stop Reason", nil),[self getEndReasonNumber:_endReanson]];
        _startCleanLab.font=[UIFont systemFontOfSize:16];
        _endCleanLab.font=[UIFont systemFontOfSize:16];
    }else{
        self.resaonView.hidden = YES;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startCleanLab.font=[UIFont systemFontOfSize:17];
    self.endCleanLab.font=[UIFont systemFontOfSize:17];
}

-(NSString *)getStartReasonNumber:(NSInteger)number{
    NSString *text;
    switch (number) {
        case 1:
            text=NSLocalizedString(@"App trigger", nil);
            break;
        case 2:
            text=NSLocalizedString(@"Remote control trigger", nil);
            break;
        case 3:
            text=NSLocalizedString(@"Button trigger", nil);
            break;
        case 4:
            text=NSLocalizedString(@"App timing trigger",nil);
            break;
        case 5:
            text=NSLocalizedString(@"Host timing trigger",nil);
            break;
        case 6:
            text=NSLocalizedString(@"Breakpoint sweep trigger",nil);
            break;
        default:
            text=NSLocalizedString(@"App trigger", nil);
            break;
    }
    return text;
}
-(NSString *)getEndReasonNumber:(NSInteger)number{
    NSString *text;
    switch (number) {
        case 1:
            text=NSLocalizedString(@"Normal cleaning is stopped",nil);
            break;
        case 2:
            text=NSLocalizedString(@"Low battery chargeback stop",nil);
            break;
        case 3:
            text=NSLocalizedString(@"Remote control pause",nil);
        case 4:
            text=NSLocalizedString(@"Button pause",nil);
            break;
        case 5:
            text=NSLocalizedString(@"App actively suspended",nil);
            break;
        case 6:
            text=NSLocalizedString(@"Abnormal alarm stop",nil);
            break;
        default:
            text=NSLocalizedString(@"Normal cleaning is stopped",nil);
            break;
    }
    return text;
}
-(void)getCleanData:(NSData *)data{
    if ([self.subDomain isEqualToString:X790SubDomain]) {
        _pointArrM=[NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            Byte *mapByte = (Byte *)[_mapData bytes];
            NSInteger lenth =((mapByte[0]<<8)+mapByte[1]);
            NSInteger mapCount; //长度
            NSInteger temp=0;
            NSInteger index=0;
            NSInteger maxX=0;
            for (int i=2; i<[data length]-2; i+=2) {
                mapCount=mapByte[i+1];
                int type = mapByte[i];
                if (type==3||type==4) {
                    type=2;
                }
                for (int j=0; j<mapCount; j++) {
                    x=0;
                    y=0;
                    x = -(x+temp);
                    y = y-index;
                    temp++;
                    [_pointArrM addObject:[NSString stringWithFormat:@"%ld",x]];
                    [_pointArrM addObject:[NSString stringWithFormat:@"%ld",y]];
                    [_pointArrM addObject:[NSString stringWithFormat:@"%d",type]];
                    if (temp>=lenth) {
                        index++;
                        maxX=temp;
                        temp=0;
                    }
                }
            }
            NSInteger   columnSpace =  lroundf(SCREENHEIGHT/2/maxX) ;
            if (columnSpace>3) {
                columnSpace=3;
            }
            for (int i=0; i<_pointArrM.count;i+=3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_cleanView addMapByPoint:CGPointMake([_pointArrM[i]integerValue]+(maxX/2), [_pointArrM[i+1]integerValue]+(index/2)) Type:[_pointArrM[i+2]integerValue] ColumnSpace:columnSpace];
                });
                
            }
            
        });
        
    }else{
         _pointArrM=[NSMutableArray array];
        Byte *mapByte = (Byte *)[_firstData bytes];
        cleanByte = (Byte *)[data bytes];
        length = mapByte[0];
        CGFloat columnSpace = self.view.bounds.size.height/(length*8);
        CGFloat rowSpace = self.view.bounds.size.width/([data length]/length);
        CGFloat scale = MIN(columnSpace, rowSpace)/MAXLAYERSPACE*0.8;
        _cleanView.scaleLevel = scale;
        if (columnSpace>MAXLAYERSPACE) {
            columnSpace = MAXLAYERSPACE;
        }
        [_cleanView setBeginScale:scale];
        for (int i = 0; i < [data length]/length; i++) {
            for (int j = 0; j<length; j++) {
                Byte rowByte = cleanByte[i*length+j];
                for (int k = 0; k < 8; k++) {
                    Byte tempdata = (Byte)(0x80>>k);
                    if ((rowByte&tempdata)==tempdata) {
                        x = -(i-data.length/length/2);
                        y = j * 8 + k - length*4;
                        if ([self.subDomain isEqualToString:X660SubDomain] || [self.subDomain isEqualToString:X800SubDomain]) {
                            [_cleanView addMapByPoint:CGPointMake(-x,y) Type:2 ColumnSpace:columnSpace];
                        }else{
                            [_cleanView addMapByPoint:CGPointMake(x,y) Type:2 ColumnSpace:columnSpace];
                        }
                    }
                }
            }
        }
       
        NSLog(@"所有清扫点 == %@",_pointArrM);
    }
}

- (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}
#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _cleanView;
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
