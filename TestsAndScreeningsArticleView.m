//
//  TestsAndScreeningsArticleView.m
//  WhatToExpect
//
//  Created by Andrew McKinley on 9/29/15.
//
//

#import "TestsAndScreeningsArticleView.h"
#import "AdView.h"

#define FIRST_AD_AFTER_PARAGRAPH 1
#define SECOND_AD_AFTER_PARAGRAPH 3


@interface TestsAndScreeningsArticleView()

@property (strong, nonatomic) UITextView *firstTextView;
@property (strong, nonatomic) UITextView *secondTextView;
@property (strong, nonatomic) UITextView *thirdTextView;
@property (strong, nonatomic) NSArray *paragraphs;
@property (strong, nonatomic) AdView *dfpAdView;
@property (strong, nonatomic) TestsAndScreeningsObjectModel *model;

@end

@implementation TestsAndScreeningsArticleView
 
-(id)initWithModel:(TestsAndScreeningsObjectModel*)theModel
{
    self = [super init];
    if (self)
    {
        self.model = theModel;
        self.paragraphs = [self organizedParagrphs:self.model.content];
        
        self.firstTextView = [self createTextView];
        [self.firstTextView setText:[self firstSectionInParagraphs:self.paragraphs]];
        [self addSubview:self.firstTextView];
        
        self.secondTextView = [self createTextView];
        [self.secondTextView setText:[self secondSectionInParagraphs:self.paragraphs]];
        [self addSubview:self.secondTextView];
        
        self.thirdTextView = [self createTextView];
        [self.thirdTextView setText:[self thirdSectionInParagraphs:self.paragraphs]];
        [self addSubview:self.thirdTextView];
        
        [self constrainLayout];
    }
    return self;
}

-(UITextView*)createTextView
{
    int font = IS_IPHONE() ? 16 : 19;
    UITextView *textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.userInteractionEnabled = NO;
    [textView setScrollEnabled:NO];
    [textView setFont:[UIFont fontWithName:FONT_REGULAR size:font]];
    [textView setTextColor:[UIColor colorWithHexString:@"555555"]];
    [textView setTextContainerInset:UIEdgeInsetsMake(5, 15, 15, 15)];
    return textView;
}

-(void)constrainLayout
{
    NSString *format = @"V:|[firstTextView][secondTextView][thirdTextView]";
    NSDictionary *views = @{ @"firstTextView" : self.firstTextView , @"secondTextView" : self.secondTextView, @"thirdTextView" : self.thirdTextView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [self addConstraints:constraints];
    
    NSString *hFormat = @"H:|[firstTextView]|";
    NSDictionary *hViews = @{ @"firstTextView" : self.firstTextView};
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hFormat
                                                                   options:0
                                                                   metrics:nil
                                                                     views:hViews];
    [self addConstraints:hConstraints];
    
    NSString *hFormat1 = @"H:|[secondTextView]|";
    NSDictionary *hViews1 = @{ @"secondTextView" : self.secondTextView};
    NSArray *hConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat:hFormat1
                                                                     options:0
                                                                     metrics:nil
                                                                       views:hViews1];
    [self addConstraints:hConstraints1];
    NSString *hFormat2 = @"H:|[thirdTextView]|";
    NSDictionary *hViews2 = @{ @"thirdTextView" : self.thirdTextView};
    NSArray *hConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat:hFormat2
                                                                     options:0
                                                                     metrics:nil
                                                                       views:hViews2];
    [self addConstraints:hConstraints2];
}

-(NSString*)firstSectionInParagraphs:(NSArray*)paragraphs
{
    int paragraphCount = 0;
    BOOL addContent = YES;
    NSString *sectionString;
    for (NSString *string in paragraphs)
    {
        if ([self isHeader:string])
        {
            if (paragraphCount < FIRST_AD_AFTER_PARAGRAPH)
            {
                addContent = YES;
                sectionString = [NSString stringWithFormat:@"%@\n%@",sectionString ? sectionString : @"",string];
            }
            else
            {
                addContent = NO;
            }
            paragraphCount++;
        }
        else if (addContent)
        {
            sectionString = sectionString ? string : [NSString stringWithFormat:@"%@\n\n%@\n",sectionString,string];
        }
    }
    return sectionString;
}

-(NSString*)secondSectionInParagraphs:(NSArray*)paragraphs
{
    int paragraphCount = 0;
    BOOL addContent = NO;
    NSString *sectionString;
    for (NSString *string in paragraphs)
    {
        if ([self isHeader:string])
        {
            if (paragraphCount >= FIRST_AD_AFTER_PARAGRAPH && paragraphCount < SECOND_AD_AFTER_PARAGRAPH)
            {
                addContent = YES;
                sectionString = [NSString stringWithFormat:@"%@\n%@",sectionString ? sectionString : @"",string];
            }
            else
            {
                addContent = NO;
            }
            paragraphCount++;
        }
        else if (addContent)
        {
            sectionString = [NSString stringWithFormat:@"%@\n%@\n",sectionString ? sectionString : @"",string];
        }
    }
    return sectionString;
}

-(NSString*)thirdSectionInParagraphs:(NSArray*)paragraphs
{
    int paragraphCount = 0;
    BOOL addContent = NO;
    NSString *sectionString;
    for (NSString *string in paragraphs)
    {
        if ([self isHeader:string])
        {
            if (paragraphCount >= SECOND_AD_AFTER_PARAGRAPH)
            {
                addContent = YES;
                sectionString = [NSString stringWithFormat:@"%@\n%@",sectionString ? sectionString : @"",string];
            }
            else
            {
                addContent = NO;
            }
            paragraphCount++;
        }
        else if (addContent)
        {
            sectionString = [NSString stringWithFormat:@"%@\n%@\n",sectionString ? sectionString : @"",string];
        }
    }
    return sectionString;
}

-(NSArray*)organizedParagrphs:(NSString*)content
{
    NSArray *brokenString = [content componentsSeparatedByString:@"\n"];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSString *string in brokenString)
    {
        if (![string isEqualToString:@""])
        {
            [results addObject:string];
        }
    }
    return [NSArray arrayWithArray:results];
}

-(BOOL)isHeader:(NSString*)string
{
    if ([string isEqualToString:[string uppercaseString]])
    {
        return YES;
    }
    
    return NO;
}

@end
