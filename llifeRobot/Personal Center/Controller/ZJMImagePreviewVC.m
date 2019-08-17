//
//  ZJMImagePreviewVC.m
//  llifeRobot
//
//  Created by 魏青青 on 2018/12/17.
//  Copyright © 2018年 ZJM. All rights reserved.
//

#import "ZJMImagePreviewVC.h"

@interface ZJMImagePreviewVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@end

@implementation ZJMImagePreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView1.image = self.image;
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
