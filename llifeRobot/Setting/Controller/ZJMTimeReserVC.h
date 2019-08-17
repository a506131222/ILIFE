//
//  ZJMTimeReserVC.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/10/16.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMBaseVC.h" 

typedef void (^BackUserNameBlock) (NSMutableArray *userNamelist);

@interface ZJMTimeReserVC : ZJMBaseVC

@property (copy,nonatomic)BackUserNameBlock backUserNameBlock;

@property (copy,nonatomic)NSData *receiveData;

@property (assign,atomic)NSInteger reserNumber;
@property (assign,atomic)NSMutableArray * reserNumArr;

@property (assign,atomic)BOOL cellDidSelect;
@property (assign,atomic)NSInteger reserHour;
@property (atomic,assign)NSInteger reserMin;
@property (nonatomic,strong)NSMutableArray *reserWeekStrArrM;
@property (assign,atomic)NSInteger type;
@property (nonatomic,copy)NSString *subDomain;
@property (copy,nonatomic)NSMutableString *oneWeekText;

/**已经预约的星期 */
@property (nonatomic,strong)NSMutableArray *reserWeekArrM;

@end
