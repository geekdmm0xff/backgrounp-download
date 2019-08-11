//
//  XLOSSTool.m
//  CNGNetworkingDemo
//
//  Created by GeekDuan on 2017/5/1.
//  Copyright © 2017年 Bltech. All rights reserved.
//

#import "XLOSSTool.h"
#import <CommonCrypto/CommonHMAC.h>
#import "XMLDictionary.h"

#define OSS_AF_URL_SESSION_MANAGER [XLOSSTool sharedAFURLSessionManager]
#define OSS_NS_FILE_MANAGER [NSFileManager defaultManager]

NSString *const OSS_XML_NEXTMARKER = @"NextMarker";
NSString *const OSS_XML_CONTENTS   = @"Contents";
NSString *const OSS_XML_KEY        = @"Key";

NSString *getGMTTime() {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    return [dateFormatter stringFromDate:[NSDate date]];
}


NSString *HmacSHA1Encrypt(NSString *strText, NSString *strKey) {
    NSData *data = [strText dataUsingEncoding:NSASCIIStringEncoding];
    CCHmacContext context;
    const char *keyCString = [strKey cStringUsingEncoding:NSASCIIStringEncoding];
    CCHmacInit(&context, kCCHmacAlgSHA1, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);
    unsigned char digestRaw[CC_SHA1_DIGEST_LENGTH];
    NSInteger digestLength = CC_SHA1_DIGEST_LENGTH;
    CCHmacFinal(&context, digestRaw);
    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];
    NSUInteger length = [digestData length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *input  = (uint8_t *)[digestData bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0) & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}


NSString *getSignature(NSString *strAccessKey, NSString *strSecretKey, NSString *strSignatureData) {
    NSMutableString *strSignature = [NSMutableString string];
    [strSignature appendFormat:@"OSS %@:%@", strAccessKey, HmacSHA1Encrypt(strSignatureData, strSecretKey)];
    return strSignature;
}


NSUInteger lastIndexOf(NSString *str, NSString *subStr) {
    NSString *string = [NSString stringWithString:str];
    NSRange range = [string rangeOfString:subStr];
    NSUInteger lastIndex = range.location;
    if (lastIndex == NSNotFound) {
        return NSNotFound;
    }
    while (1) {
        string = [string substringFromIndex:(range.location + range.length)];
        range  = [string rangeOfString:subStr];
        if (range.location == NSNotFound) {
            break;
        } else {
            lastIndex = (lastIndex + range.location + subStr.length);
        }
    }
    return lastIndex;
}


