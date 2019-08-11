//
//  MessageTableViewCell.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "ImageCollectionViewCell.h"
#import "TextUtil.h"

@interface MessageTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightLayout;

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupCollectionView];
}

- (void)setupCollectionView {
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 2 * 20 - 3 * 5) / 4.0;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(ImageCollectionViewCell.class)];
    /// todo 计算高度
    self.imageHeightLayout.constant = w;
    self.collectionView.collectionViewLayout = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(w, w);
        layout;
    });
    self.collectionView.scrollEnabled = NO;
}

- (void)setMessage:(Message *)message {
    _message = message;
    self.contentLabel.text = message.content;
    
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 2 * 20 - 3 * 5) / 4.0;
    self.imageHeightLayout.constant = message.images ? (w + 10) * ((message.images.count - 1)/ 4 + 1) : 0;
    [self.collectionView reloadData];
}

+ (CGFloat)calcCellHeight:(Message *)message {
    static CGFloat margin = 20.f;
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 2 * 20 - 3 * 5) / 4.0;

    CGFloat height = 0;
    height += margin;
    height += TextHeight(message.content, 17.f, [UIScreen mainScreen].bounds.size.width - margin * 2);
    height += message.images ? (w + 10) * ((message.images.count - 1)/ 4 + 1) : 0;;
    height += margin;
    
    return height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.message.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    cell.image = self.message.images[indexPath.row];
    return cell;
}

@end
