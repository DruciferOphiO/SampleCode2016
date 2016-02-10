
//
//  TestsAndScreeningsDetailViewController.m
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
//

#import "TestsAndScreeningsDetailViewController.h"
#import "TestsAndScreeningsTableViewCell.h"
#import "UIView+EH.h"
#import "TestsAndScreeningsArticleView.h"

@interface TestsAndScreeningsDetailViewController ()

@property (strong, nonatomic) TestsAndScreeningsArticleView *articleView;
@end

@implementation TestsAndScreeningsDetailViewController


-(id)initWithModel:(TestsAndScreeningsObjectModel*)_model withViewAtRect:(CGRect)_rect{
    self = [super init];
    if (self){
        model = _model;
        shouldAnimateView = YES;
        startFrame = _rect;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];

    [self setTitle:model.title];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:scrollView];
    
    mainImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",model.imageName]]];
    [scrollView addSubview:mainImageView];
    
    topView = [[UIView alloc] initWithFrame:startFrame];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:topView];
    
    topIconImageView = [[UIImageView alloc] init];
    [topView addSubview:topIconImageView];
    
    topTitleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    topTitleTextView.userInteractionEnabled = NO;
    [topView addSubview:topTitleTextView];
    
    topMainTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    topMainTextView.userInteractionEnabled = NO;
    
    [topView addSubview:topMainTextView];
    self.articleView = [[TestsAndScreeningsArticleView alloc] initWithModel:model];
    [scrollView addSubview:self.articleView];

    topViewFinalX = IS_IPHONE() ? 10 : 30;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    float imageX = IS_IPHONE() ? 10 : (self.view.frame.size.width - mainImageView.image.size.width)/2;
    int imageAdjustment = IS_IPHONE() ? 20 : 0;
    self.articleView.frame = CGRectMake(0, mainImageView.image.size.height + [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model], self.view.frame.size.width, [self getArticleViewHeight]);

    if (!shouldAnimateView){
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        mainImageView.frame = CGRectMake(imageX, 0, mainImageView.image.size.width-imageAdjustment, mainImageView.image.size.height);
        [self layoutTopView];
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, mainImageView.image.size.height + [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model] +[self getArticleViewHeight])];
    }else{
        mainImageView.alpha = 0;
        self.articleView.alpha = 0;
        mainImageView.frame = CGRectMake(imageX, 0, mainImageView.image.size.width-imageAdjustment, mainImageView.image.size.height);
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self layoutTopView];
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, mainImageView.image.size.height + [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model] +[self getArticleViewHeight])];
        
        __block TestsAndScreeningsDetailViewController *blocksafeSelf = [AppUtils blockSafeInstanceOf:self];
        __block UIView *blocksafeTopView = [AppUtils blockSafeInstanceOf:topView];
        __block UIImageView *blocksafeImageView = [AppUtils blockSafeInstanceOf:mainImageView];
        [UIView animateWithDuration:0.33f delay:0.20 options:UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionBeginFromCurrentState animations:^{
            blocksafeTopView.frame = CGRectMake(topViewFinalX, blocksafeImageView.image.size.height, blocksafeSelf.view.frame.size.width-(topViewFinalX*2), [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model]);
            
        } completion:^(BOOL finished) {
            [blocksafeSelf performSelector:@selector(fadeInViews) withObject:nil afterDelay:0];
        }];
    }
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (!shouldAnimateView){
        float imageX = IS_IPHONE() ? 10 : (self.view.frame.size.width - mainImageView.image.size.width)/2;
        int imageAdjustment = IS_IPHONE() ? 20 : 0;
        scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        mainImageView.frame = CGRectMake(imageX, 0, mainImageView.image.size.width-imageAdjustment, mainImageView.image.size.height);
        [self layoutTopView];
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, mainImageView.image.size.height + [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model] +[self getArticleViewHeight])];
    }
}

-(NSArray*)organizedParagrphs:(NSString*)content{
    NSArray *brokenString = [content componentsSeparatedByString:@"\n"];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *string in brokenString){
        if (![string isEqualToString:@""]){
            [results addObject:string];
        }
    }
    return [NSArray arrayWithArray:results];
}

-(BOOL)isHeader:(NSString*)string{
    if ([string isEqualToString:[string uppercaseString]]){
        return YES;
    }
    
    return NO;
}

-(void)fadeInViews{
    __block UIImageView *blocksafeImageView = [AppUtils blockSafeInstanceOf:mainImageView];
    __block UITextView *blockSafeMainTextView = [AppUtils blockSafeInstanceOf:self.articleView];
    shouldAnimateView = NO;
    startFrame = CGRectZero;
    
    [UIView animateWithDuration:0.3f animations:^{
        blocksafeImageView.alpha = 1;
        blockSafeMainTextView.alpha = 1;
    } completion:nil];
}

