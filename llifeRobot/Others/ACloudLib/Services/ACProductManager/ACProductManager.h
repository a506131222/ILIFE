//
//  ACProductManager.h
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2017/1/18.
//  Copyright © 2017年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACProduct;
/**
 * 获取产品信息管理
 */
@interface ACProductManager : NSObject

/**
 * 获取所有产品的信息列表
 *
 * @return callback 所有产品的信息
 */
+ (void)fetchAllProducts:(void (^)(NSArray<ACProduct *> *products,
                                  NSError *error))callback;
/**
 * 获取子域对应产品的信息
 *
 * @param subDomain 产品子域名称
 * @return callback 子域对应产品的信息
 */
+ (void)fetchProductWithSubdomain:(NSString *)subDomain
                         callback:(void (^)(ACProduct *product,
                                            NSError *error))callback;

@end
