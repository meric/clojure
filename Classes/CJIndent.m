//
//  CJIndent.m
//  clojure
//
//  Created by Eric on 6/10/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import "CJIndent.h"
#import "OnigRegexp.h"
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>
#import <EspressoTextCore.h>


@implementation CJIndent
@synthesize syntaxContext;
@synthesize action;
@synthesize matchingZone;
@synthesize expression;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  action=[dictionary objectForKey:@"action"];
  return self;
}

// Returns the zone the current cursor is pointing at.
+ (SXZone *)currentZoneInContext:(id)context
{
  // Get the zone the cursor is at
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  SXZone *zone = nil;
  if ([[context string] length] == range.location) {
    zone = [[context syntaxTree] rootZone];
  } else {
    zone = [[context syntaxTree] zoneAtCharacterIndex:range.location];
  }
  return zone;
}

+ (SXZone *)selector:(NSString*) selector matchesZone:(SXZone *)zone {
  // Find if the zone inherits from a selector specified zone
  // return that ancestor
  SXSelectorGroup *selectors = [SXSelectorGroup selectorGroupWithString:selector];
  while (zone && ![selectors matches:zone]){
    zone=[zone parent];
  }
  if (zone && [selectors matches:zone]) {
    return zone;
  }
  return nil;
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
    if (![CJIndent selector:syntaxContext matchesZone:[CJIndent currentZoneInContext: context]]){
      return NO;
    }
	}
	return YES;
}

+ (NSInteger) indentLevel:(NSString *)text{
  // Find the indentlevel of the string text
  NSInteger count=0;
  for (int i=0; i<=[text length]; i++) {
    char c=[text characterAtIndex:i];
    if (c==' '){
      count++;
    }
    else{
      break;
    }
  }
  return count;
}

+ (NSInteger) lineNumberForZone: (SXZone*)zone withContext:(id)context{
  // Get the line number for a zone
  return [[context lineStorage] lineNumberForIndex:[zone range].location];
}

+ (NSInteger) lineNumberAtIndex:(NSInteger)index withContext:(id)context {
  // Get the line number at index
  return [[context lineStorage] lineNumberForIndex:index];
}

+ (NSInteger) cursorLineNumber:(id)context {
  // Get the current Line number
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  return [CJIndent lineNumberAtIndex:range.location withContext:context];
}

+ (NSString *)textOfLine:(NSInteger)lineNumber withContext:(id)context {
  // Get the string of line lineNumber.
  NSRange range=[[context lineStorage] lineRangeForLineNumber:lineNumber];
  return [[context string] substringWithRange:range];
}

+ (void)indentNewLine:(NSUInteger)numberOfSpaces withContext:(id)context {
  // indent a new line with numberOfSpaces spaces
  NSRange lineRange=[[[context selectedRanges] objectAtIndex:0] rangeValue];
  CETextRecipe *recipe = [CETextRecipe textRecipe];
  NSMutableString* spaces=[NSMutableString stringWithCapacity:numberOfSpaces];
  [spaces appendString:@"\n"];
  for (int i=1; i<=numberOfSpaces; i++) {
    [spaces appendString:@" "];
  }
  [recipe addInsertedString:spaces forIndex:lineRange.location];
  [context applyTextRecipe:recipe];
}


+ (NSInteger)indentToExpr:(SXZone*)expr withContext:(id)context{
  // If it is an (...), indent like
  /*  
   * (if true
   *     false
   *     (println "hey"))
   */
  // or like this, if the previous line has more than one arg
  /*  
   * (defn helloworld [] ; has helloworld and [] as arguments
   *   (println "hello world"))
   *     
   */
  NSInteger lineNumber=[CJIndent cursorLineNumber:context];
  SXZone *prev=nil;
  NSInteger count_on_current_line=0;
  NSInteger count_on_expr_line=0;
  
  for (SXZone *child in expr){
    if ([CJIndent lineNumberForZone:child withContext:context]==[CJIndent lineNumberForZone:expr withContext:context]
        && ![CJIndent selector:@"delimiter" matchesZone:child] && child!=[expr childAtIndex:1]){
      prev=child;
      count_on_expr_line++;
    }
    if (([CJIndent lineNumberForZone:child withContext:context]==lineNumber) 
        && ![CJIndent selector:@"delimiter" matchesZone:child] && child!=[expr childAtIndex:1]){
      prev=child;
      count_on_current_line++;
      count_on_expr_line = 0;
    }
  }
  NSInteger count = count_on_current_line+count_on_expr_line;
  
  BOOL empty=[CJIndent selector:@"delimiter" matchesZone:[expr childAtIndex:0]] && [expr childCount] > 2 && [CJIndent selector:@"delimiter" matchesZone:[expr childAtIndex:2]];
  if (prev == nil || [expr childCount] <= 2 || empty || count >= 2){
    NSInteger indent=[CJIndent indentLevel:[CJIndent textOfLine:[CJIndent lineNumberAtIndex:[expr range].location withContext:context] withContext:context]]+2;
    return indent;
  }
  else {
    NSInteger toDelim=[prev range].location - [[context lineStorage] lineRangeForIndex:[prev range].location].location;
    return toDelim;
  }
}

+ (NSInteger)indentToCollection:(SXZone*)literal withContext:(id)context{
  // If it is an [...], #{...} etc, indent like
  /*
   * #{1
   *   2
   *   3}
   */
  NSInteger lineNumber=[CJIndent cursorLineNumber:context];
  NSInteger toDelim=[literal range].location - [[context lineStorage] lineRangeForIndex:[literal range].location].location;
  NSInteger modifier=[[literal childAtIndex:0] range].length;
  if ([CJIndent lineNumberAtIndex:[literal range].location+[literal range].length withContext:context] == lineNumber){
    modifier=0;
  }
  return toDelim+modifier;
}

+ (BOOL) indentNewLine:(id)context{
  NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
  
  SXZone *literal=[CJIndent selector:@"collection" matchesZone:[[context syntaxTree] zoneAtCharacterIndex:range.location]];
  
  if (literal){
    [CJIndent indentNewLine:[CJIndent indentToCollection:literal withContext:context] withContext:context];
    return YES;
  }
  
  SXZone *expr=[CJIndent selector:@"expression.list" matchesZone:[[context syntaxTree] zoneAtCharacterIndex:range.location]];

  if (expr){
    [CJIndent indentNewLine:[CJIndent indentToExpr:expr withContext:context] withContext:context];
    return YES;
  }
  
  [CJIndent indentNewLine:0 withContext:context];
  return YES;
}

// Required: actually perform the action on the context.
// If an error occurs, pass an NSError via outError (warning: outError may be NULL!)
- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
  if ([self action] == nil) {
		NSLog(@"Clojure.sugar Error: Missing action tag in XML");
		return NO;
	}
  if ([action caseInsensitiveCompare:@"indent_newline"] == 0){
    return [CJIndent indentNewLine:context];
  }
  // TODO: indent a selection.
  return NO;
}


@end
