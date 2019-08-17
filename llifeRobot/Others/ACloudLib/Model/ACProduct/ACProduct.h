//
//  ACProduct.h
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2017/1/18.
//  Copyright © 2017年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACProduct : NSObject

/** 主域ID */
@property(nonatomic, assign, readonly) NSInteger domainId;
/** 主域名称 */
@property(nonatomic, copy, readonly) NSString *domain;
/** 子域ID */
@property(nonatomic, assign, readonly) NSInteger subDomainId;
/** 子域名称 */
@property(nonatomic, copy, readonly) NSString *subDomain;
/** 产品名称 */
@property(nonatomic, copy, readonly) NSString *name;
/** 产品型号 */
@property(nonatomic, copy, readonly) NSString *model;
/** 产品图片地址 */
@property(nonatomic, copy, readonly) NSString *imageUrl;
/** 产品描述 */
@property(nonatomic, copy, readonly) NSString *desc;

/**
 * 使用字典初始化
 * @param dict 属性字典
 */
+ (instancetype)productWithDict:(NSDictionary *)dict;

@end
