//
//  ACKeyChain.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/14/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACKeyChain : NSObject

+ (void)saveUserId:(NSNumber *)userId;
+ (NSNumber *)getUserId;
+ (void)removeUserId;

+ (void)saveDevicerId:(NSString *)devicerId;
+ (NSString *)getDevicerId;
+ (void)removeDeviceId;

+ (void)saveToken:(NSString *)token;
+ (void)saveTokenExpire:(NSString *)tokenExpire;
+ (NSString *)getToken;
+ (NSString *)getTokenExpire;

+ (void)saveRefreshToken:(NSString *)token;
+ (void)saveRefreshTokenExpire:(NSString *)tokenExpire;
+ (NSString *)getRefreshToken;
+ (NSString *)getRefreshTokenExpire;

+ (void)removeToken;
@end
