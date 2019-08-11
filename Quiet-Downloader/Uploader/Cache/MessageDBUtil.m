//
//  MessageDBUtil.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "MessageDBUtil.h"

static NSString *const kDBName = @"MessageCache.db";

/**
 *  Message SQLs
 */
// Table
static NSString *const kCreateMessageTableSQL = @"create table if not exists message(id integer primary key autoincrement, userID char(128), mediaIDs text, content text, timeStamp char(64) not null, draft integer default 0, extraValue char(64));";
// Insert
static NSString *const kInsertMessageSQL = @"insert into message(userID, content, timeStamp) values(?,?,?);";
// Update
static NSString *const kUpdateMessageIDsSQL = @"update message set mediaIDs = ? where id = ?";
static NSString *const kUpdateMessageDraftSQL = @"update message set draft = ? where id = ?";

// Query
static NSString *const kGetMessageRecordSQL = @"select id,userID,mediaIDs,content,timeStamp from message where draft = 0";
static NSString *const kGetMessageDraftRecordSQL = @"select id,userID,mediaIDs,content,timeStamp from message where draft = 1";
// Delete
static NSString *const kDeleteMessageFromID = @"delete from message where id = ?";

/**
 *  Medias SQLs
 */
// Table
static NSString *const kCreateMediaTableSQL = @"create table if not exists media(id integer primary key autoincrement, messageID integer not null, data BLOB, type integer default 1, extra char(1024));";
// Index
static NSString *const kMediaDataDataIndexSQL = @"create index if not exists idx_media_data on media(data);";
// Query
static NSString *const kGetMediaRecordSQL = @"select data from media where id = ? and messageID = ?";
// Insert
static NSString *const kInsertMediaSQL = @"insert into media(messageID, data) values(?,?);";
// Delete
static NSString *const kDeleteMediaFromID = @"delete from media where id = ?";


@implementation MessageDBUtil

+ (instancetype)sharedInstance {
    static MessageDBUtil *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [MessageDBUtil new];
    });
    return ins;
}

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[FMDatabaseQueue alloc] initWithPath:[self dbPath]];
    }
    return self;
}

- (void)openDB {
    [self.queue inDatabase:^(FMDatabase *db) {
        // use for fitcloud
        [db executeUpdate:kCreateMessageTableSQL];
        // use for reminder
        [db executeUpdate:kCreateMediaTableSQL];
        [db executeUpdate:kMediaDataDataIndexSQL];

    }];
}

- (NSString *)dbPath {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *documents = [doc stringByAppendingPathComponent:kDBName];
    return documents;
}

@end

@implementation MessageDAL

/*
 static NSString *const kGetMessageRecordSQL = @"select id,userID,mediaIDs,content,timeStamp from message";
 */
+ (NSArray *)queryAllMessages {
    NSMutableArray *arr = @[].mutableCopy;
    
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:kGetMessageRecordSQL];
        while ([result next]) {
            int ID = [result intForColumn:@"id"];
            NSString *mediaIDs = [result stringForColumn:@"mediaIDs"];
            NSString *content = [result stringForColumn:@"content"];
            long long timeStamp = [result longLongIntForColumn:@"timeStamp"];
            
            Message *msg = [Message new];
            msg.content = content;
            msg.createTime = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            msg.mediaIDs = [mediaIDs componentsSeparatedByString:@","];
            msg.ID = ID;
            [arr addObject:msg];
        }
    }];
    return arr;
}

+ (NSArray *)queryDraftMessage {
    NSMutableArray *arr = @[].mutableCopy;
    
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:kGetMessageDraftRecordSQL];
        while ([result next]) {
            int ID = [result intForColumn:@"id"];
            NSString *mediaIDs = [result stringForColumn:@"mediaIDs"];
            NSString *content = [result stringForColumn:@"content"];
            long long timeStamp = [result longLongIntForColumn:@"timeStamp"];
            
            Message *msg = [Message new];
            msg.content = content;
            msg.createTime = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            msg.mediaIDs = [mediaIDs componentsSeparatedByString:@","];
            msg.ID = ID;
            [arr addObject:msg];
        }
    }];
    return arr;
}

+ (NSInteger)insertRecord:(Message *)message {
    __block NSInteger ID = -1;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:kInsertMessageSQL,
                   @"dmm",
                   message.content,
                   @((long long)message.createTime.timeIntervalSince1970).stringValue];
        if (success) {
            ID = db.lastInsertRowId;
        }
    }];
    return ID;
}

+ (BOOL)updateIds:(NSString *)ids fromID:(NSInteger)ID {
    __block BOOL success = NO;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:kUpdateMessageIDsSQL, ids, @(ID)];
    }];
    return success;
}

+ (BOOL)updateDraft:(BOOL)isDraft fromID:(NSInteger)ID {
    __block BOOL success = NO;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:kUpdateMessageDraftSQL, @(isDraft), @(ID)];
    }];
    return success;
}

+ (BOOL)deleteRecord:(NSInteger)ID {
    __block BOOL success = NO;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:kDeleteMessageFromID, @(ID)];
    }];
    return success;
}

@end

@implementation MediaDAL

+ (NSString *)insertImages:(NSArray *)images messageID:(NSInteger)messageID {
    NSMutableArray *ids = @[].mutableCopy;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        for (NSData *data in images) {
            [db executeUpdate:kInsertMediaSQL,
                       @(messageID),
                       data];
            [ids addObject:@(db.lastInsertRowId)];
        }
        [db commit];
    }];
    return [ids componentsJoinedByString:@","];
}

+ (BOOL)deleteRecord:(NSInteger)ID {
    __block BOOL success = NO;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:kDeleteMediaFromID, @(ID)];
    }];
    return success;
}

+ (UIImage *)queryMediasWithMessageID:(NSInteger)messageID mediaID:(NSInteger)mediaID {
    __block UIImage *image = nil;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:kGetMediaRecordSQL, @(mediaID), @(messageID)];
        while ([result next]) {
            NSData *data = [result dataForColumn:@"data"];
            image = [UIImage imageWithData:data];
        }
    }];
    return image;
}

+ (NSData *)queryMediasDataWithMessageID:(NSInteger)messageID mediaID:(NSInteger)mediaID {
    __block NSData *data = nil;
    [[MessageDBUtil sharedInstance].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:kGetMediaRecordSQL, @(mediaID), @(messageID)];
        while ([result next]) {
            data = [result dataForColumn:@"data"];
        }
    }];
    return data;
}

@end
