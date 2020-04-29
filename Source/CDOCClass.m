// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-1998, 2000-2001, 2004-2015 Steve Nygard.

#import "CDOCClass.h"

#import "CDClassDump.h"
#import "CDOCInstanceVariable.h"
#import "CDOCMethod.h"
#import "CDType.h"
#import "CDTypeController.h"
#import "CDTypeParser.h"
#import "CDVisitor.h"
#import "CDVisitorPropertyState.h"
#import "CDOCClassReference.h"

@implementation CDOCClass
{
    NSArray *_instanceVariables;

    BOOL _isExported;
}

- (id)init;
{
    if ((self = [super init])) {
        _isExported = YES;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@, exported: %@", [super description], self.isExported ? @"YES" : @"NO"];
}

#pragma mark -

- (NSString *)superClassName;
{
    return [_superClassRef className];
}

- (void)registerTypesWithObject:(CDTypeController *)typeController phase:(NSUInteger)phase;
{
    [super registerTypesWithObject:typeController phase:phase];

    for (CDOCInstanceVariable *instanceVariable in self.instanceVariables) {
        [instanceVariable.type phase:phase registerTypesWithObject:typeController usedInMethod:NO];
    }
}

- (NSString *)methodSearchContext;
{
    NSMutableString *resultString = [NSMutableString string];

    [resultString appendFormat:@"@interface %@", self.name];
    if (self.superClassName != nil)
        [resultString appendFormat:@" : %@", self.superClassName];

    if ([self.protocols count] > 0)
        [resultString appendFormat:@" <%@>", self.protocolsString];

    return resultString;
}

- (void)recursivelyVisit:(CDVisitor *)visitor;
{
    if (!self.shouldRecursivelyVisit) {
        return;
    }
    if ([visitor.classDump shouldShowName:self.name]) {
        CDVisitorPropertyState *propertyState = [[CDVisitorPropertyState alloc] initWithProperties:self.properties];
        
        [visitor willVisitClass:self];
        
        [visitor willVisitIvarsOfClass:self];
//        for (CDOCInstanceVariable *instanceVariable in self.instanceVariables)
//            [visitor visitIvar:instanceVariable];
        [visitor didVisitIvarsOfClass:self];
        
        //[visitor willVisitPropertiesOfClass:self];
        //[self visitProperties:visitor];
        //[visitor didVisitPropertiesOfClass:self];
        
        [self visitMethods:visitor propertyState:propertyState];
        // Should mostly be dynamic properties
//        [visitor visitRemainingProperties:propertyState];
        [visitor didVisitClass:self];
    }
}

#pragma mark - CDTopologicalSort protocol

- (NSString *)identifier;
{
    return self.name;
}

- (NSArray *)dependancies;
{
    if (self.superClassName == nil)
        return @[];

    return @[self.superClassName];
}

- (BOOL)shouldRecursivelyVisit {
    BOOL shouldRecursivelyVisit = [super shouldRecursivelyVisit];
    if (shouldRecursivelyVisit == NO) {
        return shouldRecursivelyVisit;
    }
    if ([self.name hasPrefix:@"AF"]
        || [self.name hasPrefix:@"Ali"]
        || [self.name hasPrefix:@"YY"]
        || [self.name hasPrefix:@"WB"]
        || [self.name hasPrefix:@"QQ"]
        || [self.name hasPrefix:@"UM"]
        || [self.name hasPrefix:@"LOT"]
        || [self.name hasPrefix:@"SVG"]
        || [self.name hasPrefix:@"SD"]
        || [self.name hasPrefix:@"RCT"]
        || [self.name hasPrefix:@"JD"]
        || [self.name hasPrefix:@"FM"]
        || [self.name hasPrefix:@"FLEX"]
        || [self.name hasPrefix:@"GCD"]
        || [self.name hasPrefix:@"TX"]
        || [self.name hasPrefix:@"BM"]) {
        return NO;
    }
    return shouldRecursivelyVisit;
}
@end
