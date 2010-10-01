//
//  Clojure.m
//  clojure
//
//  Created by Eric on 28/09/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import "CJZoneTree.h"
#import "OnigRegexp.h"
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>

@implementation CJZoneTree

@synthesize syntaxContext;
@synthesize expression;
@synthesize action;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  expression=[dictionary objectForKey:@"expression"];
  action=[dictionary objectForKey:@"action"];
	return self;
}

// Get zone at cursor location
+ (SXZone *)currentZoneInContext:(id)context
{
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  SXZone *zone = nil;
  if ([[context string] length] == range.location) {
    zone = [[context syntaxTree] rootZone];
  } else {
    zone = [[context syntaxTree] zoneAtCharacterIndex:range.location];
  }
  return zone;
}

// Required: return whether or not the action can be performed on the context.
// It's recommended to keep this as lightweight as possible, since you're not the only 
// action in Espresso.
- (BOOL)canPerformActionWithContext:(id)context
{
  // Possible for context to be empty if it's partially initialized
	if ([context string] == nil) {
		return NO;
	}
  // Check on the syntaxContext
	if ([self syntaxContext] != nil) {
    SXSelectorGroup *selectors = [SXSelectorGroup selectorGroupWithString:[self syntaxContext]];
		if (![selectors matches:[CJZoneTree currentZoneInContext: context]]) {
			return NO;
		}
	}
	return YES;
}

// Checks whether zone matches the regex give in the <expression/> option
- (BOOL) isExpr:(SXZone *)zone{
  if (zone==nil) 
    return NO;
  OnigRegexp *regex = [OnigRegexp compileIgnorecase:expression];
  return [[regex search:[zone text]] count] > 0;
}

// Gets an array of all zones within a zone
- (NSArray *) zonesInZone:(SXZone *)zone{
  NSAssert(zone, @"Invalid argument to [CJZoneTree zonesInZone]");
  NSMutableArray *zones=[NSMutableArray arrayWithCapacity:4];
  [zones addObject:zone];
  for (int i=0; i<[zone childCount]; i++) {
    [zones addObjectsFromArray:[self zonesInZone:[zone childAtIndex:i]]];
  }
  return zones;
}

// Find the first occurrence of a matched expression in a zone
- (SXZone *) findExpr:(SXZone *)zone{
  if ([self isExpr:zone]){
    return zone;
  }
  for (int i=0; i<[zone childCount]; i++){
    SXZone *found=[self findExpr:[zone childAtIndex:i]];
    if (found){
      return found;
    }
  }
  return nil;
}

// Get the nearest zone to the cursor
- (SXZone *) getExpr:(id)context{
  NSLog(@"getExpr called");
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  NSArray *zones=[self zonesInZone:[[context syntaxTree] rootZone]];
  for (int i=0; i<[zones count]; i++){
    SXZone *zone=[zones objectAtIndex:i];
    if ([self isExpr:zone] && 
        (range.location >= [zone range].location 
         && range.location <= [zone range].location + [zone range].length
         || range.location <= [zone range].location)){
      return zone;
    }
  }
  return nil;
}

// Get the parent expression of an expression. zone must be a matched expression
- (SXZone *) parentExpr:(SXZone *)zone{
  NSLog(@"parentExpr called");
  NSAssert(zone && [self isExpr:zone], @"Invalid argument to [CJZoneTree parentExpr]");
  SXZone *parent=[zone parent];
  while (parent && [parent parent] && ![self isExpr:parent]){
    NSLog(@"parentExpr while loop");
    NSLog([NSString stringWithFormat:@"%@", [parent text]]);
    parent=[parent parent];
  }
  return parent;
}

// Get the children expressions of an expression. zone must be a matched expression
- (NSArray *) childrenExpr:(SXZone *)zone{
  NSLog(@"childrenExpr called");
  NSAssert(zone, @"Invalid argument to [CJZoneTree childrenExpr]");
  NSUInteger count=[zone childCount];
  NSMutableArray *children=[NSMutableArray arrayWithCapacity:count];
  NSArray *zones = [self zonesInZone:zone];
  for (int j=0; j < [zones count]; j++){
    NSLog(@"childrenExpr for loop");
    SXZone *currentZone=[zones objectAtIndex:j];
    if ([self isExpr:currentZone]){
      NSAssert([self isExpr:currentZone], @"[CJZoneTree childrenExpr] calling parentExpr, nested if");
      if (zone == [self parentExpr:currentZone]){
        [children addObject:currentZone];
      }
    }
  }
  return children;
}

