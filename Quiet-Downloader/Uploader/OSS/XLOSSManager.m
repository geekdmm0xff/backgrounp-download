//
//  XLOSSManager.m
//  CNGNetworkingDemo
//
//  Created by bltech on 17/4/28.
//  Copyright © 2017年 Bltech. All rights reserved.
//

#import "XLOSSManager.h"
#import "XLOSSTool.h"

NSString *const OSS_DOMAIN_DATA = @"http://unichat.oss-cn-shanghai.aliyuncs.com/";
NSString *const OSS_BUCKET_DATA = @"unichat";

NSString *const OSS_RAM_ACCESS_KEY = @"LTAIxSZwGkRL2XJX";
NSString *const OSS_RAM_SECRET_KEY = @"Rn5kxHaYOKv403mlNbaHSuqaNStgtX";

NSString *const OSS_PICTURE_DOMAIN_DATA = @"http://unichat.oss-cn-shanghai.aliyuncs.com/";
NSString *const OSS_PICTURE_BUCKET_DATA = @"unichat";


@implementation XLOSSManager

+ (NSMutableArray<NSString *> *)listObjectsWithPrefix:(NSString *)strPrefix {
    NSMutableArray<NSString *> *retSet = nil;
    NSString *params = [NSString stringWithFormat:@"?prefix=%@&delimiter=/&max-keys=1000", strPrefix];
    retSet = [XLOSSTool listObjectsWithDomain:OSS_DOMAIN_DATA
                                       bucket:OSS_BUCKET_DATA
                                    accessKey:OSS_RAM_ACCESS_KEY
                                    secretKey:OSS_RAM_SECRET_KEY
                                      ossAuth:YES
                                       params:params
                                   overlapped:YES];
    return retSet;
}

+ (NSMutableArray<NSString *> *)listObjectsWithPrefix:(NSString *)strPrefix andMarker:(NSString *)strMarker {
    NSMutableArray<NSString *> *retSet = nil;
    NSString *params = [NSString stringWithFormat:@"?prefix=%@&delimiter=/&max-keys=1000&marker=%@%@", strPrefix, strPrefix, strMarker];
    retSet = [XLOSSTool listObjectsWithDomain:OSS_DOMAIN_DATA
                                       bucket:OSS_BUCKET_DATA
                                    accessKey:OSS_RAM_ACCESS_KEY
                                    secretKey:OSS_RAM_SECRET_KEY
                                      ossAuth:YES
                                       params:params
                                   overlapped:YES];
    return retSet;
}

+ (BOOL)deleteObjects:(NSArray<NSString *> *)objs {
    [XLOSSTool deleteObjectsWithDomain:OSS_DOMAIN_DATA
                                bucket:OSS_BUCKET_DATA
                             accessKey:OSS_RAM_ACCESS_KEY
                             secretKey:OSS_RAM_SECRET_KEY
                               ossAuth:YES
                           listObjects:objs];
    return YES;
}

+ (XLOSSObject *)existObjectWithPath:(NSString *)strPath {
    XLOSSObject *obj = [XLOSSTool existObjectWithDomain:OSS_DOMAIN_DATA
                                                 bucket:OSS_BUCKET_DATA
                                              accessKey:OSS_RAM_ACCESS_KEY
                                              secretKey:OSS_RAM_SECRET_KEY
                                                ossAuth:YES
                                                    url:strPath];
    return obj;
}

+ (BOOL)downloadObjectFromSrcPath:(NSString *)strSrcPath toDstPath:(NSString *)strDstPath {
    XLOSSObject *obj = [XLOSSTool downloadFileWithDomain:OSS_DOMAIN_DATA
                                                  bucket:OSS_BUCKET_DATA
                                               accessKey:OSS_RAM_ACCESS_KEY
                                               secretKey:OSS_RAM_SECRET_KEY
                                                 ossAuth:YES
                                                     url:strSrcPath
                                                 dstFile:strDstPath
                                     andProgressCallBack:nil];
    return !obj ? NO : YES;
}

+ (XLOSSObject *)uploadObjectFromSrcPath:(NSString *)strSrcPath toDstPath:(NSString *)strDstPath {
    XLOSSObject *obj = [XLOSSTool uploadFileWithDomain:OSS_DOMAIN_DATA
                                                bucket:OSS_BUCKET_DATA
                                             accessKey:OSS_RAM_ACCESS_KEY
                                             secretKey:OSS_RAM_SECRET_KEY
                                               ossAuth:YES
                                                   url:strDstPath
                                              fileName:strSrcPath
                                   andProgressCallBack:nil];
    return obj;
}

+ (NSMutableURLRequest *)uploadPictureRequestWithPictureData:(NSData *)data andType:(OSSFileType)type fileMD5:(NSString *)fileMD5 {
    NSString *url = [PATH_CLOUD_PICTURE stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_hd.png", fileMD5]];
    NSMutableURLRequest *request = [XLOSSTool uploadFileRequestWithDomain:OSS_PICTURE_DOMAIN_DATA
                                                                   bucket:OSS_PICTURE_BUCKET_DATA
                                                                accessKey:OSS_RAM_ACCESS_KEY
                                                                secretKey:OSS_RAM_SECRET_KEY
                                                                  ossAuth:YES
                                                                      url:url
                                                                 fileData:data];
    return request;
}

@end
