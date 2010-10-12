//
//  Clojure.m
//  clojure
//
//  Created by Eric on 28/09/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import "CJZoneTree.h"
#import "CJExpr.h"
#import "OnigRegexp.h"
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>

@implementation CJZoneTree

@synthesize syntaxContext;
@synthesize expression;
@synthesize action;
@synthesize matchingZone;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  action=[dictionary objectForKey:@"action"];
  matchingZone=[dictionary objectForKey:@"zone"];
  expression=[dictionary objectForKey:@"expression"];
  exprs=[[CJExpr alloc] initWithRegex:expression Zones:matchingZone];
	return self;
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
		if (![selectors matches:[exprs currentZone:context]]) {
			return NO;
		}
	}
	return YES;
}

+ (void)setSelection:(NSRange) range withContext:(id)context 
{
  NSArray *selectedRanges=[NSArray arrayWithObject:[NSValue valueWithRange:range]];
  [context setSelectedRanges:selectedRanges];
}

// Set the zone to become the new selection in the context.
+ (void)setSelectiontoZone:(SXZone *)zone withContext:(id)context 
{
  NSRange selectedRange=zone.range;
  [CJZoneTree setSelection:selectedRange withContext:context];
}

- (BOOL)selectNextExpr:(id)context
{
  NSRange range=[exprs currentRange:context];
  SXZone *expr=[exprs nextExprTo:range.location withContext:context];
  if (expr){
    [CJZoneTree setSelectiontoZone:expr withContext:context];
    return YES;
  }
  return NO;
}

- (BOOL)selectPreviousExpr:(id)context
{
  NSRange range=[exprs currentRange:context];
  SXZone *expr=[exprs previousExprTo:range.location withContext:context];
  if (expr){
    [CJZoneTree setSelectiontoZone:expr withContext:context];
    return YES;
  }
  return NO;
}

- (BOOL)moveNextExpr:(id)context
{
  NSRange range=[exprs currentRange:context];
  SXZone *expr=[exprs nextExprTo:range.location withContext:context];
  if (expr){
    range.length=0;
    range.location=[expr range].location;
    [CJZoneTree setSelection:range withContext:context];
    return YES;
  }
  return NO;
}


- (BOOL)movePreviousExpr:(id)context
{
  NSRange range=[exprs currentRange:context];
  SXZone *expr=[exprs previousExprTo:range.location withContext:context];
  if (expr){
    range.length=0;
    range.location=[expr range].location;
    [CJZoneTree setSelection:range withContext:context];
    return YES;
  }
  return NO;
}

// Required: actually perform the action on the context.
// If an error occurs, pass an NSError via outError (warning: outError may be NULL!)
- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
  if ([self action] == nil) {
		NSLog(@"Clojure.sugar Error: Missing action tag in XML");
		return NO;
	}
  if ([action caseInsensitiveCompare:@"select_next"] == 0){
    if ([self selectNextExpr:context]){
      return YES;
    }
  }
  else if ([action caseInsensitiveCompare:@"select_previous"] == 0){
    if ([self selectPreviousExpr:context]){
      return YES;
    }
  }
  else if ([action caseInsensitiveCompare:@"move_next"] == 0){
    if ([self moveNextExpr:context]){
      return YES;
    }
  }
  else if ([action caseInsensitiveCompare:@"move_previous"] == 0){
    if ([self movePreviousExpr:context]){
      return YES;
    }
  }
  return NO;
}

- (void)dealloc
{
  [exprs release];
	[super dealloc];
}

@end
