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


@interface CJZoneTree : NSObject {
  NSString* syntaxContext;
  NSString* action;
  NSString* expression;
}


typedef enum {
  CJDFS = 0,
  CJBFS= 1,
} CJTreeSearchType;

@property (readonly, copy) NSString* syntaxContext;
@property (readonly, copy) NSString* action;
@property (readonly, copy) NSString* expression;

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

- (BOOL) isExpr:(SXZone *)zone;
- (SXZone *) findExpr:(SXZone *)zone;
- (SXZone *) getExpr:(id) context;
- (SXZone *) parentExpr:(SXZone *)zone;
- (NSArray *) childrenExpr:(SXZone *)zone;
- (SXZone *) nextExprDFS:(SXZone *)zone;
- (SXZone *) previousExprDFS:(SXZone *)zone;
- (SXZone *) nextExprBFS:(SXZone *)zone;
- (SXZone *) previousExprBFS:(SXZone *)zone;

@end
