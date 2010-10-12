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
@synthesize special;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  action=[dictionary objectForKey:@"action"];
  special=[dictionary objectForKey:@"special"];
  exprs=[[CJExpr alloc] initWithRegex:NULL Zones:@"expression.list, collection"];
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

// Return how many indents there are on the line at characterIndex
- (NSUInteger)indentAtIndex:(NSUInteger)characterIndex withContext:(id)context
{
  NSString *string = [[context string] substringWithRange:[[context lineStorage] lineRangeForIndex:characterIndex]];
  NSInteger count=0;
  for (int i=0; i<[string length]; i++) {
    char c=[string characterAtIndex:i];
    if (c==' ') count++; else break;
  }
  return count;
}

// Figure out how many spaces needed to be inserted if the line broke at characterIndex
- (NSUInteger)toIndentAtIndex:(NSUInteger)characterIndex withContext:(id)context
{
  //NSUInteger currentIndent=[self indentAtIndex:characterIndex withContext:context];
  SXZone *expr = [exprs exprAt:characterIndex withContext:context];
  if (expr && ([expr range].location == characterIndex 
               || [expr range].location+[expr range].length == characterIndex)){
    expr=[exprs parentExpr:expr];
  }
  
  SXZone *top = [exprs topLevelExpr:expr];
  if (!top) top = [exprs topLevelExpr:[exprs previousExprTo: characterIndex withContext:context]];
  NSUInteger previousExprIndent = top ? [self indentAtIndex:[top range].location withContext:context] : 0;
  if (!expr) return previousExprIndent;
  previousExprIndent = [self indentAtIndex:[expr range].location withContext:context];
  
  NSUInteger exprsOnLineAndBeforeIndex=0;
  NSUInteger currentLine=[[context lineStorage] lineNumberForIndex:characterIndex];
  if (currentLine == [[context lineStorage] lineNumberForIndex:[expr range].location]) {
    exprsOnLineAndBeforeIndex--; // first element of list doesn't count; function call.
  }
  SXZone *prev=NULL;
  SXZone *firstOnLine=NULL; // first item on the same line as cursor that is part of expr
  SXZone *first=[expr childCount] > 1 ? [expr childAtIndex:1] : NULL;
  for (SXZone *child in expr){
    if (![[SXSelectorGroup selectorGroupWithString:@"delimiter"] matches:child]) {
      
      NSUInteger childLine=[[context lineStorage] lineNumberForIndex:[child range].location+[child range].length];
      if (childLine == currentLine) {
        if (firstOnLine == NULL){
          firstOnLine = child;
        }
        if ([child range].location+[child range].length <= characterIndex) {
          exprsOnLineAndBeforeIndex++;
        }
        prev= child;
      }
    }
  }
  OnigRegexp *regex = [OnigRegexp compile:[self special] ignorecase:YES multiline:NO];
  if ( [[SXSelectorGroup selectorGroupWithString:@"collection"] matches:expr]){
    // An array, dictionary, etc
    NSUInteger location = firstOnLine ? [firstOnLine range].location : [expr range].location + 1;
    NSUInteger line = [[context lineStorage] lineNumberForIndex:location];
    return location - [[context lineStorage] lineRangeForLineNumber:line].location;
  }
  else if (exprsOnLineAndBeforeIndex == 1 
           && (!firstOnLine || first && [[regex search:[first text]] count] == 0 )) {
    // An argument by itself, and not in special form like defn, indent same the argument
    NSUInteger location = [prev range].location;
    NSUInteger line = [[context lineStorage] lineNumberForIndex:location];
    return location - [[context lineStorage] lineRangeForLineNumber:line].location;
  }
  else if (exprsOnLineAndBeforeIndex != 0) {
    // A continuing line
    return 2 + previousExprIndent;
  }
  else if ([exprs exprAt:characterIndex withContext:context]){
    // blank line in the middle of expression
    return 2 + previousExprIndent; 
  }
  return previousExprIndent;
}

// Indent a new line
- (BOOL) indentNewLine:(id)context
{
  NSRange range = [exprs currentRange:context];
  NSUInteger numberOfSpaces=[self toIndentAtIndex:range.location withContext:context];
  
  CETextRecipe *recipe = [CETextRecipe textRecipe];
  NSMutableString* spaces=[NSMutableString stringWithString:@"\n"];
  for (int i=1; i<=numberOfSpaces; i++) {
    [spaces appendString:@" "];
  }
  [recipe addInsertedString:spaces forIndex:range.location];
  [context applyTextRecipe:recipe];
  return YES;
}


// Re-indent the selected text in context
- (BOOL) indentSelected:(id)context
{
  NSRange range = [exprs currentRange:context];
  NSRange rangeToIndent;
  rangeToIndent.location=[[context lineStorage] lineStartIndexLessThanIndex:range.location+1];
  rangeToIndent.length=[[context lineStorage] lineStartIndexGreaterThanIndex:range.location + range.length-1] - rangeToIndent.location;
  NSString *text=[[context string] substringWithRange:rangeToIndent];
  NSRange lineRange; lineRange.location=0; lineRange.length=0;
  NSLog(text);
  CETextRecipe *recipe = [CETextRecipe textRecipe];
  while (lineRange.location < [text length]){
    // Indent each line
    lineRange=[text lineRangeForRange:lineRange];
    NSUInteger lineIndex = rangeToIndent.location + lineRange.location;
    NSUInteger toIndent = [self toIndentAtIndex:lineIndex-1 withContext:context];
    NSUInteger originalIndent=[self indentAtIndex:lineIndex withContext:context];
    // Can't delete text... so if original indent is bigger, there's nothing we can do.
    if (toIndent > originalIndent){
      NSMutableString* spaces=[NSMutableString stringWithString:@""];
      for (int i = 0; i < toIndent - originalIndent; i++){
        [spaces appendString:@" "];
      }
      [recipe addInsertedString:spaces forIndex:lineIndex];
    }
    lineRange.location = lineRange.location + lineRange.length;
    lineRange.length=0;
  }
  [context applyTextRecipe:recipe];
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
    return [self indentNewLine:context];
  }
  if ([action caseInsensitiveCompare:@"indent_selected"] == 0){
    return [self indentSelected:context];
  }
  return NO;
}

- (void)dealloc
{
  [exprs release];
	[super dealloc];
}


@end