// Get the next expression from zone. zone must be a matched expression
- (SXZone *) nextExprDFS:(SXZone *)zone {
  NSLog(@"nextExprDFS called");
  NSAssert(zone && [self isExpr:zone], @"Invalid argument to [CJZoneTree nextExprDFS]");
  NSArray *children=[self childrenExpr:zone];
  if ([children count] > 0){
    SXZone *result=[children objectAtIndex:0];
    NSAssert(result!=zone, @"Next failed nextExprDFS");
    return result;
  }
  SXZone *siblingTo=zone;
  NSAssert([self isExpr:siblingTo], @"[CJZoneTree nextExpr] calling parentExpr with siblingTo");
  SXZone *parent=[self parentExpr:siblingTo];
  NSArray *siblings = [self childrenExpr:parent];
 
  while (parent && [self parentExpr:parent] && siblingTo==[siblings objectAtIndex:[siblings count]-1]){
    NSLog(@"nextExprDFS while loop");
    NSAssert([self isExpr:siblingTo], @"[CJZoneTree nextExpr] calling parentExpr with siblingTo in while");
    siblingTo=[self parentExpr:siblingTo];
    NSAssert([self isExpr:parent], @"[CJZoneTree nextExpr] calling parentExpr with parent in while");
    parent=[self parentExpr:parent];
    siblings=[self childrenExpr:parent];
  }
  
  for (int i=1; i<[siblings count]; i++){
     NSLog(@"nextExprDFS for loop");
    if ([siblings objectAtIndex:i-1]==siblingTo){
      SXZone *result=[siblings objectAtIndex:i];
      NSAssert(result!=zone, @"Next failed nextExprDFS");
      return result;
    }
  }
  return nil;
}

// Get the previous expression to zone. zone must be a matched expression
- (SXZone *) previousExprDFS:(SXZone *)zone{
  NSAssert([self isExpr:zone], @"Invalid argument to [CJZoneTree previousExprDFS]");
  return nil;
}

// Get the next expression from zone. zone must be a matched expression
- (SXZone *) nextExprBFS:(SXZone *)zone{
  NSAssert([self isExpr:zone], @"Invalid argument to [CJZoneTree nextExprBFS]");
  return nil;
}

// Get the previous expression to zone. zone must be a matched expression
- (SXZone *) previousExprBFS:(SXZone *)zone{
  NSAssert([self isExpr:zone], @"Invalid argument to [CJZoneTree previousExprBFS]");
  return nil;
}

// Required: actually perform the action on the context.
// If an error occurs, pass an NSError via outError (warning: outError may be NULL!)
- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
  NSLog(@"performActionWithContext called");
  if ([self action] == nil) {
		NSLog(@"Clojure.sugar Error: Missing action tag in XML");
		return NO;
	}
  SXZone *zone=[CJZoneTree currentZoneInContext:context];
  SXZone *expr = [self getExpr:context];
  if (zone== nil) {
    NSLog(@"Clojure.sugar Error: Cannot find any matching zone. Is it the clojure context?");
    return NO; 
  }
  if ([zone range].location == [expr range].location){
    zone=expr;
  } 
  if (![self isExpr:zone]){
    zone = [self getExpr:context];
  }
  else if ([action caseInsensitiveCompare:@"next"] == 0){
    zone = [self nextExprDFS:zone];
  }
  else if ([action caseInsensitiveCompare:@"previous"] == 0){
    zone = [self previousExprDFS:zone];
  }
  
  NSRange selectedRange=zone.range;
  NSArray *selectedRanges=[NSArray arrayWithObject:[NSValue valueWithRange:selectedRange]];
  [context setSelectedRanges:selectedRanges];
	return YES;
}

- (void)dealloc
{
	[super dealloc];
}

@end
