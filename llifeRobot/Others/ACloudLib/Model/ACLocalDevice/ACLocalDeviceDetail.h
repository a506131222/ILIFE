//
//  ACLocalDeviceDetail.h
//  AbleCloud
//
//  Created by fariel huang on 2016/12/1.
//  Copyright © 2016年 AbleCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACLocalDevice.h"

@interface ACLocalDeviceDetail : ACLocalDevice

/** 连接进行状态 */
@property (nonatomic, assign) NSInteger linkState;
/** wifi版本 */
@property (nonatomic, copy) NSString *wifiVersion;

@end
