//
//  PublishViewController.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface PublishViewController : UIViewController
@property (nonatomic, copy) void (^callback)(Message *msg);
@end

NS_ASSUME_NONNULL_END
