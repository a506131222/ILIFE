//
//  ZJMWebView.h
//  ZJMWebViewExample
//
//  Created by kingsic on 17/3/27.
//  Copyright © 2017年 kingsic. All rights reserved.
//
//  ZJMWebView 使用注意点：
//  如果 self.navigationController.navigationBar.translucent = NO；或者导航栏不存在; 那么 SGWebView 的 isNavigationBarOrTranslucent属性 必须设置 NO)

#import <UIKit/UIKit.h>
@class ZJMWebView;

@protocol ZJMWebViewDelegate <NSObject>
@optional
/** 页面开始加载时调用 */
- (void)webViewDidStartLoad:(ZJMWebView *)webView;
/** 内容开始返回时调用 */
- (void)webView:(ZJMWebView *)webView didCommitWithURL:(NSURL *)url;
/** 页面加载失败时调用 */
- (void)webView:(ZJMWebView *)webView didFinishLoadWithURL:(NSURL *)url;
/** 页面加载完成之后调用 */
- (void)webView:(ZJMWebView *)webView didFailLoadWithError:(NSError *)error;
@end

@interface ZJMWebView : UIView
/** SGDelegate */
@property (nonatomic, weak) id<ZJMWebViewDelegate> ZJMQRCodeDelegate;
/** 进度条颜色(默认蓝色) */
@property (nonatomic, strong) UIColor *progressViewColor;
/** 导航栏标题 */
@property (nonatomic, copy) NSString *navigationItemTitle;
/** 导航栏存在且有穿透效果(默认导航栏存在且有穿透效果) */
@property (nonatomic, assign) BOOL isNavigationBarOrTranslucent;

/** 类方法创建 SGWebView */
+ (instancetype)webViewWithFrame:(CGRect)frame;
/** 加载 web */
- (void)loadRequest:(NSURLRequest *)request;
/** 加载 HTML */
- (void)loadHTMLString:(NSString *)HTMLString;
/** 刷新数据 */
- (void)reloadData;


@end

