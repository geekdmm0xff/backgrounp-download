//
//  PublishViewController.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "PublishViewController.h"
#import "PublishCollectionViewCell.h"
#import "PhotoPickerHelper.h"
#import "MessageFlow.h"
#import "MBPlaceHolderTextView.h"
#import "ImagerUploadManager.h"

static const NSInteger kImageLimit = 20;

@interface PublishViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightLayout;
@property (weak, nonatomic) IBOutlet MBPlaceHolderTextView *textView;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) Message *message;
@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupTextView];
    [self setupCollectionView];
    [self loadDraft];
}

#pragma mark - Data

- (void)loadDraft {
    Message *message = [MessageFlow loadDraft];
    if (message) {
        self.textView.text = message.content;
        self.images = [message.images mutableCopy];
        [self refreshImageHeight:self.images];
        [self.imageCollectionView reloadData];
    }
    self.message = message;
}

#pragma mark - UI

- (void)setupTextView {
    self.textView.placeholder = @"请输入内容";
    [self.textView becomeFirstResponder];
}

- (void)setupNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(createAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
}

- (void)setupCollectionView {
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 2 * 20 - 3 * 5) / 4.0;
    
    [self.imageCollectionView registerNib:[UINib nibWithNibName:@"PublishCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(PublishCollectionViewCell.class)];
    self.collectionViewHeightLayout.constant = w;
    self.imageCollectionView.collectionViewLayout = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsZero;
        layout.itemSize = CGSizeMake(w, w);
        layout;
    });
    self.imageCollectionView.scrollEnabled = NO;
}

- (void)showAlert:(Message *)msg {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"将此次编辑保留" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"不保留" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        if (self.message) {
            [MessageFlow deleteDraft:self.message];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"保留" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull   action) {
        @strongify(self);
        if (self.message) {
            [MessageFlow updateDraft:self.message];
        } else {
            [MessageFlow saveMessageToDraft:msg];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVc addAction:cancelBtn];
    [alertVc addAction :sureBtn];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - Actions

- (void)createAction {
    // add feed
    Message *msg = [self generatorMessage];
    if (self.message) {
        [MessageFlow publishDraft:self.message];
    } else {
        if (msg) {
            msg.ID = [MessageFlow saveMessageToCache:msg];
        }
    }
    !self.callback ? : self.callback(msg);

    // 后端传图片
    [ImagerUploadManager commitMessageCallback:^(NSDictionary * response) {
        if (response.allKeys.count) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:0 error:0];
            NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [MBProgressHUD showSuccess:dataStr];
        }
    }];
    
    //
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction {
    Message *msg = [self generatorMessage];
    if (msg) {
        [self showAlert:msg];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showImagePicker {
    if (self.message) {
        @weakify(self);
        [PhotoPickerHelper chooseImageWithMaxImagesCount:kImageLimit - self.images.count selectedAssets:nil PickWithCompletion:^(NSArray<UIImage *> *photos, NSArray *assets) {
            @strongify(self);
            [self.images addObjectsFromArray:photos];
            [self refreshImageHeight:photos];
            [self.imageCollectionView reloadData];
        } from:self];
    } else {
        @weakify(self);
        [PhotoPickerHelper chooseImageWithMaxImagesCount:kImageLimit selectedAssets:self.assets PickWithCompletion:^(NSArray<UIImage *> *photos, NSArray *assets) {
            @strongify(self);
            self.images = [NSMutableArray arrayWithArray:photos];
            self.assets = [NSMutableArray arrayWithArray:assets];
            [self refreshImageHeight:photos];
            [self.imageCollectionView reloadData];
        } from:self];
    }
}

- (void)refreshImageHeight:(NSArray *)images {
    CGFloat w = ([UIScreen mainScreen].bounds.size.width - 2 * 20 - 3 * 5) / 4.0;
    self.collectionViewHeightLayout.constant = (w + 10) * (images.count / 4 + 1);
}

- (void)deletePhotoWithIndex:(NSInteger)index {
    if (self.assets.count > 0) {
        [self.assets removeObjectAtIndex:index];
    }
    [self.images removeObjectAtIndex:index];
    [self.imageCollectionView reloadData];
}

#pragma mark - Private Methods

- (Message *)generatorMessage {
    if (self.textView.text.length == 0 && self.images.count == 0) {
        return nil;
    }
    // new
    Message *msg = [Message new];
    msg.content = self.textView.text;
    msg.images = self.images;
    msg.createTime = [NSDate date];
    
    // copy
    self.message.content = msg.content;
    self.message.images = msg.images;
    self.message.createTime = msg.createTime;

    return msg;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.images.count < kImageLimit ? self.images.count + 1 : self.images.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PublishCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublishCollectionViewCell" forIndexPath:indexPath];
    @weakify(self);
    [cell setDeleteBlock:^{
        @strongify(self);
        [self deletePhotoWithIndex:indexPath.item];
    }];
    if (indexPath.item < self.images.count) { // show image
        cell.curImage = self.images[indexPath.item];
        cell.showDeleteTag = YES;
    } else {
        cell.curImage = nil;
        cell.showDeleteTag = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.images.count) { // add image
        [self showImagePicker];
    }
}

#pragma mark - Getter

- (NSMutableArray *)images {
    if (!_images) {
        _images = @[].mutableCopy;
    }
    return _images;
}

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = @[].mutableCopy;
    }
    return _assets;
}
@end
