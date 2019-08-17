//
//  ACFeedBackManager.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/2/25.
//  Copyright © 2016年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACFeedBack;
@interface ACFeedBackManager : NSObject

/**
* 提交用户意见反馈
* @param feedback 反馈实例
* @param callback 反馈信息提交结果回调
*/
+ (void)submitFeedBack:(ACFeedBack *)feedback
              callback:(void(^)(BOOL isSuccess, NSError *error))callback;


@end
