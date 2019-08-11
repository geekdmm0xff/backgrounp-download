//
//  MBPlaceHolderTextView.m
//  MyBaby
//
//  Created by apple on 2017/6/23.
//  Copyright © 2017年 BlazeLoogTechnologies. All rights reserved.
//

#import "MBPlaceHolderTextView.h"

@interface MBPlaceHolderTextView()
@property (nonatomic, strong) UILabel *placeHolderLabel;
@end

@implementation MBPlaceHolderTextView

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0.25;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initUI];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _placeholder = @"";
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.textContainerInset = UIEdgeInsetsZero;
    
    _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.bounds.size.width - 10, 18)];
    _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _placeHolderLabel.font = self.font;
    _placeHolderLabel.backgroundColor = [UIColor clearColor];
    _placeHolderLabel.textColor = self.placeholderColor;
    _placeHolderLabel.alpha = 0;
    [self addSubview:_placeHolderLabel];
    
    _placeHolderLabel.text = self.placeholder;
    [self sendSubviewToBack:_placeHolderLabel];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _placeHolderLabel.text = self.placeholder;
    if (_placeholder && _placeholder.length > 0) {
        _placeHolderLabel.alpha = [[self text] length] > 0 ? 0 : 1;
    } else {
        _placeHolderLabel.alpha = 0;
    }
}

- (void)textChanged:(NSNotification *)notification {
    if (_placeholder.length > 0) {
        [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
            if ([[self text] length] > 0) {
                _placeHolderLabel.alpha = 0;
            } else {
                _placeHolderLabel.alpha = 1;
            }
        }];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

// 控制偏移
- (void)setContentOffset:(CGPoint)contentOffset {
    if (_type == 1 && self.contentSize.height < kInputTextHeightMax) {
        return;
    }
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (_type == 1 && self.contentSize.height < kInputTextHeightMax) {
        return;
    }
    [super setContentOffset:contentOffset animated:animated];
}

@end
