//
//  ZJMUserAgreeVCViewController.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/12/15.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMUserAgreeVC.h"
#import <QuickLook/QuickLook.h>


@interface ZJMUserAgreeVC ()

@end

@implementation ZJMUserAgreeVC
{
    NSString *path;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    if (path==nil) {
//        return;
//    }
    if (_type==1) {
        NSString *languageCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
        if ([languageCode containsString:@"Han"]==YES) {
            path = [[NSBundle mainBundle] pathForResource:@"注册协议(中文)" ofType:@"pdf"];
        }else{
            //英文
            path = [[NSBundle mainBundle] pathForResource:@"注册协议(英文)" ofType:@"pdf"];
        }
    }else{
        NSString *languageCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
        
        if ([languageCode containsString:@"Han"]==YES) {
            path = [[NSBundle mainBundle] pathForResource:@"隐私政策协议(中文)" ofType:@"pdf"];
        }else{
            //英文
            path = [[NSBundle mainBundle] pathForResource:@"隐私政策协议(英文)" ofType:@"pdf"];
        }
    }
  
    NSURL *url = [NSURL fileURLWithPath:path];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREENWEIGHT, SCREENHEIGHT)];
    dispatch_async(dispatch_get_main_queue(), ^{
         [webView loadRequest:[NSURLRequest requestWithURL:url]];
    });
    
    [webView sizeToFit];
    
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
