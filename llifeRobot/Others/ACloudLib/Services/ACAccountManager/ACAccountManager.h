//
//  ACAccountManager.h
//  ACloudLib
//
//  Created by zhourx5211 on 14/12/8.
//  Copyright (c) 2014年 zcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACloudLibConst.h"
#import "ACMsg.h"


// 第三方的登陆的provider
extern NSString *const ACAccountManagerLoginProviderQQ;
extern NSString *const ACAccountManagerLoginProviderWeibo;
extern NSString *const ACAccountManagerLoginProviderWechat;
extern NSString *const ACAccountManagerLoginProviderJingDong;
extern NSString *const ACAccountManagerLoginProviderFacebook;
extern NSString *const ACAccountManagerLoginProviderTwitter;
extern NSString *const ACAccountManagerLoginProviderInstagram;
extern NSString *const ACAccountManagerLoginProviderOther;

@class ACUserInfo, ACMsg;
@interface ACAccountManager : NSObject

#pragma mark - 验证码
/**
 * 发送验证码
 * @param account  要发送的账号
 * @param template 发送短信模板, 使用前需要在控制台定义
 * @param callback 发送结果回调
 */
+ (void)sendVerifyCodeWithAccount:(NSString *)account
                         template:(NSInteger)template
                         callback:(void (^)(NSError *error))callback;

/**
 * 验证验证码是否可用
 * @param account    要验证的账号
 * @param verifyCode 要验证的验证码
 * @param callback   验证结果回调
 */
+ (void)checkVerifyCodeWithAccount:(NSString *)account
                        verifyCode:(NSString *)verifyCode
                          callback:(void (^)(BOOL valid,NSError *error))callback;

#pragma mark - 注册
/**
 * 注册账号
 * `phone`和`email`二选其一, 如果两个参数同时传入, 那么验证码默认以手机请求的验证码为主
 * @param phone      电话号码
 * @param email      邮箱地址
 * @param password   密码
 * @param verifyCode 验证码
 * @param callback   注册结果回调
 */
+ (void)registerWithPhone:(NSString *)phone
                    email:(NSString *)email
                 password:(NSString *)password
               verifyCode:(NSString *)verifyCode
                 callback:(void (^)(NSString *uid, NSError *error))callback;

#pragma mark - 登陆
/**
 * 登陆 返回uid
 * @param account  电话号码
 * @param password 密码
 * @param callback 登陆结果回调
 */
+ (void)loginWithAccount:(NSString *)account
                password:(NSString *)password
                callback:(void (^)(NSString *uid, NSError *error))callback;

/**
 * 登陆 成功之后返回用户的默认属性对象
 * @param account  电话号码
 * @param password 密码
 * @param callback 登陆结果回调
 */
+ (void)loginWithUserInfo:(NSString *)account
                 password:(NSString *)password
                 callback:(void (^)(ACUserInfo *user, NSError *error))callback;

/**
 * 使用验证码登陆 成功之后返回用户的默认属性对象
 * @discussion 若账户不存在则自动注册新的用户
 * @param account       电话号码
 * @param verifyCode    验证码
 * @param callback      登陆结果回调
 */
+ (void)loginWithAccount:(NSString *)account
              verifyCode:(NSString *)verifyCode
                callback:(void (^)(ACUserInfo *user, NSError *error))callback;

#pragma mark - 第三方账号
/**
 * 第三方账号登录
 * @param openId      通过第三方登录获取的openId
 * @param provider    第三方类型（如QQ、微信、微博, Facebook, 京东, Twitter, Instagram）
 * @param accessToken 通过第三方登录获取的accessToken
 * @param callback    第三方登陆结果回调
 */
+ (void)loginWithOpenId:(NSString *)openId
               provider:(NSString *)provider
            accessToken:(NSString *)accessToken
               callback:(void (^)(ACUserInfo *user, NSError *error))callback;

/**
 * 绑定一个未被注册的普通帐号
 * @discussion emai和phone可以任选其一;nickName为可选项
 * @param email         邮箱地址
 * @param phone         电话号码
 * @param password      密码
 * @param nickName      昵称
 * @param verifyCode    验证码
 * @param callback      绑定结果回调
 */
+ (void)bindAccountWithEmail:(NSString *)email
                       phone:(NSString *)phone
                    password:(NSString *)password
                    nickName:(NSString *)nickName
                  verifyCode:(NSString *)verifyCode
                    callback:(void (^)(NSError *error))callback;

/**
 * 绑定第三方账号
 * @param openId      通过第三方登录获取的openId
 * @param provider    第三方类型（如QQ、微信、微博, Facebook, 京东, Twitter, Instagram）
 * @param accessToken 通过第三方登录获取的accessToken
 * @param callback    绑定第三方账号结果回调
 */
