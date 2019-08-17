//
//  ACACL.h
//  AbleCloudLib
//
//  Created by 乞萌 on 15/8/31.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ACObject;
@interface ACACL : NSObject

typedef enum: NSInteger {
    ACACLOpTypeREAD,
    ACACLOpTypeWRITE,
} ACACLOpType;

/** 是否全局可读 */
@property (nonatomic, assign, readonly) BOOL isPublicReadAllow;
/** 是否全局可写 */
@property (nonatomic, assign, readonly) BOOL isPublicWriteAllow;
/** 白名单 */
@property (nonatomic, strong, readonly) ACObject *userAccessObj;
/** 黑名单 */
@property (nonatomic, strong, readonly) ACObject *userDenyObj;

/*
 * 设置`全局可读`访问权限，不设置则默认为所有人可读
 */
- (void)setPublicReadAccess:(BOOL)allow;

/*
 * 设置`全局可写`访问权限，不设置则默认为除自己外的所有人不可写
 */
- (void)setPublicWriteAccess:(BOOL)allow;

/**
 * 设置用户可访问权限（白名单）
 *
 * @param optype 权限类型，OpType.READ为可读权限，OpType.WRITE为可写权限
 * @param userId 被设置用户Id
 */
- (void)setUserAccess:(ACACLOpType)optype userId:(long)userId;

/**暂不使用
 * 取消设置用户可访问权限（白名单），恢复默认权限
 *
 * @param optype 权限类型，OpType.READ为可读权限，OpType.WRITE为可写权限
 * @param userId 被设置用户Id
 */
- (void)unsetUserAccess:(ACACLOpType)optype userId:(long)userId;

/**
 * 设置用户访问权限（黑名单）
 *
 * @param optype 权限类型，OpType.READ为可读权限，OpType.WRITE为可写权限
 * @param userId 被设置用户Id
 */
- (void)setUserDeny:(ACACLOpType)optype userId:(long)userId;

/**暂不使用
 * 取消设置用户访问权限（黑名单），恢复默认权限
 *
 * @param optype 权限类型，OpType.READ为可读权限，OpType.WRITE为可写权限
 * @param userId 被设置用户Id
 */
- (void)unsetUserDeny:(ACACLOpType)optype userId:(long)userId;

//辅助函数
- (ACObject *)toACObject;
- (NSString *)getUserKey:(long)user;
- (ACObject *)getAuthObjectByKey:(ACObject * )accessObj key:(NSString *)key create:(BOOL)create;
- (void)setUserAccessDictionaryWithObj:(ACObject *)obj opType:(ACACLOpType)opType isAllow:(BOOL)isAllow key:(NSString *)key;
@end
