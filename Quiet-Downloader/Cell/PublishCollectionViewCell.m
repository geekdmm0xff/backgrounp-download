//
//  PublishCollectionViewCell.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "PublishCollectionViewCell.h"

@interface PublishCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIButton *deleteTagButton;

@end

@implementation PublishCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.showDeleteTag = NO;
}

- (void)setCurImage:(id)curImage {
    _curImage = curImage;
    if (!curImage) {
        self.imageView.image = [UIImage imageNamed:@"bt_add"];
    } else {
        self.imageView.image = curImage;
    }
}

- (void)setShowDeleteTag:(BOOL)showDeleteTag {
    _showDeleteTag = showDeleteTag;
    self.deleteTagButton.hidden = !showDeleteTag;
}

- (IBAction)deleteTagButtonClicked:(id)sender {
    !self.deleteBlock ? : self.deleteBlock();
}

@end
