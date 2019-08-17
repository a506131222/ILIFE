//
//  ZJMReserModel.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/25.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJMReserModel : NSObject<NSCoding>
/** 预约编号*/
@property (assign,atomic) NSInteger reserNumber;
/** 预约开关*/
@property (assign,atomic) NSInteger reserOpen;
/** 重复*/
@property (assign,atomic)NSInteger week;
/** 小时*/
@property (assign,atomic)NSInteger hour;
/** 分钟*/
@property (assign,atomic)NSInteger min;

@property (strong,nonatomic)NSMutableArray *dataArrM;

@property (assign,atomic)NSInteger number;

@end
