//
//  UIApplication+NetworkActivity.m
//  townWizard-ios
//
//  Created by John Doe on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"

static NSInteger activityCount = 0;
@implementation UIApplication (NetworkActivity)
- (void)showNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        if (activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:YES];
        }
        activityCount++;
    }
}
- (void)hideNetworkActivityIndicator {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    @synchronized ([UIApplication sharedApplication]) {
        activityCount--;
        if (activityCount <= 0) {
            [self setNetworkActivityIndicatorVisible:NO];
            activityCount=0;
        }    
    }
}

- (void)setActivityindicatorToZero {
    activityCount = 0;
    [self hideNetworkActivityIndicator];
}

@end