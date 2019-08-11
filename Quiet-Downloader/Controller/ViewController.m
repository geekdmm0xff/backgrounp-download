//
//  ViewController.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/8.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "ViewController.h"
#import "XLOSSManager.h"
#import "PublishViewController.h"
#import "MessageTableViewCell.h"
#import "MessageFlow.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupNav];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"MessageTableViewCell"];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    cell.message = self.messages[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *msg = self.messages[indexPath.row];
    if (!msg.height) {
        msg.height = [MessageTableViewCell calcCellHeight:self.messages[indexPath.row]];
    }
    return msg.height;
}

#pragma mark - UI

- (void)setupNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStylePlain target:self action:@selector(publishAction)];
}

#pragma mark - Actions

- (void)publishAction {
    PublishViewController *vc = [PublishViewController new];
    @weakify(self);
    [vc setCallback:^(Message * _Nonnull msg) {
        @strongify(self);
        [self.messages addObject:msg];
        [self.tableView reloadData];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = @[].mutableCopy;
    }
    return _messages;
}

@end
