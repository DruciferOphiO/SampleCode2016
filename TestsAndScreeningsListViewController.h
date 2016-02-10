//
//  TestAndScreeningsListViewController.h
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
//

#import "BaseViewController.h"
#import "TestsAndScreeningsFacade.h"
#import "TestsAndScreeningsTableViewCell.h"

/**
 Overview:
 Simple View Controller. No Xib. Requires nav controller
 */

@interface TestsAndScreeningsListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIView *backgroundView;
    UITableView *testsTable;
    NSArray *allData;
    UIImageView *banner;
    TestsAndScreeningsFacade *productFacade;
    
    UIImageView *firstTrimesterHeaderImage;
    UIImageView *secondTrimesterHeaderImage;
    UIImageView *thirdTrimesterHeaderImage;
}

@end
