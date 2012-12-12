//
//  DCURL.h
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCURL : NSURL
-(DCURL *)URLByAppendingQueryString:(NSString *)queryString;
-(DCURL *)URLbyAppendingParameterWithKey:(NSString *)key andValue:(NSString *)value;
-(NSDictionary *)getJsonResponse;
@end
