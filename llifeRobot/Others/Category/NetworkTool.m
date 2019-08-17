//
//  NetworkTool.m
//  XHH_networkTool
//
//  Created by xiaohuihui on 2016/11/26.
//  Copyright © 2016年 30-陈辉华. All rights reserved.
//

#import "NetworkTool.h"
#define kAppleUrlToCheckNetStatus @"http://captive.apple.com/"
@implementation NetworkTool

+ (instancetype)sharedTool {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:nil];
    });
    
    return instance;
}

- (void)requestWithURLString: (NSString *)URLString
                  parameters: (NSDictionary *)parameters
                      method: (NSString *)method
                    callBack: (void (^)(id))callBack {
    
    if ([method isEqualToString:@"GET"]) {
        [self GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            callBack(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }
    
    if ([method isEqualToString:@"POST"]) {
        [self POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            callBack(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }
}
+(BOOL)checkNetCanUse{
    __block BOOL canUse = NO;
    
    NSString *urlString = kAppleUrlToCheckNetStatus;
    
    // 使用信号量实现NSURLSession同步请求**
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 5;
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    
    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //解析html页面
        NSString *htmlString = [self filterHTML:result];
        //除掉换行符
        NSString *resultString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([resultString isEqualToString:@"SuccessSuccess"]) {
            canUse = YES;
            NSLog(@"手机所连接的网络是可以访问互联网的: %d",canUse);
            
        }else {
            canUse = NO;
            NSLog(@"手机无法访问互联网: %d",canUse);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return canUse;
}
+(NSString *)filterHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
    
}


@end
