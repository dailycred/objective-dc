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
    return [self getJsonResponseWithHTTPMethod:@"GET"];
}

-(NSDictionary *)getJsonResponseWithHTTPMethod:(NSString *)method{
    return [self getJsonResponseWithHTTPMethod:method andError:nil];
}

-(NSDictionary *)getJsonResponseWithHTTPMethod:(NSString *)method andError:(NSError **)error{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:self];
    [request setHTTPMethod:method];
    //get response
    NSHTTPURLResponse* urlResponse = nil;
    NSError *urlError = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&urlError];
    if (urlError != nil){
        *error = urlError;
        return nil;
    }
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    id worked = [response objectForKey:@"worked"];
    if (worked != nil && ![worked boolValue]){
        NSLog(@"error from response: %@", response);
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        NSDictionary *responseError = [[response objectForKey:@"errors"] objectAtIndex:0];
        [details setValue:[responseError objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
        if ([responseError objectForKey:@"attribute"] != nil){
            [details setValue:[responseError objectForKey:@"attribute"] forKey:@"attribute"];
        }
        [details setValue:response forKey:@"json"];
        *error = [NSError errorWithDomain:@"dailycred" code:200 userInfo:details];
        return nil;
    }
    return response;
}
@end
