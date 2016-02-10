//
//  TestsAndScreeningsArticleView.h
//  WhatToExpect
//
//  Created by Andrew McKinley on 9/29/15.
//
//

#import <UIKit/UIKit.h>
#import "TestsAndScreeningsObjectModel.h"

/**
 Overview:
 Uses TestsAndScreeningsObjectModel for data. Uses autolayout for subviews. MUST SET CONTENT SIZE IN VIEW CONTOLLER */

@interface TestsAndScreeningsArticleView : UIView

/**
 @abstract:
 This method MUST be used to instantiate this class. A valid TestsAndScreeningsObjectModel  must be provided.
 @param theModel: TestsAndScreeningsObjectModel must not be nil. Must contain data.
 
 */

-(id)initWithModel:(TestsAndScreeningsObjectModel*)theModel;

@end
