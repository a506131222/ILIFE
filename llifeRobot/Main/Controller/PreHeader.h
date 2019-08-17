//
//  PreHeader.h
//  llifeRobot
//
//  Created by 张佳满 on 2017/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#ifndef PreHeader_h
#define PreHeader_h

#define BaseColor  [UIColor colorWithRed:0.0/255.0 green:178.0/255.0 blue:156.0/255.0 alpha:1]

#define Backgroundcolor  [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1]



#import "MJRefresh.h"
#import "PhotoManager.h"
#import "UIImage+Size.h"
#import "UIImageView+WebCache.h"
#import "FLAnimatedImage.h"
#import "UIView+Frame.h"
//获取设备的物理高度
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

//获取设备的物理宽度
#define SCREENWEIGHT [UIScreen mainScreen].bounds.size.width

#define imageViewScale   5.0

#define MAPWIDTH 1500
#define SlamPathRadio 224/100       //路径单点分辨率大小:slam单点分辨率大小
#define gridViewWidth   SCREENWEIGHT*5
#define gridViewHegith   SCREENHEIGHT*5
#define PointSize   5
/** 产品主域*/
#define  MAINDOMAIN @"china-ilife"

/** 产品子域 */
#define  X420SubDomain  @"ilifex420"
#define  X430SubDomain  @"zhiyitest"
#define  X660SubDomain  @"ilifex660"
#define  X610SubDomain  @"ilifex610"
#define  X620SubDomain  @"ilifex620"
#define  X782SubDomain  @"ilifex782"
#define  X785SubDomain  @"ilifex785"
#define  X786SubDomain  @"ilifex786"
#define  X787SubDomain  @"ilifex787"
#define  X790SubDomain  @"ilifex790"
#define  X800SubDomain  @"ilifex800"
#define  X900SubDomain  @"ilifex900"
#define  X910SubDomain  @"ilifex910"

/** 接口服务名称 */
#define  SearchCleanRealTime     @"searchCleanRealTime"
#define  SearchCleanRoadData     @"searchCleanRoadData"
#define  SearchCleanRealTimeMore @"searchCleanRealTimeMore"
#define  CleanRealTime           @"clean_realtime"
#define  SearchCleanRoadDataMore @"searchCleanRoadDataMore"

#define  BUGLY      @"6d8efb53ec"
#define messageType  @"ablecloud"
/** 意见反馈邮箱*/
#define feekBackMail @"telephoneNumber"
/** 意见反馈文字*/
#define feedBackText @"description"
/**意见反馈图片 */
#define  feekBackPictures @"pictures"

//ios系统版本
#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define kSystemVersion [[UIDevice currentDevice]systemVersion]
#define LINEWIDTH 3
#define FORBiDDENWIDTH 1
#define NUMBERIMARIWDTH 16
#define CONSTANTS 10

// 判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
// 判断iPhone4系列
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhone5系列
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhone6系列
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iphone6+系列
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneX
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPHoneXr
#define iPhoneXr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs
#define iPhoneXs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs Max
#define iPhoneXs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

#define HexColor(HexValue)   [UIColor colorWithRed:((float)((HexValue & 0xFF0000) >> 16))/255.0 green:((float)((HexValue & 0xFF00) >> 8))/255.0 blue:((float)(HexValue & 0xFF))/255.0 alpha:1.0]


//是否 是iPhoneX系列
#define isIphoneX_Series (SCREENWEIGHT >= 375.0f && SCREENHEIGHT >= 812.0f && ISiPhone)


//是否为iPhone X 系列  （消除Xcode10上警告）
#define isIphoneX_Series \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
//导航栏高度
#define NavBar_Height 44
//TabBar的高度
#define TabBar_Height  (isIphoneX_Series? 83 : 49)
//状态栏高度
#define Status_Height (isIphoneX_Series?44:20)

//底部 安全高度
#define Bottom_Safe_Height (isIphoneX_Series?34:0)

#define UmessageKEY @"5a1d022cf29d9851d30002fc"

#ifndef __OPTIMIZE__
#define NSLog(format, ...)  NSLog((@"\n文件名:%s" "  行号:%d" "\n[方法名:%s]" "\n打印结果:" format"\n  \n"), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,__FUNCTION__,  ##__VA_ARGS__)
#else
#define NSLog(...){}
#endif


#define TICK   CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define TOCK   NSLog(@"Time:%f", CFAbsoluteTimeGetCurrent() - start)


#define FONT_SIZE(size) ([UIFont systemFontOfSize:FontSize(size))

 
#define Weakself   __weak __typeof(self)weakSelf = self
#define StrongSelf __strong __typeof(weakSelf)strongSelf = weakSelf


#endif /* PreHeader_h */

