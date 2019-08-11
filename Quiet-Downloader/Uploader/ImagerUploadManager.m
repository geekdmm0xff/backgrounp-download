//
//  ImagerUploadManager.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/8.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import "ImagerUploadManager.h"
#import "XLOSSManager.h"
#import "NSData+Category.h"
#import "XLOSSTool.h"

@interface ImagerUploadManager ()
@end

@implementation ImagerUploadManager

+ (instancetype)sharedInstance {
    static ImagerUploadManager *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [ImagerUploadManager new];
    });
    return ins;
}

+ (void)serverRun {
    [[MessageDBUtil sharedInstance] openDB];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @weakify(self);
        [[NetworkCheckHelper shareInstance] checkNetworkWithBlock:^(BOOL haveNetwork) {
            @strongify(self);
            if (haveNetwork) {
                [self commitMessageCallback:^(NSDictionary * response) {
                    if (response.allKeys.count) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:0 error:0];
                        NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [MBProgressHUD showSuccess:dataStr];
                    }
                }];
            }
        }];
    });
}

+ (void)commitMessageCallback:(void (^)(NSDictionary *))callback {
    if (![NetworkCheckHelper isConnected]) {
        return;
    }
    NSArray *messages = [MessageDAL queryAllMessages];
    for (Message *msg in messages) {
        [self addGroupTasks:msg callback:callback];
    }
}

+ (void)addGroupTasks:(Message *)message
             callback:(void (^)(NSDictionary *))callback {
    dispatch_group_t requestGroup = dispatch_group_create();
    
    NSMutableDictionary *map = @{}.mutableCopy;
    map[@"title"] = message.content;
    map[@"images"] = @[].mutableCopy;

    for (NSString *mediaID in message.mediaIDs) {
        dispatch_group_enter(requestGroup);
        
        NSData *data = [MediaDAL queryMediasDataWithMessageID:message.ID mediaID:mediaID.integerValue];
        if (!data) {
            dispatch_group_leave(requestGroup);
            return;
        }
        
        NSMutableURLRequest *request = [XLOSSManager uploadPictureRequestWithPictureData:data andType:OSSFileTypePictureHD fileMD5:[data md5String]];
        NSURLSessionUploadTask *task = [[XLOSSTool sharedAFURLSessionManager] uploadTaskWithRequest:request fromData:data progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (!error) {
                [MediaDAL deleteRecord:mediaID.integerValue];
                [map[@"images"] addObject:request.URL.absoluteString];
            } else {
                NSLog(@"%@", error);
            }
            dispatch_group_leave(requestGroup);
        }];
        [task resume];
    }
    
    dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{
        [MessageDAL deleteRecord:message.ID];
        !callback ? : callback(map);
    });
}

@end
