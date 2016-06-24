//
//  CustomTextField.m
//  KS App
//
//  Created by Sunidhi Gupta on 30/06/14.
//  Copyright (c) 2014 Techahead. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +10, bounds.origin.y+3, bounds.size.width - 5, bounds.size.height-6);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +10, bounds.origin.y+3, bounds.size.width - 5, bounds.size.height-6);
    return inset;
}


@end
