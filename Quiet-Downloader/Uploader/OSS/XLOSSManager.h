//
//  XLOSSManager.h
//  CNGNetworkingDemo
//
//  Created by bltech on 17/4/28.
//  Copyright © 2017年 Bltech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PATH_CLOUD_PICTURE [NSString stringWithFormat:@"unichat"]

UIKIT_EXTERN NSString *const OSS_DOMAIN_DATA;
UIKIT_EXTERN NSString *const OSS_BUCKET_DATA;
UIKIT_EXTERN NSString *const OSS_RAM_ACCESS_KEY;
UIKIT_EXTERN NSString *const OSS_RAM_SECRET_KEY;

UIKIT_EXTERN NSString *const OSS_PICTURE_DOMAIN_DATA;
UIKIT_EXTERN NSString *const OSS_PICTURE_BUCKET_DATA;

@class XLOSSObject;

typedef NS_ENUM(NSUInteger, OSSFileType) {
    OSSFileTypeUnknown = 0,
    OSSFileTypePictureThum,
    OSSFileTypePictureHalfHD,
    OSSFileTypePictureHD,
};

@interface XLOSSManager : NSObject

+ (NSMutableArray<NSString *> *)listObjectsWithPrefix:(NSString *)strPrefix;
+ (NSMutableArray<NSString *> *)listObjectsWithPrefix:(NSString *)strPrefix andMarker:(NSString *)strMarker;
+ (BOOL)deleteObjects:(NSArray<NSString *> *)objs;
+ (XLOSSObject *)existObjectWithPath:(NSString *)strPath;
+ (BOOL)downloadObjectFromSrcPath:(NSString *)strSrcPath toDstPath:(NSString *)strDstPath;
+ (XLOSSObject *)uploadObjectFromSrcPath:(NSString *)strSrcPath toDstPath:(NSString *)strDstPath;

+ (NSMutableURLRequest *)uploadPictureRequestWithPictureData:(NSData *)data andType:(OSSFileType)type fileMD5:(NSString *)fileMD5;

@end
