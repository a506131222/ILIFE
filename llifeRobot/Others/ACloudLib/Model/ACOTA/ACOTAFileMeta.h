//
//  ACOTAFileInfo.h
//  AbleCloudLib
//
//  Created by leverly on 15/7/11.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** OTA基本信息 */
@interface ACOTAFileMeta : NSObject
/** 文件名 */
@property (nonatomic, copy) NSString *name;
/** 文件类型 */
@property(nonatomic,assign) NSInteger type;
/** 文件校验和 */
@property(nonatomic,assign) NSInteger checksum;
/** 文件下载URL */
@property(nonatomic,copy) NSString *downloadUrl;

@end
