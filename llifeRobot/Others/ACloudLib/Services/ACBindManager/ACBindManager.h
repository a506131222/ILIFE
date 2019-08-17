//
//  ACBindManager.h
//  AbleCloudLib
//
//  Created by OK on 15/3/24.
//  Copyright (c) 2015年 ACloud. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ACDeviceMsg.h"
#import "ACloudLibConst.h"

//设备通讯的优先性设置
typedef enum: NSUInteger {
    ACDeviceCommunicationOptionOnlyLocal = 1,  //仅通过局域网
    ACDeviceCommunicationOptionOnlyCloud,      //仅通过云端
    ACDeviceCommunicationOptionCloudFirst,     //云端优先
    ACDeviceCommunicationOptionLocalFirst,     //局域网优先
} ACDeviceCommunicationOption;


@class ACDeviceMsg, ACMsg, ACUserDevice, ACObject;
@interface ACBindManager : NSObject

@property (nonatomic, strong) NSArray *cahceArray;

#pragma mark 设备权限管理
/**
 *  获取设备列表,不包含设备状态信息
 *  @discussion         单次最多返回100个设备信息
 *  @param callback     数组：devices保存的对象是ACUserDevice的对象
 */
+ (void)listDevicesWithCallback:(void(^)(NSArray<ACUserDevice *> *devices,NSError *error))callback;

/**
 *  分页获取设备列表,不包含设备状态信息
 *  @discussion         此接口不会缓存设备的信息因此调用此接口后局域网无法通信
 *  @param limit        返回设备的数量
 *  @param offset       查询起始点偏移量
 *  @param callback     数组：devices保存的对象是ACUserDevice的对象
 */
+ (void)listDevicesFrom:(NSInteger)offset
                  limit:(NSInteger)limit
               callback:(void(^)(NSArray<ACUserDevice *> *devices,NSError *error))callback;

/**
 *  获取设备列表,包含设备在线状态信息
 *  @discussion         单次最多返回100个设备信息
 *  @param callback     数组：devices保存的对象是ACUserDevice的对象
 */
+ (void)listDevicesWithStatusCallback:(void(^)(NSArray<ACUserDevice *> *devices,NSError *error))callback;

/**
 *  分页获取设备列表,包含设备在线状态信息
 *  @discussion         此接口不会缓存设备的信息因此调用此接口后局域网无法通信
 *  @param limit        返回设备的数量
 *  @param offset       查询起始点偏移量
 *  @param callback     数组：devices保存的对象是ACUserDevice的对象
 */
+ (void)listDevicesWithStatusFrom:(NSInteger)offset
                            limit:(NSInteger)limit
                         callback:(void(^)(NSArray<ACUserDevice *> *devices,NSError *error))callback;

/**
 *  获取用户绑定设备的总数
 *  @discussion  可以通过ACProductManager当中的接口获取产品相关信息
 *  @param subDomain    子域
 *  @param callback     结果回调
 */
+ (void)getDeviceCountInSubDomain:(NSString *)subDomain
                         callback:(void(^)(NSInteger count,NSError *error))callback;

/**
 *  获取用户列表
 *
 *  @param deviceId 设备唯一标识
 *  @param callback 数组：users保存的对象是ACBindUser的对象
 */
+ (void)listUsersWithSubDomain:(NSString *)subDomain
                      deviceId:(NSInteger)deviceId
                     calllback:(void(^)(NSArray *users,NSError *error))callback;

/**
 *  绑定设备
 *
 *  @param physicalDeviceId 设备物理ID
 *  @param name                    设备名称
 *  @param callback         回调 deviceId 设备的逻辑Id
 */
+ (void)bindDeviceWithSubDomain:(NSString *)subDomain
               physicalDeviceId:(NSString *)physicalDeviceId
                           name:(NSString *)name
                       callback:(void(^)(ACUserDevice *userDevice,NSError *error))callback;

/**
 * 修改设备扩展属性
 */
