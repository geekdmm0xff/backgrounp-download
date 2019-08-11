//
//  MBPlaceHolderTextView.h
//  MyBaby
//
//  Created by apple on 2017/6/23.
//  Copyright © 2017年 BlazeLoogTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kInputTextHeightMax 260
#define kInputTextHeightMin 20

@interface MBPlaceHolderTextView : UITextView
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, assign) NSInteger type;// 1为输入框 0为其他

- (void)textChanged:(NSNotification *)notification;
@end
