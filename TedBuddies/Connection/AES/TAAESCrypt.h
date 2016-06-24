
//
//  Created by Ashish on 04/02/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface TAAESCrypt : NSObject

+ (NSString *)encrypt:(NSString *)message password:(NSString *)password;
+ (NSString *)decrypt:(NSString *)base64EncodedString password:(NSString *)password;

@end
