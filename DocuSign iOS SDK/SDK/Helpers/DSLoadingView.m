//
//  DSLoadingView.m
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 9/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSLoadingView.h"

@implementation DSLoadingView


+ (instancetype)loadingView {
    DSLoadingView *loadingView;
    
    NSArray* nibViews =  [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    
    for (DSLoadingView *view in nibViews) {
        if ([view isKindOfClass:[DSLoadingView class]]) {
            loadingView = view;
        }
    }
    return loadingView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.HUDView.layer.cornerRadius = 10;
    self.HUDView.layer.masksToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.frame = newSuperview.bounds;
}

@end
