//
//  PublishCollectionViewCell.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^VoidBlock)(void);

@interface PublishCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong, nullable) UIImage *curImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL showDeleteTag;
@property (nonatomic, copy) VoidBlock deleteBlock;
@end

NS_ASSUME_NONNULL_END
