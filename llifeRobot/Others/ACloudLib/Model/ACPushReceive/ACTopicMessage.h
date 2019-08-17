//
//  ACTopicMessage.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/6.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACObject;

/**
 * 订阅消息基类
 */
@interface ACTopicMessage : NSObject

/** 数据内容 */
@property (nonatomic, strong) ACObject *payload;

@end
