//
//  ZJMCleanRecordModel.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/29.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJMCleanRecordModel : NSObject


@property (nonatomic,copy)NSString *day;
@property (nonatomic,copy)NSString *time;
@property (atomic,assign)int clean_time;
@property (atomic,assign)int clean_area;
@property (nonatomic,strong)NSData *data;
@property (nonatomic,strong)NSData *firstData;
@property (nonatomic,strong)NSData *roadData;
@property (atomic,assign)int slam_x_min;
@property (atomic,assign)int slam_x_max;
@property (atomic,assign)int slam_y_min;
@property (atomic,assign)int slam_y_max;

@property (nonatomic)NSInteger length;
@property (nonatomic)NSInteger start;
@property (nonatomic)NSInteger end;

@end
