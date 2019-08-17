//
//  ZJMRecordDetailVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/30.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h"

@interface ZJMRecordDetailVC : ZJMBaseVC

@property (nonatomic,strong)NSData *mapData;
@property (nonatomic,strong)NSData *roadData;
@property (nonatomic,strong)NSData *firstData;
@property (nonatomic,copy)NSString *subDomain;
@property (atomic,assign)NSInteger deviceID;
@property (atomic,assign)int slam_x_min;
@property (atomic,assign)int slam_x_max;
@property (atomic,assign)int slam_y_min;
@property (atomic,assign)int slam_y_max;

@property (nonatomic)NSInteger startReason;
@property (nonatomic)NSInteger endReanson;
@end
