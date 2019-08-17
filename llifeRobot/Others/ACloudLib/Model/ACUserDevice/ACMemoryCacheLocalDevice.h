//
//  ACMemoryCacheLocalDevice.h
//  AbleCloudLib
//
//  Created by __zimu on 16/4/1.
//  Copyright © 2016年 ACloud. All rights reserved.
//
//  用户存储本地设备列表

#import <Foundation/Foundation.h>

@interface ACMemoryCacheLocalDevice : NSObject

@property (nonatomic, strong) NSMutableArray *localDeviceList;

+ (instancetype)sharedManager;

+ (void)clearCache;

@end
