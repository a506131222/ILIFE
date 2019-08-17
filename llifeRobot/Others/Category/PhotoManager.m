//
//  PhotoManager.m
//  DisableOtherAudioPlaying
//
//  Created by vedon on 18/9/13.
//  Copyright (c) 2013 com.vedon. All rights reserved.
//

#import "PhotoManager.h"


@implementation PhotoManager
@synthesize camera;
@synthesize pickingImageView;
@synthesize configureBlock;

+(PhotoManager *)shareManager
{
    static PhotoManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PhotoManager alloc]init];
    });
    return manager;
}

-(id)init
{
    self = [super init];
    if (self) {
        isSaveToLibrary = NO;
        [self initCamera];
        [self initlizationPickImageView];
    }
    return  self;
}

-(void)initCamera
{
    camera = [[UIImagePickerController alloc] init];
    camera.delegate = self;
    camera.allowsEditing = YES;
    isSaveToLibrary = NO;
    qualityNum = 3;
    //检查摄像头是否支持摄像机模式
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
//        camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        NSLog(@"Camera not exist");
        return;
    }
    
    //仅对视频拍摄有效
    switch (qualityNum) {
        case 0:
            camera.videoQuality = UIImagePickerControllerQualityTypeHigh;
            break;
        case 1:
            camera.videoQuality = UIImagePickerControllerQualityType640x480;
            break;
        case 2:
            camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
            break;
        case 3:
            camera.videoQuality = UIImagePickerControllerQualityTypeLow;
            break;
        default:
            camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
            break;
    }
    
}

-(void)initlizationPickImageView
{
    __block NSUInteger blockSourceType = 0;
    if (pickingImageView) {
        pickingImageView = nil;
    }
    pickingImageView= [[UIImagePickerController alloc] init];
    //相册
    blockSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickingImageView.delegate = self;
    
    pickingImageView.allowsEditing = YES;
    
    pickingImageView.sourceType = blockSourceType;
    
}

#pragma  mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if (kSystemVersion.floatValue >9.0) {
        [self prefersStatusBarHidden];
        
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    /* 此处info 有六个可选类型
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    
    if(self.configureBlock)
    {
        self.configureBlock(image);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancle it");
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}


-(UIImage *)getPreViewImg:(NSURL *)url
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    //截取视频第一帧的图片
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}


@end
