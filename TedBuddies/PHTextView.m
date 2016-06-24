//
//  PHTextView.m
//  FitnessChallenge
//
//  Created by Teena Nath Paul on 21/05/14.
//  Copyright (c) 2014 Teena Nath Paul. All rights reserved.
//

#import "PHTextView.h"

@implementation PHTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    self.delegate = self;
    _placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(3, 7, self.frame.size.width, 30)];
    [_placeHolder setBackgroundColor:[UIColor clearColor]];
    [_placeHolder setNumberOfLines:0];
    [_placeHolder setTextColor:kBlueColor];
    [self addSubview:_placeHolder];
}

- (void)setPlaceHolderText:(NSString *)text
{
    _placeHolder.text = text;
    [_placeHolder sizeToFit];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (string.length > 0)
    {
        _placeHolder.hidden = YES;
    }
    else
    {
        _placeHolder.hidden = NO;
    }
    
    return YES;
}

@end
