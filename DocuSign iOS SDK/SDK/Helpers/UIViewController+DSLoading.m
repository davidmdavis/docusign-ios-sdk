//
//  UIViewController+DSLoading.m
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 5/13/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "UIViewController+DSLoading.h"
#import <objc/runtime.h>
#import "DSLoadingView.h"

static char kLoadingViewKey;

@implementation UIViewController (DSLoading)

- (void)ds_showLoading {
    UIView *loadingView = [DSLoadingView loadingView];
    loadingView.alpha = 0;
    [self dsloading_associateValue:loadingView withKey:&kLoadingViewKey];
    UIView *viewToAddTo;
    if (self.navigationController) {
        viewToAddTo = self.navigationController.view;
    } else {
        viewToAddTo = self.view;
    }
    [viewToAddTo addSubview:loadingView];
    [viewToAddTo bringSubviewToFront:loadingView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         loadingView.alpha = 1;
                     }];
}

- (void)ds_hideLoading {
    UIView *loadingView = [self dsloading_associatedValueForKey:&kLoadingViewKey];
    [UIView animateWithDuration:0.3 animations:^{
        loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
    }];
    [self dsloading_associateValue:nil withKey:&kLoadingViewKey];
}

- (void)dsloading_associateValue:(id)value withKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)dsloading_associatedValueForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

@end
