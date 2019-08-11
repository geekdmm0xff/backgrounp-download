//
//  MBProgressHUD+TMLExt.h
//  MIMEChat3
//
//  Created by Apple on 15/8/21.
//
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (TMLExt)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessageAbleUse:(NSString *)message toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessageAbleUse:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

+ (void)showToast:(NSString *)message;
+ (void)showToast:(NSString *)message Offset:(CGFloat)offset;

+ (void)showSystemAlert:(NSString *)message;

@end
