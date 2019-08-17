//
//  ACOTAInfo.h
//  AbleCloudLib
//
//  Created by leverly on 15/7/11.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 固件升级状态 */
typedef NS_ENUM(NSUInteger, ACOTAUpgradeInfoStatus) {
    ACOTAUpgradeInfoStatusUnDownload = 0,   //未下载
    ACOTAUpgradeInfoStatusDownloadSucceed,  //下载未升级
    ACOTAUpgradeInfoStatusUpdateSucceed     //升级完成
};

@class ACOTAFileMeta;
@interface ACOTAUpgradeInfo : NSObject

/** 原版本 */
@property(nonatomic,copy) NSString *oldVersion;
/** file信息 */
@property(nonatomic,strong) NSArray *file;
/** 设备目标版本 */
@property (nonatomic, copy) NSString *targetVersion;
/** ACOTAMode */
@property (nonatomic, assign) NSInteger otaMode;
/** 升级描述 */
@property(nonatomic,copy) NSString *upgradeLog;
/** 当前升级状态 */
@property (nonatomic, assign) ACOTAUpgradeInfoStatus status;
/** 是否需要升级 */
@property (nonatomic, assign) BOOL update;
/** OTA基本信息 */
@property (nonatomic, strong) ACOTAFileMeta *meta;

@end
