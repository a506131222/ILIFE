//
//  ACPushReceive.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/10/12.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACObject;
@interface ACPushReceive : NSObject

/** 数据集名称 */
@property (nonatomic, copy) NSString *className;
/** 数据集操作类型 */
@property (nonatomic,unsafe_unretained) long opType;
/** 数据内容 */
@property (nonatomic,strong) ACObject *payload;


@end
