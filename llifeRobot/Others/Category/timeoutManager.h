//
//  timeoutManager.h
//  llifeRobot
//
//  Created by 张佳满 on 2018/7/9.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface timeoutManager : NSObject


@property (nonatomic, assign)__block int timeout;
@property (assign,atomic)   __block int codeType;

+ (id)sharedTimerManager;

- (void)countDown;

@end
