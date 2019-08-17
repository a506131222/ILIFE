//
//  ACHelper.h
//  ACloudLib
//
//  Created by zhourx5211 on 12/14/14.
//  Copyright (c) 2014 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ACHelper : NSObject

+ (NSData *)AES256EncryptWithData:(NSData *)data key:(NSString *)key;
+ (NSData *)AES256DecryptWithData:(NSData *)data key:(NSString *)key;
//生成指定位数 Nonce
+ (NSString *)generateNonceWithLength:(NSInteger)length;
//生成指定位数 trace id
+ (NSString *)generateTraceIdWithLength:(NSInteger)length;

+ (NSString *)generateSignatureWithTimeout:(NSString *)timeout
                                 timestamp:(NSString *)timestamp
                                     nonce:(NSString *)nonce
                                     token:(NSString *)token;

+ (NSTimeInterval)getUTCFormateDate:(NSDate *)localDate;

+ (NSString *)currentWifiSSID;

//base64加密
+ (NSString *)encodeBase64:(NSString *)input;
//base64解密
+ (NSString *)decodeBase64:(NSString *)input;

@end
