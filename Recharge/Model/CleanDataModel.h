//
//  cleanModel.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/5/31.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CleanDataModel : NSObject


@property (nonatomic)NSInteger dataNum;
@property (nonatomic)NSInteger dataId;
@property (nonatomic,strong)NSMutableData *data;
@end
