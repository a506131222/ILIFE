//
//  ACClassTopicMessage.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/9.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import "ACTopicMessage.h"
#import "ACClassTopic.h"

@interface ACClassTopicMessage : ACTopicMessage

/** 数据集名称 */
@property (nonatomic, copy) NSString *className;
/** 数据集操作类型 */
@property (nonatomic, assign) ACClassDataOperationType opType;

@end