-(void)layoutTopView{
    if ([model.weekIconText isEqualToString:@"EVERY DOCTOR VISIT"]){
        [topIconImageView setImage:[UIImage imageNamed:@"icon_testscreenings_everyvisit"]];
    }else if ([model.weekIconText isEqualToString:@"FIRST DOCTOR VISIT"]){
        [topIconImageView setImage:[UIImage imageNamed:@"icon_testscreenings_1stvisit"]];
    }else{
        [topIconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_testscreenings_week%@.png",model.weekIconText]]];
    }
    
    topIconImageView.frame = CGRectMake(10, 20, 50, 50);
    
    int widthAdjustment = IS_IPHONE() ? 20 : 60;
    [topTitleTextView setText:[NSString stringWithFormat:@"%@",model.title]];
    topTitleTextView.userInteractionEnabled = NO;
    int font = IS_IPHONE() ? 13 : 19;
    NSString *titleFontColor = IS_IPHONE() ? @"000000" : @"5f4d7f";
    [topTitleTextView setFont:[UIFont fontWithName:FONT_BOLD size:font]];
    [topTitleTextView setTextColor:[UIColor colorWithHexString:titleFontColor]];
    [topTitleTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    topTitleTextView.frame = CGRectMake(topIconImageView.frame.origin.x + topIconImageView.frame.size.width + 5, 15, self.view.frame.size.width - topIconImageView.frame.origin.x - topIconImageView.frame.size.width - 5 - widthAdjustment, 25);

    [topMainTextView setText:[NSString stringWithFormat:@"%@",model.testDescription]];
    topMainTextView.userInteractionEnabled = NO;
    
    NSString *textFontColor = IS_IPHONE() ? @"4c4c4c" : @"5f4d7f";
    [topMainTextView setFont:[UIFont fontWithName:FONT_REGULAR size:font]];
    [topMainTextView setTextColor:[UIColor colorWithHexString:textFontColor]];
    [topMainTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    float mainTextHeight = [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:nil] - topTitleTextView.frame.size.height - topTitleTextView.frame.origin.y -1;

    topMainTextView.frame = CGRectMake(topIconImageView.frame.origin.x + topIconImageView.frame.size.width + 5, topTitleTextView.frame.origin.y + topTitleTextView.frame.size.height, topTitleTextView.frame.size.width, mainTextHeight);
    
    
    
    if (CGRectEqualToRect(startFrame, CGRectZero)){
        topView.frame = CGRectMake(topViewFinalX, mainImageView.image.size.height, self.view.frame.size.width-(topViewFinalX*2), [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model]);
    }else{
        topView.frame = CGRectMake(startFrame.origin.x, startFrame.origin.y, startFrame.size.width, startFrame.size.height);
    }
}

// scan all UITextView and add thier heights
-(float)getArticleViewHeight{
    float height = 0.0f;
    [self.articleView layoutIfNeeded];
    for (UIView *view in self.articleView.subviews){
        if ([view class] == [UITextView class]){
            UITextView *textView = (UITextView*)view;
            height = height + textView.contentSize.height;
        }
        [self.view bringSubviewToFront:view];
    }
    return height;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect{
    return 2;
}

-(void)sharePressed{
    NSString *bodyStr = @"Learn why this diagnostic test is recommended, along with its accuracy and risks: http://www.whattoexpect.com/pregnancy/pregnancy-health/prenatal-testing/amniocentesis.aspx";

    bodyStr = [NSString stringWithFormat:@"%@ \n\n %@", bodyStr, NSLocalizedString(@"COMMUNITY_SHARE_APP_LINK_TEXT", nil)];
    
    NSArray *postArr = [NSArray arrayWithObjects:bodyStr, [NSURL URLWithString:ITUNES_APP_STORE_TRACKING_URL], nil];
    
    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:postArr applicationActivities:nil];
    
    [act setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
        if(completed){
            [EHTracking logShareActionWithNetwork:activityType andOptions:nil];
        }
    }];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        if ([act.popoverPresentationController respondsToSelector:@selector(setSourceView:)]) {
            act.excludedActivityTypes = @[UIActivityTypeAirDrop];
            act.popoverPresentationController.sourceView = self.navigationController.navigationBar;
            [act.view setTintColor:[UIColor colorWithHexString:@"0D56FE"]];
            act.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width - 90,-50, 100, 100);
            act.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            act.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"0D56FE"];
        }
    }
    [self presentViewController:act animated:YES completion:nil];
}

-(NSString*)pageNameForPageView{
    return @"Detail";
}

-(NSString*)channelForPageView{

    return @"Tests And Screenings";
}
@end
