//
//  CJExpr.m
//  clojure
//
//  Created by Eric on 12/10/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import "CJExpr.h"
#import "OnigRegexp.h"


@implementation CJExpr

@synthesize matchingRegex;
@synthesize matchingSelectors;

- (id) initWithRegex:(NSString *)regex Zones:(NSString *)zones
{
  matchingSelectors = zones ? [[SXSelectorGroup selectorGroupWithString:zones] retain] : NULL;
  matchingRegex=regex ? regex : NULL;
  return self;
}

// Return if the zone matches the regex specified in the xml
- (BOOL) matchRegex:(SXZone *)zone
{
  if (!matchingRegex){
    return YES;
  }
  if (zone && matchingRegex){
    OnigRegexp *regex = [OnigRegexp compile:matchingRegex ignorecase:YES multiline:YES];
    return [[regex search:[zone text]] count] > 0;
  }
  return NO;
}

// Return if the zone matches the ones specified in the xml
- (BOOL) matchZone:(SXZone *)zone
{
  if (!matchingSelectors){
    return YES;
  }
  if (zone && matchingSelectors != nil) {
    return [matchingSelectors matches:zone];
  }
  return NO;
}

// Return if zone is an expr or not
- (BOOL) isExpr:(SXZone *)zone
{
  if (!zone) return NO;
  return [self matchRegex:zone] && [self matchZone:zone];
}

// Return the expr at characterIndex
- (SXZone *) exprAt:(NSUInteger)characterIndex withContext:(id)context
{
  SXZone *zone=[[context syntaxTree] zoneAtCharacterIndex:characterIndex];
  while(zone && ![self isExpr:zone]){
    zone=[zone parent];
  }
  return zone;
}

// Returns the last child of zone.
- (SXZone *)lastChild:(SXZone *)zone{
  SXZone *z=nil;
  for (SXZone *i in zone){
    z=i;
  }
  return z;
}

// Returns the first child of zone.
- (SXZone *)firstChild:(SXZone *)zone
{
  for (SXZone *i in zone){
    return i;
  }
  return nil;
}

// Returns the next child in the child's parent.
- (SXZone *)nextSibling:(SXZone *)child
{
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
- (SXZone *)previousSibling:(SXZone *)child
{
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
- (SXZone *)nextZoneTo:(SXZone *)thisZone
{
  SXZone *child;
  if (child=[self firstChild:thisZone]){
    return child;
  }
  SXZone *parent=[thisZone parent];
  child=thisZone;
  while (parent && child==[self lastChild:parent]) {
    
    parent=[parent parent];
    child=[child parent];
  }
  return [self nextSibling:child];
}

// Returns the previous zone before the specified zone.
- (SXZone *)previousZoneTo:(SXZone *)thisZone
{
  SXZone *zone;
  if ((zone=[self previousSibling:thisZone])){
    while ([zone childCount] > 0){
      zone = [zone childAtIndex:[zone childCount]-1];
    }
    return zone;
  }
  return [thisZone parent];
}

// Returns the zone the current cursor is pointing at.
- (SXZone *) currentZone:(id)context
{
  NSRange range = [self currentRange:context];
  SXZone *zone = nil;
  if ([[context string] length] == range.location) {
    zone = [[context syntaxTree] rootZone];
  } else {
    zone = [[context syntaxTree] zoneAtCharacterIndex:range.location];
  }
  return zone;
}

// Returns the current selected range
- (NSRange) currentRange:(id)context
{
  return [[[context selectedRanges] objectAtIndex:0] rangeValue];
}

// Return the zone after the cursor
- (SXZone *) nextZone:(id)context
{
  NSRange range = [self currentRange:context];
  SXZone *zone =[self currentZone:context];
  while(zone && [zone range].location <= range.location){
    zone = [self nextZoneTo:zone];
  }
  return zone;
}

// Return the zone before the cursor
- (SXZone *) previousZone:(id)context
{
  return [self previousZoneTo:[self nextZone:context]];
}

- (SXZone *) parentExpr: (SXZone *) child
{
  child=[child parent];
  while(child && ![self isExpr:child]){
    child=[child parent];
  }
  return child;
}

- (SXZone *) topLevelExpr: (SXZone *)expr 
{
  while(expr && [self parentExpr:expr]!=nil){
    expr=[expr parent];
  }
  return expr;
}

- (BOOL) expr:(SXZone *)child isWithin: (SXZone *) ancestor
{
  while(child && child != ancestor) {
    child=[self parentExpr:child];
  }
  return child ? YES : NO;
}

- (NSArray *) childExprs:(SXZone *) expr
{
  NSMutableArray *children=[NSMutableArray arrayWithCapacity:4];
  SXZone *zone=expr;
  while(zone=[self nextZoneTo:zone]) {
    if ([self isExpr:zone]){
      if ([self parentExpr:zone] == expr) {
        [children addObject:zone];
      }
    }
    if (![self expr:zone isWithin:expr]) {
      break;
    }
  }
  return children;
}
// Return the next expr after the characterIndex
- (SXZone *) nextExprTo: (NSUInteger)characterIndex withContext:(id)context
{
  SXZone *thisExpr=[self exprAt:characterIndex withContext:context];
  thisExpr= thisExpr ? [self nextZoneTo:thisExpr] :  [self nextZone:context];
  while(thisExpr && (![self isExpr:thisExpr])){
    thisExpr = [self nextZoneTo:thisExpr];
  }
  return thisExpr;
}

// Return the previous expr after the characterIndex
- (SXZone *) previousExprTo: (NSUInteger)characterIndex  withContext:(id)context
{
  NSRange range = [self currentRange:context];
  SXZone *thisExpr=[self exprAt:characterIndex withContext:context];
  thisExpr=thisExpr ? [self previousZoneTo:thisExpr] : [self previousZone: context];
  while(thisExpr && (![self isExpr:thisExpr] 
                     || [thisExpr range].length==range.length 
                     && [thisExpr range].location==range.location )){
    thisExpr = [self previousZoneTo:thisExpr];
  }
  return thisExpr;
}

-(void) dealloc {
  [matchingSelectors release];
  [super dealloc];
}

@end
