//
//  NSDictionary+dictionaryWithObject.h
//  TedBuddies
//
//  Created by Mac on 30/03/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSDictionary (dictionaryWithObject)
+(NSDictionary *) dictionaryWithPropertiesOfObject:(id) obj;
@end
