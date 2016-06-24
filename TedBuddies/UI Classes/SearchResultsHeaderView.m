//
//  SearchResultsHeaderView.m
//  GiphyClient
//
//  Created by Jared Halpern on 9/14/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import "SearchResultsHeaderView.h"
#import "Constants.h"


@interface SearchResultsHeaderView ()
@property (nonatomic, strong) UILabel *resultsLabel;
@end

@implementation SearchResultsHeaderView

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    
    _resultsLabel = [[UILabel alloc] init];
    _resultsLabel.font = kFontRegular;
    _resultsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _resultsLabel.textColor = [UIColor whiteColor];
    _resultsLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_resultsLabel];
    
    self.backgroundColor = kColorDarkBlue;
    [self setupConstraints];
  }
  return self;
}

- (void)setupConstraints
{
  NSMutableArray *constraints = [@[]mutableCopy];
  
  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_resultsLabel]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_resultsLabel)]];
  
  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_resultsLabel]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_resultsLabel)]];
  [self addConstraints:constraints];
}

- (void)setResultsLabelText:(NSString *)resultsLabelText
{
  _resultsLabel.text = resultsLabelText;
  [self setNeedsLayout];
}

@end