+ (void)setDeviceProfileWithSubDomain:(NSString *)subDomain
                              deviceId:(NSInteger)deviceId
                               profile:(ACObject *)profile
                              callback:(void (^) (NSError *error))callback;

/**
 * 获取设备扩展属性
 */
+ (void)getDeviceProfileWithSubDomain:(NSString*)subDomain
                              deviceId:(NSInteger)deviceId
                              callback:(void (^) (ACObject*profile, NSError *error))callback;

/**
 *  根据分享码 绑定设备
 *
 *  @param shareCode        分享码
 *  @param callback         回调 ACUserDevice 设备的对象
 */
+ (void)bindDeviceWithShareCode:(NSString *)shareCode
                       callback:(void(^)(ACUserDevice *userDevice,NSError *error))callback;

/**
 *  根据账户绑定设备
 *
 *  @param subDomain 子域
 *  @param deviceId  设备ID
 *  @param account     电话号码
 */
+ (void)bindDeviceWithUserSubdomain:(NSString *)subDomain
                           deviceId:(NSInteger)deviceId
                            account:(NSString *)account
                           callback:(void(^)(NSError *error))callback;
/**
 *  解绑设备
 *
 *  @param subDomain    子域名称
 *  @param deviceId     设备唯一标识
 */
+ (void)unbindDeviceWithSubDomain:(NSString *)subDomain
                         deviceId:(NSInteger)deviceId
                         callback:(void(^)(NSError *error))callback;


/**
 *  管理员取消 某个用户的绑定  （管理员接口）
 *
 *  @param subDomain 子域
 *  @param userId    用户ID
 *  @param deviceId  设备逻辑ID
 *  @param callback  回调
 */
+ (void)unbindDeviceWithUserSubDomain:(NSString *)subDomain
                               userId:(NSInteger)userId
                             deviceId:(NSInteger)deviceId
                             callback:(void(^)(NSError *error))callback;


/**
 *  设备管理员权限转让 （管理员接口）
 *
 *  @param subDomain    子域名称
 *  @param deviceId     设备逻辑ID
 *  @param userId       新的管理员ID
 */
+ (void)changeOwnerWithSubDomain:(NSString *)subDomain
                        deviceId:(NSInteger)deviceId
                          userId:(NSInteger)userId
                        callback:(void(^)(NSError *error))callback;
/**
 *  更换物理设备 （管理员接口）
 *
 *  @param subDomain        子域名称
 *  @param physicalDeviceId 设备物理ID
 *  @param deviceId         设备逻辑ID
 */
+ (void)changeDeviceWithSubDomain:(NSString *)subDomain
                 physicalDeviceId:(NSString *)physicalDeviceId
                         deviceId:(NSInteger)deviceId
                         callback:(void(^)(NSError *error))callback;


/**
 *  修改设备名称 （管理员接口）
 *
 *  @param subDomain    子域名称
 *  @param deviceId     设备逻辑ID
 *  @param name         设备的新名称
 */
+ (void)changNameWithSubDomain:(NSString *)subDomain
                      deviceId:(NSInteger)deviceId
                          name:(NSString *)name
                      callback:(void(^)(NSError *error))callback;

/**
 * 获取分享码  （管理员接口）
 * @discussion      若已存在未过期二维码则返回原有二维码并更新timeout时间，若原有二维码已过期则返回新的二维码
 * @param subDomain 子域名称
 * @param deviceId  设备唯一标识
 * @param timeout   超时时间（秒）
 * @param callback  shareCode 分享码
 */
+ (void)fetchShareCodeWithSubDomain:(NSString *)subDomain
                           deviceId:(NSInteger)deviceId
                            timeout:(NSTimeInterval)timeout
                           callback:(void (^)(NSString *shareCode, NSError *error))callback;

/**
 * 获取分享码  （管理员接口）
 * @discussion      此接口会强制删除其他已生成的二维码，并返回新的二维码
 * @param subDomain 子域名称
 * @param deviceId  设备唯一标识
 * @param timeout   超时时间（秒）
 * @param callback  shareCode 分享码
 */