+ (void)bindWithOpenId:(NSString *)openId
              provider:(NSString *)provider
           accessToken:(NSString *)accessToken
              callback:(void(^)(NSError *error))callback;

#pragma mark - 修改密码/昵称/扩展属性
/**
 * 修改密码
 * @param old         旧密码
 * @param newPassword 新密码
 * @param callback    修改密码结果回调
 */
+ (void)changePasswordWithOld:(NSString *)old
                          new:(NSString *)newPassword
                     callback:(void (^)(NSString *uid, NSError *error))callback;

/**
 * 重置密码
 * @param account    重置密码的账户
 * @param verifyCode 验证码
 * @param password   新密码
 * @param callback   重置密码结果回调
 */
+ (void)resetPasswordWithAccount:(NSString *)account
                      verifyCode:(NSString *)verifyCode
                        password:(NSString *)password
                        callback:(void (^)(NSString *uid, NSError *error))callback;

/**
 * 更换手机号
 * @param phone      新手机号
 * @param password   密码
 * @param verifyCode 验证码
 * @param callback   更换手机号结果回调
 */
+ (void)changePhone:(NSString *)phone
           password:(NSString *)password
         verifyCode:(NSString *)verifyCode
           callback:(void(^)(NSError *error))callback;

/**
 * 更换邮箱
 * @param email      新邮箱
 * @param password   密码
 * @param verifyCode 验证码
 * @param callback   更换邮箱结果回调
 */
+ (void)changeEmail:(NSString *)email
           password:(NSString *)password
         verifyCode:(NSString *)verifyCode
           callback:(void(^)(NSError *error))callback;

#pragma mark - 扩展属性
/**
 * 根据用户的uid     获取该用户的公有属性
 * @param userList 用户uid数组
 * @param callback 用户的公有属性结果回调
 */
+ (void)getPublicProfilesByUserList:(NSArray *)userList
                           callback:(void(^)(NSArray<ACObject *> *userList, NSError *error))callback;

/**
 * 设置当前用户的头像
 * @param image    头像图片
 * @param callback 设置头像结果回调
 */
+ (void)setAvatar:(UIImage *)image
         callback:(void(^)(NSString *avatarUrl, NSError *error))callback;

/**
 * 修改昵称
 * @param nickName 新的昵称
 * @param callback 修改昵称结果回调
 */
+ (void)changeNickName:(NSString *)nickName
              callback:(void (^) (NSError *error))callback;

/**
 * 获取帐号扩展属性
 * @param callback  获取帐号扩展属性结果回调
 */
+ (void)getUserProfile:(void (^)(ACObject *profile, NSError *error))callback;

/**
 * 修改帐号扩展属性
 * @param profile   用户扩展属性键值
 * @param callback  修改帐号扩展属性结果回调
 */
+ (void)setUserProfile:(ACObject *)profile
              callback:(void (^)(NSError *error))callback;

#pragma mark - 状态管理
/**
 * 判断用户是否已经存在
 * @param account   用户账户
 * @param callback  判断结果回调
 */
+ (void)checkExist:(NSString *)account
          callback:(void(^)(BOOL exist,NSError *error))callback;

/**
 * 判断用户是否已经在本机上过登陆
 */
+ (BOOL)isLogin;

/**
 * 注销当前用户(退出登录)
 */
+ (void)logout;

/**
 * 更新用户的 accessToken
 */
+ (void)updateAccessTokenCallback:(void (^)(BOOL success, NSError *error))callback;

/**
 * 重新生成用户的refreshToken
 * @discussion 本用户的refreshToken会强制过期并自动重新获取，开发者无需再次登录。
 */
+ (void)regenerateRefreshToken:(void (^)(NSError *error))callback;

/**
 * refresh token 过期回调
 * @discussion 建议在主页面任意处设置此回调，并在此回调中做 <重新登录> 操作处理。
 */
+ (void)setRefreshTokenInvalidCallback:(void (^)(NSError *error))callback;
 

#pragma mark - Deprecated

/**
 * 重置密码返回更多基本信息
 * @param account    账户名
 * @param verifyCode 验证码
 * @param password   重置的密码
 * @param callback   重置密码回调
 */
+ (void)resetPasswordWithUserInfo:(NSString *)account
                       verifyCode:(NSString *)verifyCode
                         password:(NSString *)password
                         callback:(void (^)(ACUserInfo *user, NSError *error))callback ACDeprecated("过期");

/**
 * 指定昵称注册
 * @param nickName   昵称
 * @param phone      电话
 * @param email      邮箱
 * @param password   密码
 * @param verifyCode 验证码
 * param callback   注册回调
 */
+ (void)registerWithNickName:(NSString *)nickName
                       phone:(NSString *)phone
                       email:(NSString *)email
                    password:(NSString *)password
                  verifyCode:(NSString *)verifyCode
                    callback:(void (^)(ACUserInfo *user, NSError *error))callback ACDeprecated("过期");

@end
