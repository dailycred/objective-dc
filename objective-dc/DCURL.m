//
//  DCURL.m
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCURL.h"

@implementation DCURL
- (DCURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    DCURL *theURL = [DCURL URLWithString:URLString];
    return theURL;
}

- (DCURL *)URLbyAppendingParameterWithKey:(NSString *)key andValue:(NSString *)value{
    return [self URLByAppendingQueryString:[NSString stringWithFormat:@"%@=%@", key, value]];
}

-(NSDictionary *)getJsonResponse{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:self];
    //get response
    NSHTTPURLResponse* urlResponse = nil;  
    NSError *error = [[NSError alloc] init];  
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    NSDictionary* results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    return results;
}
@end
