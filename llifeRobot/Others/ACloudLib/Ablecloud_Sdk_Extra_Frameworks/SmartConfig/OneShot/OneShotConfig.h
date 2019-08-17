//
// OneShotConfig.h
// OneShotConfig
//
//  Created by codebat on 15/1/22.
//  Copyright (c) 2015年 Winnermicro. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface OneShotConfig : NSObject
+ (instancetype)getInstance;
/*返回：
 -1,表示网络状况不好，发送UDP包失败
 0,表示发送UDP包成功
 */
-(int)startConfig: (NSString*) ssid pwd: (NSString*) password;
/*停止当前UDP包发送
 */
-(void)stopConfig;


@end
