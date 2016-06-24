//
//  PHTextView.h
//  FitnessChallenge
//
//  Created by Teena Nath Paul on 21/05/14.
//  Copyright (c) 2014 Teena Nath Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHTextView : UITextView<UITextViewDelegate>

@property (nonatomic, strong) UILabel *placeHolder;
- (void)setPlaceHolderText:(NSString *)text;

@end
