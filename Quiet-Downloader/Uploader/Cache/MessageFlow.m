//
//  MessageFlow.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "MessageFlow.h"

@implementation MessageFlow

// 如果是草稿要更新状态
+ (NSInteger)saveMessageToCache:(Message *)message {
    // 1. insert message
    NSInteger messageID = [MessageDAL insertRecord:message];
    // 2. insert media
    NSMutableArray *arr = @[].mutableCopy;
    for (UIImage *img in message.images) {
        NSData *data = UIImageJPEGRepresentation(img, 0.8);
        [arr addObject:data];
    }
    NSString *mediaIds = [MediaDAL insertImages:arr messageID:messageID];
    // 4. update ids
    [MessageDAL updateIds:mediaIds fromID:messageID];
    return messageID;
}

// 保存草稿箱
+ (NSInteger)saveMessageToDraft:(Message *)message {
    NSInteger messageID = [self saveMessageToCache:message];
    [MessageDAL updateDraft:YES fromID:messageID];
    return messageID;
}

+ (NSArray *)loadMessages {
    NSArray *messages = [MessageDAL queryAllMessages];
    for (Message *msg in messages) {
        NSMutableArray *images = @[].mutableCopy;
        for (NSString *mediaID in msg.mediaIDs) {
            UIImage *image = [MediaDAL queryMediasWithMessageID:msg.ID mediaID:mediaID.integerValue];
            if (image) {
                [images addObject:image];
            }
        }
        if (images.count) {
            msg.images = images;
        }
    }
    return messages;
}

+ (Message *)loadDraft {
    Message *msg = [MessageDAL queryDraftMessage].firstObject;
    NSMutableArray *images = @[].mutableCopy;
    for (NSString *mediaID in msg.mediaIDs) {
        UIImage *image = [MediaDAL queryMediasWithMessageID:msg.ID mediaID:mediaID.integerValue];
        if (image) {
            [images addObject:image];
        }
    }
    if (images.count) {
        msg.images = images;
    }
    return msg;
}

+ (void)deleteDraft:(Message *)message {
    [MessageDAL deleteRecord:message.ID];
    for (NSString *mediaID in message.mediaIDs) {
        [MediaDAL deleteRecord:mediaID.integerValue];
    }
}

+ (void)updateDraft:(Message *)message {
    [self deleteDraft:message];
    [self saveMessageToDraft:message];
}

+ (void)publishDraft:(Message *)message {
    [MessageDAL updateDraft:NO fromID:message.ID];
}

+ (NSData *)img:(UIImage *)image dataWithCompression:(CGFloat)compression {
    return UIImageJPEGRepresentation(image, compression);
}

@end
