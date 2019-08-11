//
//  PhotoPickerHelper.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "PhotoPickerHelper.h"
#import "TZImagePickerController.h"

@implementation PhotoPickerHelper
+ (void)chooseImageWithMaxImagesCount:(NSInteger)maxImageCount selectedAssets:(nullable NSMutableArray *)selectedAssets PickWithCompletion:(ChooseImages)completion from:(UIViewController *)vc {
    
    TZImagePickerController* imagePickerController = [[TZImagePickerController alloc]initWithMaxImagesCount:maxImageCount delegate:nil];
    //默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
    //    imagePickerController.photoWidth = photoWidth;
    imagePickerController.selectedAssets = selectedAssets;
    imagePickerController.allowPickingVideo = NO;
    imagePickerController.allowPickingOriginalPhoto = NO;
    
    [imagePickerController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        completion(photos, assets);
    }];
    [vc.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}
@end
