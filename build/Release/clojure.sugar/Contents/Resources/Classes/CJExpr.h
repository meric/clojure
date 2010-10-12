//
//  CJExpr.h
//  clojure
//
//  Created by Eric on 12/10/10.
//  Copyright 2010 Sydney University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EspressoTextActions.h>
#import <EspressoSyntaxCore.h>


@interface CJExpr : NSObject {
  NSString* matchingRegex;
  SXSelectorGroup* matchingSelectors;
}

@property (readonly, copy) NSString* matchingRegex;
@property (readonly, copy) SXSelectorGroup* matchingSelectors;

- (id) initWithRegex:(NSString *)regex Zones:(NSString *)zones;
- (BOOL) isExpr:(SXZone *)zone;
- (BOOL) expr:(SXZone *)child isWithin: (SXZone *) ancestor;
- (SXZone *) currentZone:(id)context;
- (NSRange) currentRange:(id)context;
- (SXZone *) parentExpr: (SXZone *) child;
- (SXZone *) topLevelExpr: (SXZone *)expr;
- (NSArray *) childExprs:(SXZone *)expr;
- (SXZone *) exprAt:(NSUInteger)characterIndex withContext:(id)context;
- (SXZone *) nextZone:(id)context;
- (SXZone *) nextExprTo: (NSUInteger)characterIndex withContext:(id)context;
- (SXZone *) previousZone:(id)context;
- (SXZone *) previousExprTo: (NSUInteger)characterIndex withContext:(id)context;

@end
