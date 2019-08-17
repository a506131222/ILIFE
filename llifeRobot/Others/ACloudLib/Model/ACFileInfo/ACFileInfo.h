//
//  ACFileInfo.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/8/31.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACACL.h"

@interface ACFileInfo : NSObject
/** 上传文件名字 */
@property (nonatomic, copy) NSString *name;
/** 上传小型文件，直接上传数据 不支持断点续传 */
@property (nonatomic, strong) NSData *data;
/** 上传文件路径，支持断点续传 */
@property (copy,nonatomic) NSString *filePath;
/** 文件访问权限 如果不设置 则默认 */
@property (nonatomic, strong) ACACL *acl;
/** 文件存储的空间   用户自定义   如名字为Image或者text的文件夹下 */
@property (nonatomic, copy) NSString *bucket;

/**
* 上传文件的空间(不同空间获取下载链接getDownloadUrl时具有不同时效性)
* <p/>
* YES:上传文件到 public 空间，下载该文件时获取的url是永久有效的;
* NO :上传文件到 private 空间，获取的url是有有效期的，并且带有签名信息
* 默认是NO
*/
@property (nonatomic, assign) BOOL isPublic;

/** crc校验使用 */
@property (nonatomic, unsafe_unretained) NSInteger checksum;

/**
 * 初始化
 * @param name   上传文件名字
 * @param bucket 文件存储的空间
 */
- (instancetype)initWithName:(NSString *)name bucket:(NSString *)bucket;

/**
 * 初始化
 * @param name 上传文件名字
 * @param bucket 文件存储的空间
 * @param checksum crc校验
 */
- (instancetype)initWithName:(NSString *)name bucket:(NSString *)bucket Checksum:(NSInteger )checksum;

/**
 * 初始化
 * @param name 上传文件名字
 * @param bucket 文件存储的空间
 * @param checksum crc校验
 */
+ (instancetype)fileInfoWithName:(NSString *)name bucket:(NSString *)bucket CheckSum:(NSInteger )checksum;

- (BOOL)isCrc;

@end
