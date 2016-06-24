
//
//  Created by Ashish on 04/02/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

#import <Foundation/NSString.h>

@interface NSString (Base64Additions)

+ (NSString *)base64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
