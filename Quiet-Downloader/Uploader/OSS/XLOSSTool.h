//
//  XLOSSTool.h
//  CNGNetworkingDemo
//
//  Created by GeekDuan on 2017/5/1.
//  Copyright © 2017年 Bltech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "XLOSSObject.h"

UIKIT_EXTERN NSString *const OSS_XML_NEXTMARKER;
UIKIT_EXTERN NSString *const OSS_XML_CONTENTS;
UIKIT_EXTERN NSString *const OSS_XML_KEY;

typedef BOOL(^ProgressCallBack)(int64_t nCurrent, int64_t nMax);

@interface XLOSSTool : NSObject

+ (AFURLSessionManager *)sharedAFURLSessionManager;

+ (XLOSSObject *)downloadFileWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl dstFile:(NSString *)strDstFile andProgressCallBack:(ProgressCallBack)cb;

+ (XLOSSObject *)uploadFileWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl fileName:(NSString *)strFileName andProgressCallBack:(ProgressCallBack)cb;

+ (XLOSSObject *)existObjectWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl;

+ (void)deleteObjectsWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth listObjects:(NSArray<NSString *> *)listObjects;

+ (NSMutableArray <NSString *> *)listObjectsWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth params:(NSString *)params overlapped:(BOOL)bOverlapped;

+ (NSMutableURLRequest *)uploadFileRequestWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl fileData:(NSData *)fileData;

@end
