//
//  PhotoPickerHelper.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ChooseImages)(NSArray<UIImage *> *photos, NSArray *assets);

@interface PhotoPickerHelper : NSObject
+ (void)chooseImageWithMaxImagesCount:(NSInteger)maxImageCount selectedAssets:(nullable NSMutableArray *)selectedAssets PickWithCompletion:(ChooseImages)completion from:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
