//
//  Message.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSDate *createTime;
// ues for SQL
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSArray *mediaIDs;

// use for UI
@property (nonatomic, assign) CGFloat height;
@end

NS_ASSUME_NONNULL_END
