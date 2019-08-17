//
//  ACCustomTopicMessage.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/7.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopicMessage.h"

@interface ACCustomTopicMessage : ACTopicMessage

/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** 自定义类型 */
@property (nonatomic, copy) NSString *type;
/** 自定义key */
@property (nonatomic, copy) NSString *key;

@end
