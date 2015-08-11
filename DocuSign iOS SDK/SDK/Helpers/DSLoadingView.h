//
//  DSLoadingView.h
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 9/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSLoadingView : UIView

@property (weak, nonatomic) IBOutlet UIVisualEffectView *HUDView;

+ (instancetype)loadingView;

@end
