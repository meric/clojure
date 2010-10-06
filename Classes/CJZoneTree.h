//
//  Clojure.h
//  clojure
//
//  Created by Eric on 28/09/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>

/*
 Usage
 <action></action> <!--Required-->
 <expression></expression> <!--Optional-->
 <zone></zone> <!--Optional-->
 <syntax-context> <!--Required-->
*/

@interface CJZoneTree : NSObject {
  NSString* syntaxContext;
  NSString* action;
  NSString* expression;
  NSString* matchingZone;
}

@property (readonly, copy) NSString* syntaxContext;
@property (readonly, copy) NSString* action;
@property (readonly, copy) NSString* expression;
@property (readonly, copy) NSString* matchingZone;

// Optional; called instead of -init if implemented.
// Dictionary contains the keys defined in the <setup> tag of action definitions. This is 
// how you can create generic item classes that behave differently depending on the 
// XML settings.
- (id)initWithDictionary:(NSDictionary *)dictionary bundlePath:(NSString *)bundlePath;

// Required: return whether or not the action can be performed on the context.
// It's recommended to keep this as lightweight as possible, since you're not the only 
// action in Espresso.
- (BOOL)canPerformActionWithContext:(id)context;

// Required: actually perform the action on the context.
// If an error occurs, pass an NSError via outError (warning: outError may be NULL!)
- (BOOL)performActionWithContext:(id)context error:(NSError **)outError;

- (BOOL) matchRegex:(SXZone *)zone;
- (BOOL) matchZone:(SXZone *)zone;

- (BOOL) isExpr:(SXZone *)zone;

+ (void) setSelection:(NSRange) range withContext:(id)context;
+ (void) setSelectiontoZone:(SXZone *)zone withContext:(id)context;

+ (void) moveCursorToZone:(SXZone *)zone withContext:(id)context;
+ (BOOL) range:(NSRange)range1 equals:(NSRange) range2;

+ (SXZone *)currentZoneInContext:(id)context;

+ (SXZone *) lastChild:(SXZone *)zone;
+ (SXZone *) firstChild: (SXZone *)zone;

+ (SXZone *) nextSibling:(SXZone *)child;
+ (SXZone *) previousSibling:(SXZone *)child;

+ (SXZone *) nextZoneTo:(SXZone *)thisZone;
+ (SXZone *) previousZoneTo:(SXZone *)thisZone;

+ (SXZone *) getNextZone:(id)context;
+ (SXZone *) getPreviousZone:(id)context;

- (SXZone *) getLastZone:(id)context;
- (SXZone *) getFirstZone:(id)context;

- (SXZone *) getExpr:(id)context;
- (SXZone *) getNextExpr:(id)context;
- (SXZone *) getPreviousExpr:(id)context;

- (BOOL) selectNextExpr:(id)context;
- (BOOL) selectPreviousExpr:(id)context;

@end
