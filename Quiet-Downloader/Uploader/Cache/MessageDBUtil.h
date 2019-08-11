//
//  MessageDBUtil.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "Message.h"


NS_ASSUME_NONNULL_BEGIN

@interface MessageDBUtil : NSObject
@property (nonatomic, strong) FMDatabaseQueue *queue;
+ (instancetype)sharedInstance;
- (void)openDB;
- (NSString *)dbPath;
@end

@interface MessageDAL : NSObject
+ (NSInteger)insertRecord:(Message *)message;
+ (BOOL)updateIds:(NSString *)ids fromID:(NSInteger)ID;
+ (BOOL)updateDraft:(BOOL)isDraft fromID:(NSInteger)ID;
+ (BOOL)deleteRecord:(NSInteger)ID;
+ (NSArray *)queryAllMessages;
+ (NSArray *)queryDraftMessage;
@end

@interface MediaDAL : NSObject
+ (NSString *)insertImages:(NSArray *)images messageID:(NSInteger)messageID;
+ (BOOL)deleteRecord:(NSInteger)ID;
+ (UIImage *)queryMediasWithMessageID:(NSInteger)messageID mediaID:(NSInteger)mediaID;
+ (NSData *)queryMediasDataWithMessageID:(NSInteger)messageID mediaID:(NSInteger)mediaID;
@end

NS_ASSUME_NONNULL_END
