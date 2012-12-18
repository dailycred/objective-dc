//
//  DCClient.m
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 Dailycred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCClient.h"
#import "DCURL.h"
#import "DCURLParser.h"

@implementation DCClient

NSString* const kAuthEndpoint = @"/oauth/authorize";
NSString* const kAccessTokenEndpoint = @"/oauth/access_token";
NSString* const kConnectEndpoint = @"/connect";
NSString* const kMeJsonEndpoint = @"/graph/me.json";
NSString* const kGatewayEndpoint = @"/oauth/gateway";
NSString* const kCurrentUserKey = @"dc_current_user";
NSString* const kSigninEndpoint = @"/user/api/signin.json";
NSString* const kSignupEndpoint = @"/user/api/signup.json";

static DCClient *instance = nil;
static DCUser *currentUser = nil;

@synthesize clientId, clientSecret, redirectUri, baseUri, identityProviders;

+(DCClient*) initWithClientId:(NSString*) aClientId andClientSecret:(NSString*)aClientSecret withRedirectUri:(NSString *)redirectUri{
    DCClient *client = [DCClient sharedClient];
    client.clientId = aClientId;
    client.clientSecret = aClientSecret;
    client.redirectUri = redirectUri;
    client.baseUri = @"https://www.dailycred.com";
    client.identityProviders = [[NSArray alloc] initWithObjects:@"github",@"facebook",@"google",@"twitter",@"email", nil];
    return client;
}

-(void) authorize{
    DCURL *url = [self getAuthURLFromEndpoint:kGatewayEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"client_id" andValue:clientId];
    if (redirectUri != nil){
        url = [url URLbyAppendingParameterWithKey:@"redirect_uri" andValue:redirectUri];
    }
    [[UIApplication sharedApplication] openURL: url];
}

-(void) authorizeWithIdentityProvider:(NSString *)identityProvider{
    DCURL *url = [self getAuthURLFromEndpoint:kConnectEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"identity_provider" andValue:[identityProvider lowercaseString]];
    [[UIApplication sharedApplication] openURL: url];
}

-(void)connectUser:(DCUser *)user withIdentityProvider:(NSString *)identityProvider{
    DCURL *url = [self getAuthURLFromEndpoint:kConnectEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"identity_provider" andValue:[identityProvider lowercaseString]];
    url = [url URLbyAppendingParameterWithKey:@"access_token" andValue:[user getAccessTokenForProvider:@"dailycred"]];
    [[UIApplication sharedApplication] openURL: url];
}


-(void) authenticateWithCallbackUrl:(NSString *) callback{
    DCURLParser *parser = [[DCURLParser alloc] initWithURLString:callback];
    NSString *accessToken = [parser valueForHashVariable:@"access_token"];
    NSLog(@"access token is %@", accessToken);
    [DCClient setCurrentUser: [[DCUser alloc] initWithAccessToken:accessToken]];
}

+(DCClient *)sharedClient{
    @synchronized(self)    
    {    
        if(instance==nil)    
        {    
            
            instance= [DCClient new];    
        }    
    }    
    return instance;   
}

-(NSString *)getAccessTokenFromCode:(NSString *)code{
    DCURL *url = [self getURLFromEndpoint:kAccessTokenEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"code" andValue:code];
    url = [url URLbyAppendingParameterWithKey:@"client_secret" andValue:clientSecret];
    NSDictionary* results = [url getJsonResponse];
    NSString *accessToken = [results objectForKey:@"access_token"];
        
    return accessToken;
}

                                    
-(NSDictionary *)getUserJsonFromAccessToken:(NSString *)accessToken{
    DCURL *url = [self getURLFromEndpoint:kMeJsonEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"access_token" andValue:accessToken];
    return [url getJsonResponse];
}

-(DCUser *)signinUserWithLogin:(NSString *)login andPassword:(NSString *) password andError:(NSError **)error{
    DCURL *url = [self getAuthURLFromEndpoint:kSigninEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"login" andValue:login];
    url = [url URLbyAppendingParameterWithKey:@"pass" andValue:password];
    NSError *newError = nil;
    NSDictionary *response = [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
        return nil;
    }
    DCUser *user = [[DCUser alloc] initWithDictionary:[response objectForKey:@"user"]];
    [DCClient setCurrentUser:user];
    return user;
}

-(DCUser *)signupOrSigninUserWithLogin:(NSString *)login andPassword:(NSString *) password andError:(NSError **)error{
    DCURL *url = [self getAuthURLFromEndpoint:kSignupEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"email" andValue:login];
    url = [url URLbyAppendingParameterWithKey:@"pass" andValue:password];
    NSError *newError = nil;
    NSDictionary *response = [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
        return nil;
    }
    DCUser *user = [[DCUser alloc] initWithDictionary:[response objectForKey:@"user"]];
    [DCClient setCurrentUser:user];
    return user;
}

-(DCURL *)getAuthURLFromEndpoint:(NSString *)endpoint{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseUri,endpoint];
    DCURL *url = [DCURL URLWithString: urlString];
    url = [url URLbyAppendingParameterWithKey:@"client_id" andValue:clientId];
    if (redirectUri != nil){
        url = [url URLbyAppendingParameterWithKey:@"redirect_uri" andValue:redirectUri];
    }
    url = [url URLbyAppendingParameterWithKey:@"response_type" andValue:@"token"];
    return url;
}

-(DCURL *)getURLFromEndpoint:(NSString *)endpoint{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseUri,endpoint];
    return [DCURL URLWithString: urlString];
}



+(DCUser *)getCurrentUser{
    if (currentUser == nil){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSData *userData = [prefs objectForKey:kCurrentUserKey];
        if (userData != nil){
            currentUser = (DCUser *)[NSKeyedUnarchiver unarchiveObjectWithData:userData];
        }
    }
    return currentUser;
}

+(void)setCurrentUser:(DCUser *)user{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [prefs setObject:userData forKey:kCurrentUserKey];
    currentUser = user;
}

+(void)logout{
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kCurrentUserKey];
    currentUser = nil;
}

@end
