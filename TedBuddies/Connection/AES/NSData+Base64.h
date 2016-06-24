
//  Created by Ashish on 04/02/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (Base64Additions)

+ (NSData *)base64DataFromString:(NSString *)string;

@end