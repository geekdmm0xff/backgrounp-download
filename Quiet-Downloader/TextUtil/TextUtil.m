//
//  TextUtil.m
//  HealthManager_Customer
//
//  Created by lzh on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "TextUtil.h"

@implementation TextUtil

+ (CGSize)calculateSizeWithString:(NSString*)aString font:(UIFont *)aFont constrainedToSize:(CGSize)aSize lineBreakMode:(NSLineBreakMode)aLineBreakMode
{
    CGSize returnSize = CGSizeZero;
    
    CGSize boundedSize = [aString boundingRectWithSize:aSize options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:aFont} context:nil].size;
    returnSize.width = ceilf(boundedSize.width);
    returnSize.height = ceilf(boundedSize.height);
    
    return returnSize;
}

+ (CGFloat)calculateHeightWithString:(NSString*)aString font:(UIFont *)aFont constrainedToSize:(CGSize)aSize lineBreakMode:(NSLineBreakMode)aLineBreakMode
{
    return [self calculateSizeWithString:aString font:aFont constrainedToSize:aSize lineBreakMode:aLineBreakMode].height;
}

+ (CGFloat)calculateWidthWithString:(NSString*)aString font:(UIFont*)aFont lineBreakMode:(NSLineBreakMode)aLineBreakMode
{
    
   return  [self calculateSizeWithString:aString font:aFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 1000) lineBreakMode:aLineBreakMode].width;
    
}


@end
