//
//  ZJMConsumablesModel.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/11/1.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJMConsumablesModel : NSObject

@property (nonatomic,copy)NSString *imageName;
@property (nonatomic,copy)NSString *consumableText;
@property (atomic,assign)NSInteger number;

@end
