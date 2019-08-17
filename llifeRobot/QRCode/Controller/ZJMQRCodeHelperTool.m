//  ZJMRCodeHelperTool.m
//ZJMQRCodeExample
//
//  Created by kingsic on 2017/8/17.
//  Copyright © 2017年 Sorgle. All rights reserved.
//

#import "ZJMQRCodeHelperTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZJMQRCodeHelperTool
/** 打开手电筒 */
+ (void)SG_openFlashlight {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    if ([captureDevice hasTorch]) {
        BOOL locked = [captureDevice lockForConfiguration:&error];
        if (locked) {
            captureDevice.torchMode = AVCaptureTorchModeOn;
            [captureDevice unlockForConfiguration];
        }
    }
}
/** 关闭手电筒 */
+ (void)SG_CloseFlashlight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}


@end
