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
    key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    
    value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedParameter = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)value,NULL,(CFStringRef)@"!*'();@&+$,/?%#[]~=_-.:",kCFStringEncodingUTF8 );
    return [self URLByAppendingQueryString:[NSString stringWithFormat:@"%@=%@", key, encodedParameter]];
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
    if (worked != nil && ![worked boolValue] && error != nil){
        NSLog(@"error during request %@ from response: %@", self, response);
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        NSDictionary *responseError = [[response objectForKey:@"errors"] objectAtIndex:0];
        [details setValue:[responseError objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
        if ([responseError objectForKey:@"attribute"] != nil){
            NSString *attribute = [responseError objectForKey:@"attribute"];
            [details setValue:attribute forKey:@"attribute"];
        }
        [details setValue:[response description] forKey:@"json"];
        NSLog(@"error details: %@", details);
        *error = [NSError errorWithDomain:@"dailycred" code:200 userInfo:details];
        return nil;
    }
    return response;
}

-(NSString *)description{
    NSString *fullUrl = [self absoluteString];
    return [NSString stringWithFormat:@"%@%@", fullUrl, [self parameterString]];
}
@end
