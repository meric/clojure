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
@synthesize matchingZone;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  expression=[dictionary objectForKey:@"expression"];
  action=[dictionary objectForKey:@"action"];
  matchingZone=[dictionary objectForKey:@"zone"];
	return self;
}

// Returns the zone the current cursor is pointing at.
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

// Returns whether the zone matches the regular expression specified in the 
// "expression" tag.
- (BOOL) matchRegex:(SXZone *)zone{
  if (![self expression]){
    return YES;
  }
  if (zone && [self expression]){
    OnigRegexp *regex = [OnigRegexp compile:expression ignorecase:YES multiline:YES];
    return [[regex search:[zone text]] count] > 0;
  }
  return NO;
}

// Returns whether the zone matches one of the zones specified in the "zone" tag.
- (BOOL) matchZone:(SXZone *)zone{
  if (![self matchingZone]){
    return YES;
  }
  if (zone && [self matchingZone] != nil) {
    SXSelectorGroup *selectors = [SXSelectorGroup selectorGroupWithString:[self matchingZone]];
    if ([selectors matches:zone]) {
      return YES;
    }
  }
  return NO;
}

// Checks whether zone matches the regular expression in the "expression" tag as well 
// as the one of the zones specified in the "zone" tag.
- (BOOL) isExpr:(SXZone *)zone{
  return [self matchRegex:zone] && [self matchZone:zone];
}

+ (void)setSelection:(NSRange) range withContext:(id)context {
  NSArray *selectedRanges=[NSArray arrayWithObject:[NSValue valueWithRange:range]];
  [context setSelectedRanges:selectedRanges];
}


// Set the zone to become the new selection in the context.
+ (void)setSelectiontoZone:(SXZone *)zone withContext:(id)context {
  NSRange selectedRange=zone.range;
  [CJZoneTree setSelection:selectedRange withContext:context];
}
  

// Returns whether range1 is identical to range2.
+ (BOOL) range:(NSRange)range1 equals:(NSRange) range2 {
  return range1.location==range2.location && range1.length==range2.length;
}

// Returns the last child of zone.
+ (SXZone *)lastChild:(SXZone *)zone{
  SXZone *z=nil;
  for (SXZone *i in zone){
    z=i;
  }
  return z;
}

// Returns the first child of zone.
+ (SXZone *)firstChild:(SXZone *)zone{
  for (SXZone *i in zone){
    return i;
  }
  return nil;
}

// Returns the next child in the child's parent.
+ (SXZone *)nextSibling:(SXZone *)child{
  SXZone *previous=nil;
  for (SXZone *zone in [child parent]){
    if (previous==child){
      return zone;
    }
    previous=zone;
  }
  return nil;
}

// Returns the previous child in the child's parent.
+ (SXZone *)previousSibling:(SXZone *)child{
  SXZone *previous=nil;
  for (SXZone *zone in [child parent]){
    if (zone==child){
      return previous;
    }
    previous=zone;
  }
  return nil;
}

// Returns the next zone after the specified zone.
+ (SXZone *)nextZoneTo:(SXZone *)thisZone{
  SXZone *child;
  if (child=[self firstChild:thisZone]){
    return child;
  }
  SXZone *parent=[thisZone parent];
  child=thisZone;
  while (parent && child==[CJZoneTree lastChild:parent]) {
    
    parent=[parent parent];
    child=[child parent];
  }
  return [CJZoneTree nextSibling:child];
}

// Returns the previous zone before the specified zone.
+ (SXZone *)previousZoneTo:(SXZone *)thisZone{
  SXZone *zone;
  if ((zone=[CJZoneTree previousSibling:thisZone])){
    while ([zone childCount] > 0){
      
      zone = [zone childAtIndex:[zone childCount]-1];
    }
    return zone;
  }
  return [thisZone parent];
}

// Returns the expression currently wrapping the cursor
- (SXZone *)getExpr:(id)context{
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  SXZone *zone= [[context syntaxTree] zoneAtCharacterIndex:range.location];
  while(zone && ![self isExpr:zone]){
    zone=[zone parent];
  }
  return zone;
}

// Returns the next zone after the zone containing the cursor.
+ (SXZone *)getNextZone:(id)context{
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  SXZone *zone=[[context syntaxTree] rootZone];
  zone=[self currentZoneInContext:context]; //[[context syntaxTree] rootZone];
  while(zone && [zone range].location <= range.location){
    zone = [CJZoneTree nextZoneTo:zone];
  }
  return zone;
}

// Returns the previous zone before the zone containing the cursor.
+ (SXZone *)getPreviousZone:(id)context{
  return [CJZoneTree previousZoneTo:[CJZoneTree getNextZone:context]];
}

// Returns the next expression if an expression is not being selected,
// otherwise returns the expression wrapping the cursor
- (SXZone *)getNextExpr:(id)context{
  SXZone *expr=[self getExpr:context];
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  if (expr == nil || [CJZoneTree range:range equals:[expr range]]){
    expr = [CJZoneTree getNextZone:context];
    while(expr && (![self isExpr:expr] || [CJZoneTree range:[expr range] equals:range])){
      expr = [CJZoneTree nextZoneTo:expr];
    }
  }
  return expr;
}

// Returns the previous expression if an expression is not being selected,
// otherwise returns the expression wrapping the cursor
- (SXZone *)getPreviousExpr:(id)context{
  SXZone *expr=[self getExpr:context];
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  if (expr == nil || [CJZoneTree range:range equals:[expr range]]){
    expr = [CJZoneTree getPreviousZone:context];
    while(expr && (![self isExpr:expr] || [CJZoneTree range:[expr range] equals:range])){
      
      expr = [CJZoneTree previousZoneTo:expr];
    }
  }
  return expr;
}

// Returns the very last zone in the context
- (SXZone *) getLastZone:(id)context{
  SXZone *parent=[[context syntaxTree] rootZone];
  SXZone *child=nil;
  while (child=[CJZoneTree lastChild:parent]) {
    parent=child;
  }
  return parent;
}

// Returns the very first zone in the context.
- (SXZone *) getFirstZone:(id)context{
  return [CJZoneTree firstChild:[[context syntaxTree] rootZone]];
}

- (BOOL)selectNextExpr:(id)context{
  SXZone *expr=[self getNextExpr:context];
  if (expr == nil){
    expr=[self getFirstZone:context];
    while(expr && ![self isExpr:expr]){
      expr=[CJZoneTree nextZoneTo:expr];
    }
  }
  if (expr){
    [CJZoneTree setSelectiontoZone:expr withContext:context];
    return YES;
  }
  return NO;
}

- (BOOL)selectPreviousExpr:(id)context{
  SXZone *expr=[self getPreviousExpr:context];
  if (expr == nil){
    expr=[self getLastZone:context];
    while(expr && ![self isExpr:expr]){
      expr=[CJZoneTree previousZoneTo:expr];
    }
  }
  if (expr){
    [CJZoneTree setSelectiontoZone:expr withContext:context];
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
  if ([action caseInsensitiveCompare:@"next"] == 0){
    if ([self selectNextExpr:context]){
      return YES;
    }
  }
  else if ([action caseInsensitiveCompare:@"previous"] == 0){
    if ([self selectPreviousExpr:context]){
      return YES;
    }
  }
  return NO;
}

- (void)dealloc
{
	[super dealloc];
}

@end
