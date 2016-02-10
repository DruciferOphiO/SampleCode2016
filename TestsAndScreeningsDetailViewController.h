//
//  TestsAndScreeningsDetailViewController.h
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
//

#import "BaseViewController.h"
#import "TestsAndScreeningsObjectModel.h"

/**
 Overview:
 Uses TestsAndScreeningsObjectModel for data and TestsAndScreeningsArticleView as a subview for article. Needs data model and location to start animation. View will start at given location, animated to the correct location, then other view will fade in. 
 */

@interface TestsAndScreeningsDetailViewController : BaseViewController<NSLayoutManagerDelegate>
{
    TestsAndScreeningsObjectModel *model;
    UIView *topView;
    UIImageView *mainImageView;
    UIScrollView *scrollView;
    UIImageView *topIconImageView;
    UITextView *topTitleTextView;
    UITextView *topMainTextView;
    BOOL shouldAnimateView;
    CGRect startFrame;
    int topViewFinalX;
}

/**
 @abstract:
 This method MUST be used to instantiate this class. A valid TestsAndScreeningsObjectModel and rect must be provided.
 @param _model: TestsAndScreeningsObjectModel must not be nil. Must contain data.
 @param _rect: CGRect must contain the origional location of the cell from TestsAndSCreeningsListViewController 

 */

-(id)initWithModel:(TestsAndScreeningsObjectModel*)_model withViewAtRect:(CGRect)_rect;

@end
