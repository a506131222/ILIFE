//
//  ACFeedBack.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/2/23.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACObject;
@interface ACFeedBack : NSObject
/** 子域 */
@property (nonatomic, copy) NSString *subDomain;
/** 预留字段, 可传nil */
@property (nonatomic, copy) NSString *type;
/** 开发者自定义的扩展信息，与前端定义的字段一致 */
@property (nonatomic, strong) ACObject *extend;
/**
 * 添加意见反馈项
 * 需跟控制台自定义参数对应
 * @param key   对应控制台中的字段
 * @param value 意见反馈的文字内容
 */
- (void)addFeedBackWithKey:(NSString *)key value:(NSString *)value;
/**
 * 添加意见反馈图片
 * 该接口value是图片的url地址, 图片可以通过调用`ACileManager`上传到云端, 也可以将图片存储到其余地方
 * @param key   对应控制台中的字段
 * @param value 图片的url地址
 */
- (void)addFeedBackPictureWithKey:(NSString *)key value:(NSString *)value;

/**
 * 添加意见反馈图片
 * 可以通过直接添加意见反馈图片数组的形式进行上传意见反馈图片
 * 上传图片数组时, SDK会将每一张图片分别上传, 一旦有一张上传失败, 则该次意见反馈提交失败.
 * 上传的图片默认是不做压缩的, 如果需要压缩, 请上传压缩后的图片数组
 * @param key   对应控制台中的字段
 * @param pictures 图片数组
 */
- (void)addFeedbackPictures:(NSArray<UIImage *> *)pictures forKey:(NSString *)key;

- (NSDictionary *)getPictures;

@end

