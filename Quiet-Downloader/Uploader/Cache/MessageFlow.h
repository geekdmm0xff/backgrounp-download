//
//  MessageFlow.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageFlow : NSObject

+ (NSInteger)saveMessageToCache:(Message *)message;
+ (NSInteger)saveMessageToDraft:(Message *)message;

+ (NSArray *)loadMessages;
+ (Message *)loadDraft;

+ (void)deleteDraft:(Message *)message;

+ (void)updateDraft:(Message *)message;

+ (void)publishDraft:(Message *)message;

@end

NS_ASSUME_NONNULL_END
