//
//  NetworkCheckHelper.m
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/10.
//  Copyright © 2019 GeekDuan. All rights reserved.
//
#import <netinet/in.h>
#import "NetworkCheckHelper.h"
#import "AFNetworkReachabilityManager.h"

@interface NetworkCheckHelper ()
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation NetworkCheckHelper

+ (NetworkCheckHelper*)shareInstance {
    static NetworkCheckHelper* shareInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareInstance = [[NetworkCheckHelper alloc]init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _reachabilityManager = [AFNetworkReachabilityManager managerForDomain:@"www.baidu.com"];;
    }
    return self;
}

+ (BOOL)isConnected {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        return false;
    }
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}


- (void)checkNetworkWithBlock:(HaveNetworkBlock)haveNetworkBlock {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                !haveNetworkBlock ? : haveNetworkBlock(YES);
                break;
            default:
                !haveNetworkBlock ? : haveNetworkBlock(NO);
                break;
        }
    }];
}

@end
