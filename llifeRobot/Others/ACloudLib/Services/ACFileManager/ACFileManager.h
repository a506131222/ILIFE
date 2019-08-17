//
//  ACFileManager.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/8/31.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

static  NSMutableDictionary * downloadCancelDictionary;
typedef double (^progress )();

@class ACMsg;
@class ACFileInfo;

@interface ACFileManager : NSObject<NSURLSessionDownloadDelegate>
/** 进度回调 */
@property (nonatomic, strong) progress progressCallback;
/** 下载进度 */
@property (unsafe_unretained,nonatomic) float progress;
/** 文件类型 */
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSMutableDictionary *uploadCancelDictionary;
@property (nonatomic, strong) NSMutableDictionary *downloadCancelDictionary;


#pragma mark - 上传文件



/**
 * 上传文件

 * @param fileInfo         文件信息
 * @param progressCallback 上传进度
 * @param voidCallback     上传结果
 */
- (void)uploadFileWithfileInfo:(ACFileInfo *)fileInfo
              progressCallback:(void(^)(float progress))progressCallback
                  voidCallback:(void(^)(ACMsg *responseObject,NSError * error))voidCallback;

/**
 * 获取下载url
 *
 * @param fileInfo   文件下载信息
 * @param expireTime 如果文件上传到 public  空间， 则expireTime这个参数无效，获取的url是永久有效的;
 *                   如果文件上传到 private 空间， 所获取的访问/下载URL的有效时长。单位为秒。
 *                   如果取值为小于或等于0,国内环境长期有效，国外环境表示7天。
 */
- (void)getDownloadUrlWithfile:(ACFileInfo *)fileInfo
                    ExpireTime:(long)expireTime
               payloadCallback:( void (^)(NSString * urlString,NSError * error))callback;

/**
 * //session下载

 * @param urlString        获得的downURLString
 * @param callback         返回error信息的回调
 * @param completeCallback 返回完成的信息的回调
 */
- (void)downFileWithsession:(NSString * )urlString
                   checkSum:(NSInteger)checkSum
                   callBack:(void(^)(float progress ,NSError * error))callback
           CompleteCallback:(void (^)(NSString *filePath))completeCallback;

/*
 * 取消下载
 */
- (void)cancel;

/*
 * 暂停下载
 */
- (void)suspend;

/*
 * 恢复下载
 */
- (void)resume;

/*
 * 取消上传
 * @param fileInfo      文件信息
 */
- (void)cancleUploadWithfileInfo:(ACFileInfo *)fileInfo;

@end
