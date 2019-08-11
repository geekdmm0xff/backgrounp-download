//
//  NetworkCheckHelper.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/10.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HaveNetworkBlock)(BOOL haveNetwork);

NS_ASSUME_NONNULL_BEGIN

@interface NetworkCheckHelper : NSObject
+ (NetworkCheckHelper*)shareInstance;
+ (BOOL)isConnected;
- (void)checkNetworkWithBlock:(HaveNetworkBlock) haveNetworkBlock;
@end

NS_ASSUME_NONNULL_END
