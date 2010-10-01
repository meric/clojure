//
//  Clojure.m
//  clojure
//
//  Created by Eric on 28/09/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import "CLJTraverse.h"
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>

@implementation CLJTraverse

@synthesize syntaxContext;
@synthesize undoName;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath
{
  syntaxContext=[dictionary objectForKey:@"syntax-context"];
  undoName=[dictionary objectForKey:@"undo_name"];
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
		NSRange range = [[[context selectedRanges] objectAtIndex:0] rangeValue];
		SXSelectorGroup *selectors = [SXSelectorGroup selectorGroupWithString:[self syntaxContext]];
		SXZone *zone = nil;
		if ([[context string] length] == range.location) {
			zone = [[context syntaxTree] rootZone];
		} else {
			zone = [[context syntaxTree] zoneAtCharacterIndex:range.location];
		}
		if (![selectors matches:zone]) {
			return NO;
		}
	}
	return YES;
}

// Required: actually perform the action on the context.
// If an error occurs, pass an NSError via outError (warning: outError may be NULL!)
- (BOOL)performActionWithContext:(id)context error:(NSError **)outError
{
	return FALSE;
}
@end