NSData *buildDeleteObjects(NSArray<NSString *> *listObjects) {
    NSMutableString *str = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [str appendString:@"\n"];
    [str appendString:@"<Delete>\n"];
    [str appendString:@"  <Quiet>false</Quiet>\n"];
    for (NSString *key in listObjects) {
        [str appendString:@"  <Object>\n"];
        [str appendFormat:@"    <Key>%@</Key>\n", key];
        [str appendString:@"  </Object>\n"];
    }
    [str appendString:@"</Delete>\n"];
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

NSString *getMD5Bytes(NSData *srcData) {
    if (!srcData) {
        return nil;
    }
    NSString *srcStr = [[NSString alloc] initWithData:srcData encoding:NSUTF8StringEncoding];
    const char *cStr = [srcStr UTF8String];
    Byte result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSData *md5Data = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return [md5Data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@implementation XLOSSTool

+ (NSMutableURLRequest *)uploadFileRequestWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl fileData:(NSData *)fileData {
    NSString *urlStr = bOSSAuth ? [NSString stringWithFormat:@"%@%@", strDomain, strUrl] : [NSString stringWithFormat:@"%@", strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)fileData.length] forHTTPHeaderField:@"Content-Length"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"PUT\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendString:@"image/png\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendFormat:@"/%@/", strBucket];
        [tmpStr appendString:strUrl];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    return request;
}

+ (XLOSSObject *)downloadFileWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl dstFile:(NSString *)strDstFile andProgressCallBack:(ProgressCallBack)cb {
    NSString *urlStr = bOSSAuth ? [NSString stringWithFormat:@"%@%@", strDomain, strUrl] : [NSString stringWithFormat:@"%@", strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"GET\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendFormat:@"/%@/", strBucket];
        [tmpStr appendString:strUrl];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block XLOSSObject *obj = nil;
    NSURLSessionDownloadTask *dowloadTask = [OSS_AF_URL_SESSION_MANAGER.session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpURLResponse.statusCode;
        if (statusCode == 200) {
            NSMutableArray *dstPaths = [NSMutableArray arrayWithArray:[strDstFile componentsSeparatedByString:@"/"]];
            [dstPaths removeLastObject];
            NSString *dstDir = [dstPaths componentsJoinedByString:@"/"];
            if (![OSS_NS_FILE_MANAGER fileExistsAtPath:dstDir]) {
                [OSS_NS_FILE_MANAGER createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *dstPath = [dstDir stringByAppendingPathComponent:httpURLResponse.suggestedFilename];
            BOOL isDeleteFailed = NO;
            if ([OSS_NS_FILE_MANAGER fileExistsAtPath:dstPath]) {
                isDeleteFailed = ![OSS_NS_FILE_MANAGER removeItemAtPath:dstPath error:nil];
            }
            if (!isDeleteFailed) {
                NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
                [OSS_NS_FILE_MANAGER moveItemAtURL:location toURL:dstURL error:nil];
                
                obj = [[XLOSSObject alloc] init];
                obj.key  = strUrl;
                obj.Etag = [httpURLResponse.allHeaderFields objectForKey:@"Etag"];
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [dowloadTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    return obj;
}

+ (XLOSSObject *)uploadFileWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl fileName:(NSString *)strFileName andProgressCallBack:(ProgressCallBack)cb {
    NSString *urlStr = bOSSAuth ? [NSString stringWithFormat:@"%@%@", strDomain, strUrl] : [NSString stringWithFormat:@"%@", strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"PUT"];
    NSData *fileData = [NSData dataWithContentsOfFile:strFileName];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)fileData.length] forHTTPHeaderField:@"Content-Length"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"PUT\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendString:@"application/octet-stream\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendFormat:@"/%@/", strBucket];
        [tmpStr appendString:strUrl];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block XLOSSObject *obj = nil;
    NSURLSessionUploadTask *uploadTask = [OSS_AF_URL_SESSION_MANAGER.session uploadTaskWithRequest:request fromData:fileData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpURLResponse.statusCode;
        if (statusCode == 200) {
            obj = [[XLOSSObject alloc] init];
            obj.key  = strUrl;
            obj.Etag = [httpURLResponse.allHeaderFields objectForKey:@"Etag"];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [uploadTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    return obj;
}

+ (XLOSSObject *)existObjectWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth url:(NSString *)strUrl {
    NSString *urlStr = bOSSAuth ? [NSString stringWithFormat:@"%@%@", strDomain, strUrl] : [NSString stringWithFormat:@"%@", strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"HEAD"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"HEAD\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendFormat:@"/%@/", strBucket];
        [tmpStr appendString:strUrl];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block XLOSSObject *obj = nil;
    NSURLSessionDataTask *dataTask = [OSS_AF_URL_SESSION_MANAGER.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpURLResponse.statusCode;
        if (statusCode == 404) {
            
        } else if (statusCode == 200) {
            obj = [[XLOSSObject alloc] init];
            obj.key  = strUrl;
            obj.Etag = [httpURLResponse.allHeaderFields objectForKey:@"Etag"];
        } else {
            
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    return obj;
}

+ (void)deleteObjectsWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth listObjects:(NSArray<NSString *> *)listObjects {
    NSUInteger count = listObjects.count;
    if (count == 0) {
        return;
    }
    for (NSUInteger i = 0; i < count; i += 1000) {
        NSUInteger toIndex = count < i + 1000 ? count : i + 1000;
        NSMutableArray<NSString *> *mutableList = [NSMutableArray array];
        for (NSUInteger j = i; j < toIndex; j++) {
            [mutableList addObject:listObjects[j]];
        }
        NSArray *list = [NSArray arrayWithArray:mutableList];
        [self deleteObjectsInternalWithDomain:strDomain bucket:strBucket accessKey:strAccessKey secretKey:strSecretKey ossAuth:bOSSAuth listObjects:list];
    }
}

+ (void)deleteObjectsInternalWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth listObjects:(NSArray<NSString *> *)listObjects {
    NSString *urlStr = [NSString stringWithFormat:@"%@?delete", strDomain];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    NSData *xml = buildDeleteObjects(listObjects);
    NSString *strMD5Base64 = getMD5Bytes(xml);
    [request setValue:strMD5Base64 forHTTPHeaderField:@"Content-MD5"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)strMD5Base64.length] forHTTPHeaderField:@"Content-Length"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"POST\n"];
        [tmpStr appendFormat:@"%@\n", strMD5Base64];
        [tmpStr appendString:@"application/octet-stream\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendString:@""];
        [tmpStr appendFormat:@"/%@/?delete", strBucket];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionUploadTask *uploadTask = [OSS_AF_URL_SESSION_MANAGER.session uploadTaskWithRequest:request fromData:xml completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpURLResponse.statusCode;
        if (statusCode == 200) {
            
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [uploadTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
}

+ (NSMutableArray<NSString *> *)listObjectsWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth params:(NSString *)params overlapped:(BOOL)bOverlapped {
    NSMutableArray<NSString *> *retSet = [NSMutableArray array];
    NSString *nextMarker = nil;
    while (YES) {
        NSString *str = params;
        if (nextMarker) {
            if ([str containsString:@"&marker="]) {
                str = [str substringWithRange:NSMakeRange(0, lastIndexOf(str, @"&marker"))];
            }
            str = [NSString stringWithFormat:@"%@&marker=%@", str, nextMarker];
        }
        nextMarker = nil;
        NSMutableArray<NSString *> *set = [self listObjectsInternalWithDomain:strDomain bucket:strBucket accessKey:strAccessKey secretKey:strSecretKey ossAuth:bOSSAuth params:str nextMarker:&nextMarker];
        [retSet addObjectsFromArray:set];
        if (!nextMarker) {
            break;
        }
    }
    return retSet;
}

+ (NSMutableArray<NSString *> *)listObjectsInternalWithDomain:(NSString *)strDomain bucket:(NSString *)strBucket accessKey:(NSString *)strAccessKey secretKey:(NSString *)strSecretKey ossAuth:(BOOL)bOSSAuth params:(NSString *)params nextMarker:(NSString **)nextMarker {
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", strDomain, params];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    if (bOSSAuth) {
        NSString *strDate = getGMTTime();
        NSString *strCalc = nil;
        
        NSMutableString *tmpStr = [NSMutableString string];
        [tmpStr appendString:@"GET\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendString:@"\n"];
        [tmpStr appendFormat:@"%@\n", strDate];
        [tmpStr appendString:@""];
        [tmpStr appendFormat:@"/%@/", strBucket];
        
        strCalc = [NSString stringWithString:tmpStr];
        
        NSString *strSignature = getSignature(strAccessKey, strSecretKey, strCalc);
        [request setValue:strDate forHTTPHeaderField:@"Date"];
        [request setValue:strSignature forHTTPHeaderField:@"Authorization"];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSMutableArray<NSString *> *retSet = [NSMutableArray array];
    NSURLSessionDataTask *dataTask = [OSS_AF_URL_SESSION_MANAGER.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpURLResponse.statusCode;
        if (statusCode == 200) {
            retSet = [self parseListObjectsWithXMLDictionary:[NSDictionary dictionaryWithXMLData:data] andNextMarker:nextMarker];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    return retSet;
}

+ (NSMutableArray<NSString *> *)parseListObjectsWithXMLDictionary:(NSDictionary *)xml andNextMarker:(NSString **)nextMarker {
    NSMutableArray<NSString *> *retSet = [NSMutableArray array];
    *nextMarker = [xml objectForKey:OSS_XML_NEXTMARKER] ? : nil;
    id contents = [xml objectForKey:OSS_XML_CONTENTS];
    if ([contents isKindOfClass:[NSArray class]]) {
        for (NSDictionary *content in contents) {
            [retSet addObject:[content objectForKey:OSS_XML_KEY]];
        }
    } else if ([contents isKindOfClass:[NSDictionary class]]) {
        [retSet addObject:[contents objectForKey:OSS_XML_KEY]];
    }
    return retSet;
}

+ (AFURLSessionManager *)sharedAFURLSessionManager {
    static AFURLSessionManager *_sharedAFURLSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sharedAFURLSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    });
    return _sharedAFURLSessionManager;
}

@end
