//
//  TestsAndScreeningsViewController.h
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
//


/**
 Overview:
    Simple View Controller. Init with BaseNavigationController in app Delegate. Uses tracking from BaseViewController. No Xib
 */
#import "BaseViewController.h"

typedef void(^expandFinished)(BOOL);

@interface ToolsViewController : BaseViewController

@end
