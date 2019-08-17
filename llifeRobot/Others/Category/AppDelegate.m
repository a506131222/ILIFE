//
//  AppDelegate.m
//  llifeRobot
//
//  Created by Yannis on 16/8/17.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "AppDelegate.h"
#import "ZJMTabBarVC.h"
#import "ACloudLib.h"
#import "PreHeader.h"
#import  <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCellularData.h>
#import "IQKeyboardManager.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

-(NSMutableArray<ACUserDevice *>*)ownerDeviceList{
    if (_ownerDeviceList ==nil) {
        _ownerDeviceList = [NSMutableArray array];
    }
    return  _ownerDeviceList;
    
}
-(NSMutableArray *)deviceNameList{
   
    
    if (_deviceNameList == nil) {
        _deviceNameList = [NSMutableArray array];
        
    }
    return  _deviceNameList;
    
}
-(NSMutableArray *)deviceList{
    if (_deviceList ==nil) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [ACloudLib setMode:ACLoudLibModeTest Region:ACLoudLibRegionChina];
    
    [ACloudLib setMajorDomain:MAINDOMAIN majorDomainId:5479];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ZJMTabBarVC *tabBar = [[ZJMTabBarVC alloc]init];
    
    self.window.rootViewController = tabBar;
    
    [self.window makeKeyAndVisible];
    NSLog(@"%@", [ACloudLib getMajorDomain]);
    NSLog(@"%ld", [ACloudLib getMajorDomainId]);
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    
    keyboardManager.enable = YES;
    keyboardManager.shouldResignOnTouchOutside = YES;
    
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    
    keyboardManager.enableAutoToolbar = YES;
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17];
    
    keyboardManager.keyboardDistanceFromTextField = 60.0f; // 输入框距离键盘的距离
    [Bugly startWithAppId:BUGLY];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    //切到后台定时器运行
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//static void uncaughtExceptionHandler(NSException *exception) {
//    
//    NSLog(@"CRASH: %@", exception);
//    
//    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
//    
//    // Internal error reporting
//    
//}


@end
