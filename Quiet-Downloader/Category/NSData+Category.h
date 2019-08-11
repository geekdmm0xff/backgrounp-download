//
//  NSData+Category.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/9.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Category)
/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)md5String;
@end

NS_ASSUME_NONNULL_END
