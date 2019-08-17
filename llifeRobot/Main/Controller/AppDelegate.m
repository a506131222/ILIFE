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
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
#import "ZJMNavigationController.h"
#import "ZJMTabBarVC.h"
#import <CoreData/CoreData.h>
#import "InformationModel.h"
#import <CoreTelephony/CTCellularData.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NSBundle+Localizations.h"


#define INFORMATIONDATA @"Information"
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgrounTask;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation AppDelegate
{
    BOOL notificationPush;
    Byte cleanContent[1];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Jarvan._4_CoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"InformationData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"InformationData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            abort();
        }
    }
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
    [self setPreferredLanguage];
    _appRegion = ACLoudLibRegionChina;
    [ACloudLib setMode:ACLoudLibModeRouter Region:_appRegion];
    [ACloudLib setMajorDomain:MAINDOMAIN majorDomainId:5479];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ZJMTabBarVC *tabBar = [[ZJMTabBarVC alloc]init];
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];
    NSLog(@"%@", [ACloudLib getMajorDomain]);
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = YES;
    keyboardManager.shouldResignOnTouchOutside = YES;
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    keyboardManager.enableAutoToolbar = YES;
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17];
    keyboardManager.keyboardDistanceFromTextField = 70.0f; // 输入框距离键盘的距离
    [[UIButton appearance] setExclusiveTouch:YES];
    [Bugly startWithAppId:@"945344c9c6"];
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

- (void)setPreferredLanguage
{
    // 设置默认语言
    NSArray *languages = [NSLocale preferredLanguages]; //系统偏好语言
    NSString *language = languages.firstObject;
    NSString *langua;
    if ([language hasPrefix:@"zh-Hans"]) {
        langua = @"zh-Hans";
    }else if ([language hasPrefix:@"es"]) {
        langua = @"es";
    }else{
        langua = @"en";
    }
    [NSBundle setLanguage:langua];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
 
    //切到后台定时器运行
    UIApplication *app = [UIApplication sharedApplication];
     self.backgrounTask = [app beginBackgroundTaskWithExpirationHandler:^{
         [[UIApplication sharedApplication] endBackgroundTask:self.backgrounTask];
         self.backgrounTask = UIBackgroundTaskInvalid;
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(applyToSystemForMoreTime) userInfo:nil repeats:YES];
     [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}
- (void)applyToSystemForMoreTime {
    NSLog(@"后台活动剩余时间 == %.02f",[UIApplication sharedApplication].backgroundTimeRemaining);
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 69.0) {
        [[UIApplication sharedApplication] endBackgroundTask:self.self.backgrounTask];
        self.backgrounTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.self.backgrounTask];
            self.self.backgrounTask = UIBackgroundTaskInvalid;
        }];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self getCurrentWifiName];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.timer != nil) {
        self.timer.fireDate = [NSDate distantFuture];
        [self.timer invalidate];
        self.timer = nil;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (NSString *)getCurrentWifiName{
  
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            _wifiName = [dict valueForKey:@"SSID"];
        }
    }
    CFRelease(myArray);
    
    return _wifiName;
}

@end
