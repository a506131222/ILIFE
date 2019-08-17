//
//  ACNotificationManager.h
//  AbleCloudLib
//
//  Created by zhourx5211 on 7/21/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import <UserNotifications/UserNotifications.h>
#import "ACloudLibConst.h"

@interface ACNotificationManager : NSObject

/** 
 * 绑定App的appKey和启动参数，启动消息参数用于处理用户通过消息打开应用相关信息
 * @param appKey      主站生成appKey
 * @param launchOptions 启动参数
 */
+ (void)startWithAppkey:(NSString *)appKey launchOptions:(NSDictionary *)launchOptions ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/** 
 * 注册RemoteNotification的类型
 * @brief 开启消息推送，实际调用：[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
 * @warning 此接口只针对 iOS 7及其以下的版本，iOS 8 请使用 `registerRemoteNotificationAndUserNotificationSettings`
 * @param types 消息类型，参见`UIRemoteNotificationType`
 */
+ (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
/** 
 * 注册RemoteNotification的类型
 * @brief 分别针对iOS8以前版本及iOS8及以后开启推送消息推送。
 * 默认的时候是sound，badge ,alert三个功能全部打开。
 * @param notificationSettings iOS8及以上，iOS10以下版本的推送类型。默认types8 = UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge;
 */
+ (void)registerRemoteNotificationAndUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_AVAILABLE_IOS(8_0) ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
/** 
 * 注册RemoteNotification的类型
 * @brief iOS10及以上版本的推送。
 * 默认的时候是sound，badge ,alert三个功能全部打开。
 * @param options iOS10及以上版本的推送类型。默认types10 = UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
 * @param completionHandler 用户点击授权结果回调。
 */
+ (void)registerRemoteNotificationWithTarget:(id)target
                        authorizationOptions:(UNAuthorizationOptions)options
                           completionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler NS_AVAILABLE_IOS(10_0) ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");
#endif

/** 
 * 解除RemoteNotification的注册（关闭消息推送，实际调用：[[UIApplication sharedApplication] unregisterForRemoteNotifications]）
 * @param types 消息类型，参见`UIRemoteNotificationType`
 */
+ (void)unregisterForRemoteNotifications ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/** 
 * 向友盟注册该设备的deviceToken，便于发送Push消息
 * @param deviceToken APNs返回的deviceToken
 */
+ (void)registerDeviceToken:(NSData *)deviceToken ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/** 
 * 应用处于运行时（前台、后台）的消息处理
 * @param userInfo 消息参数
 */
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/** 
 * 为某个消息发送点击事件
 * @warning 请注意不要对同一个消息重复调用此方法，可能导致你的消息打开率飚升，此方法只在需要定制 Alert 框时调用
 * @param userInfo 消息体的NSDictionary，此Dictionary是
 * (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo中的userInfo
 */
+ (void)setNotificationClickForRemoteNotification:(NSDictionary *)userInfo ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/**
 * 添加推送别名
 *
 * @param userId   用户ID
 * @param callback 返回结果的监听回调
 */
+ (void)addAliasWithUserId:(NSInteger)userId callback:(void (^)(NSError *error))callback ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

/**
 * 若要使用新的别名，请先调用removeAlias接口移除掉旧的别名
 *
 * @param userId   用户ID
 * @param callback 返回结果的监听回调
 */
+ (void)removeAliasWithUserId:(NSInteger)userId callback:(void (^)(NSError *error))callback ACDeprecated("请参照 http://docs.ablecloud.cn/current/ios/site/guide_ios/doc/消息推送/");

@end
