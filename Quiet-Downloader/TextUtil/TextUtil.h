//
//  TextUtil.h
//  HealthManager_Customer
//
//  Created by lzh on 2017/12/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TextHeight(str,fontSize,constrainedWidth) [TextUtil calculateHeightWithString:str font:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(constrainedWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];

#define BoldTextHeight(str,fontSize,constrainedWidth) [TextUtil calculateHeightWithString:str font:[UIFont boldSystemFontOfSize:fontSize] constrainedToSize:CGSizeMake(constrainedWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];

#define TextWidth(str,fontSize) [TextUtil calculateWidthWithString:str font:[UIFont systemFontOfSize:fontSize] lineBreakMode:NSLineBreakByWordWrapping];

#define BoldTextWidth(str,fontSize) [TextUtil calculateWidthWithString:str font:[UIFont boldSystemFontOfSize:fontSize]  lineBreakMode:NSLineBreakByWordWrapping];

@interface TextUtil : NSObject

+ (CGSize)calculateSizeWithString:(NSString*)aString font:(UIFont *)aFont constrainedToSize:(CGSize)aSize lineBreakMode:(NSLineBreakMode)aLineBreakMode;

+ (CGFloat)calculateHeightWithString:(NSString*)aString font:(UIFont *)aFont constrainedToSize:(CGSize)aSize lineBreakMode:(NSLineBreakMode)aLineBreakMode;

+ (CGFloat)calculateWidthWithString:(NSString*)aString font:(UIFont*)aFont lineBreakMode:(NSLineBreakMode)aLineBreakMode;

+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr;

@end
