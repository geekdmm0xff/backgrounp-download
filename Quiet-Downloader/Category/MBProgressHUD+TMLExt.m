//
//  MBProgressHUD+TMLExt.m
//  MIMEChat3
//
//  Created by Apple on 15/8/21.
//
//

#import "MBProgressHUD+TMLExt.h"

@implementation MBProgressHUD (TMLExt)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = @"上传成功";
    hud.detailsLabelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;

    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    // 1秒之后再消失
    [hud hide:YES afterDelay:3.0];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    [hud hide:YES afterDelay:30.0f];
    return hud;
}

+ (MBProgressHUD *)showMessageAbleUse:(NSString *)message toView:(UIView *)view; {
    MBProgressHUD *hud = [self showMessage:message toView:view];
    hud.userInteractionEnabled = NO;
    return hud;
}

+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error {
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message {
    return [self showMessage:message toView:nil];
}

+ (MBProgressHUD *)showMessageAbleUse:(NSString *)message; {
    MBProgressHUD *hud = [self showMessage:message toView:nil];
    hud.userInteractionEnabled = NO;
    return hud;
}

+ (void)hideHUDForView:(UIView *)view {
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    [self hideHUDForView:[[UIApplication sharedApplication].windows lastObject]];
}

+ (void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[[UIApplication sharedApplication] delegate] window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = message;
        hud.margin = 8;
//        hud.yOffset = [UIScreen mainScreen].bounds.size.height/2 - 100;
        hud.userInteractionEnabled = NO;
        [hud hide:YES afterDelay:2.0f];
    });
}

+ (void)showToast:(NSString *)message Offset:(CGFloat)offset {
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 8;
    hud.yOffset = offset;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:2.0f];
}
@end
