//
//  DCURLParser.h
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCURLParser : NSObject {
    NSArray *variables;
    NSArray *hashVariables;
}

@property (nonatomic, retain) NSArray *variables;
@property (nonatomic, retain) NSArray *hashVariables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;
- (NSString *)valueForHashVariable:(NSString *)varName;

@end