+ (void)regenerateShareCodeWithSubDomain:(NSString *)subDomain
                                deviceId:(NSInteger)deviceId
                                 timeout:(NSTimeInterval)timeout
                                callback:(void (^)(NSString *shareCode, NSError *error))callback;

#pragma mark 设备查询控制接口

/**
*  查询设备绑定状态
*
*  @param subDomain        子域名称
*  @param physicalDeviceId 物理id
*  @param callback         是否被绑定
*/
+ (void)isDeviceBoundsWithSubDomain:(NSString *)subDomain
                   physicalDeviceId:(NSString *)physicalDeviceId
                           callback:(void (^)(BOOL isBounded, NSError *error))callback;
/**
 *  查询设备在线状态
 *
 *  @param subDomain        子域名称
 *  @param deviceId         设备逻辑ID
 *  @param physicalDeviceId 物理id
 *  @param callback         online  是否在线
 */
+ (void)isDeviceOnlineWithSubDomain:(NSString *)subDomain
                           deviceId:(NSInteger)deviceId
                   physicalDeviceId:(NSString *)physicalDeviceId
                           callback:(void(^)(Boolean online,NSError *error))callback;   


/**
 *  向设备发送消息
 *
 *  @param option            与设备交互的方式  1:仅通过局域网 2:仅通过云 3:通过云优先 4:通过局域网优先
 *  @param subDomain         子域名
 *  @param physicalDeviceId  设备物理ID
 *  @param msg               发送的消息
 *  @param callback          返回结果的监听
 */
+ (void)sendToDeviceWithOption:(ACDeviceCommunicationOption)option
                     SubDomain:(NSString *)subDomain
              physicalDeviceId:(NSString *)physicalDeviceId
                           msg:(ACDeviceMsg *)msg
                      callback:(void (^)(ACDeviceMsg *responseMsg, NSError *error))callback;

/**
 *  监听网络变化并且更新设备信息
 *
 *  @param timeout     超时时间
 *  @param subDomainId 子域ID
 *  @param callback    返回结果的回调
 */
+(void)networkChangeHanderWithTimeout:(NSInteger)timeout SubDomainId:(NSInteger)subDomainId  Callback:(void(^)(NSArray * deviceArray,NSError *error))callback;


/**
 * 更新设备的密钥accessKey
 *
 * @param subDomain 子域名，如djj（豆浆机）
 * @param deviceId  设备id（这里的id，是调用list接口返回的id，不是制造商提供的id）
 * @param callback  返回结果的监听回调
 */
+ (void)updateAccessKeyWithSubDomain:(NSString *)subDomain
                            deviceId:(NSInteger)deviceId
                            callback:(void(^)(NSError *error))callback;



#pragma mark - Deprecated

/**
 * 向设备发送消息
 *
 * @param option    与设备交互的方式  1:仅通过局域网 2:仅通过云 3:通过云优先 4:通过局域网优先
 * @param subDomain 子域名
 * @param deviceId  设备Id
 * @param msg       发送的消息
 * @param callback  返回结果的监听
 */
+ (void)sendToDeviceWithOption:(int)option
                     SubDomain:(NSString *)subDomain
                      deviceId:(NSInteger)deviceId
                           msg:(ACDeviceMsg *)msg
                      callback:(void (^)(ACDeviceMsg *responseMsg, NSError *error))callback ACDeprecated("请使用sendToDeviceWithOption:SubDomain:physicalDeviceId:msg:callback:方法") ;

/**
 * 获取分享码  （管理员接口）
 
 * @param subDomain 子域名称
 * @param deviceId  设备唯一标识
 * @param timeout   超时时间（秒）
 * @param callback  shareCode 分享码
 */
+ (void)getShareCodeWithSubDomain:(NSString *)subDomain
                         deviceId:(NSInteger)deviceId
                          timeout:(NSTimeInterval)timeout
                         callback:(void(^)(NSString *shareCode,NSError *error))callback ACDeprecated("请使用fetchShareCodeWithSubDomain:SubDomain:physicalDeviceId:msg:callback:方法");


@end
