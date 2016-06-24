//
//  Categories.m
//  PikMyKidDispatcher
//
//  Created by Teena Nath Paul on 28/03/14.
//  Copyright (c) 2014 Techahead Software. All rights reserved.
//

#import "Categories.h"

//========================  NSDictionary Category ====================
@implementation NSDictionary (DictExpanded)

- (id)objectForKeyNonNull:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null] || obj == nil)
        return @"";
    return obj;
}

@end

//========================  NSMutableDictionary Category ====================
@implementation NSMutableDictionary (Expanded)

- (id)objectForKeyNonNull:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null] || obj == nil)
        return @"";
    return obj;
}


@end

//========================  UIView Category ====================
@implementation UIView (SubviewHunting)

- (UIView*)huntedSubviewWithClassName:(NSString*) className
{
    if([[[self class] description] isEqualToString:className])
        return self;
    
    for(UIView* subview in self.subviews)
    {
        UIView* huntedSubview = [subview huntedSubviewWithClassName:className];
        
        if(huntedSubview != nil)
            return huntedSubview;
    }
    
    return nil;
}

- (UIView*)huntedSuperViewWithClassName:(Class)className
{
    if([self isKindOfClass:className])
        return self;
    
    UIView *hunted = self;
    
    while (hunted)
    {
        hunted = hunted.superview;
        if ([hunted isKindOfClass:className])
        {
            return hunted;
        }
    }
    
    return nil;
}


- (void) debugSubviews
{
    [self debugSubviews:0];
}

- (void) debugSubviews:(NSUInteger) count
{
    if(count == 0)
        printf("\n\n\n");
    
    for(int i = 0; i <= count; i++)
        printf("--");
    
    printf(" %s\n", [[self class] description].UTF8String);
    
    for(UIView* x in self.subviews)
        [x debugSubviews:(count + 1)];
    
    if(count == 0)
        printf("\n\n\n");
}

- (void)setHeight:(CGFloat)height
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height)];
}

- (void)setWidth:(CGFloat)width
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height)];
}

- (void)setOrigin:(CGPoint)point
{
    [self setFrame:CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height)];
}
- (void)setXOrigin:(CGFloat)x
{
    [self setFrame:CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}
- (void)setYOrigin:(CGFloat)y
{
    [self setFrame:CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height)];
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)xOrigin
{
    return self.frame.origin.x;
}

- (CGFloat)yOrigin
{
    return self.frame.origin.y;
}


@end


@implementation NSString (NSStringExtended)

- (BOOL) appendToFile
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"ServerLog/DispatcherServerLog.txt"];
    
    
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return NO;
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[self dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}

@end

@implementation Categories

@end
