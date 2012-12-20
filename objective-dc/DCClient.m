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
NSString* const kResetPasswordEndpoint = @"/password/api/reset";
NSString* const kChangePasswordEndpoint = @"/password/api/change";
NSString* const kFireEventEndpoint = @"/admin/api/customevent.json";
NSString* const kTagUserEndpoint = @"/admin/api/user/tag.json";
NSString* const kUntagUserEndpoint = @"/admin/api/user/untag.json";

static DCClient *instance = nil;
static DCUser *currentUser = nil;

@synthesize clientId = _clientId, clientSecret = _clientSecret, redirectUri = _redirectUri, baseUri = _baseUri, identityProviders = _identityProviders;

-(DCClient *)initWithClientId:(NSString *)clientId andClientSecret:(NSString *)clientSecret withRedirectUri:(NSString *)redirectUri{
    return [[[DCClient alloc] init] buildClientWithId:clientId andSecret:clientSecret andRedirectUri:redirectUri];
}

#pragma mark authentication methods

-(void) authorize{
    DCURL *url = [self getAuthURLFromEndpoint:kGatewayEndpoint];
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

#pragma mark authentication helpers


-(void) authenticateWithCallbackUrl:(NSString *) callback{
    DCURLParser *parser = [[DCURLParser alloc] initWithURLString:callback];
    NSString *accessToken = [parser valueForHashVariable:@"access_token"];
    NSLog(@"access token is %@", accessToken);
    [DCClient setCurrentUser: [[DCUser alloc] initWithAccessToken:accessToken]];
}

-(NSString *)getAccessTokenFromCode:(NSString *)code{
    DCURL *url = [self getURLFromEndpoint:kAccessTokenEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"code" andValue:code];
    url = [url URLbyAppendingParameterWithKey:@"client_secret" andValue:_clientSecret];
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

#pragma mark url helpers

-(DCURL *)getAuthURLFromEndpoint:(NSString *)endpoint{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",_baseUri,endpoint];
    DCURL *url = [DCURL URLWithString: urlString];
    url = [url URLbyAppendingParameterWithKey:@"client_id" andValue:_clientId];
    if (_redirectUri != nil){
        url = [url URLbyAppendingParameterWithKey:@"redirect_uri" andValue:_redirectUri];
    }
    url = [url URLbyAppendingParameterWithKey:@"response_type" andValue:@"token"];
    return url;
}

-(DCURL *)getURLFromEndpoint:(NSString *)endpoint{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",_baseUri,endpoint];
    return [DCURL URLWithString: urlString];
}

-(DCURL *)getUserUrlFromEndpoint:(NSString *)endpoint forUser:(DCUser *)user{
    DCURL *url = [self getURLFromEndpoint:endpoint];
    url = [url URLbyAppendingParameterWithKey:@"client_id" andValue: _clientId];
    url = [url URLbyAppendingParameterWithKey:@"client_secret" andValue: _clientSecret];
    return [url URLbyAppendingParameterWithKey:@"user_id" andValue: user.uuid];
}

#pragma mark password methods

-(void)resetPasswordForUser:(DCUser *)user andError:(NSError **)error{
    DCURL *url = [self getUserUrlFromEndpoint:kResetPasswordEndpoint forUser:user];
    NSError *newError = nil;
    [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
    }
}

-(void)changePasswordFrom:(NSString *)oldPass to:(NSString *)newPass forUser:(DCUser *)user withError:(NSError **)error{
    DCURL *url = [self getUserUrlFromEndpoint:kChangePasswordEndpoint forUser:user];
    url = [url URLbyAppendingParameterWithKey:@"pass_curr" andValue:oldPass];
    url = [url URLbyAppendingParameterWithKey:@"pass_new" andValue:newPass];
    NSError *newError = nil;
    [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
    }
}

#pragma mark event methods

-(void)fireEventWithEventType:(NSString *)eventType forUser:(DCUser *)user withValue:(NSString *)value andError:(NSError *__autoreleasing *)error{
    DCURL *url = [self getUserUrlFromEndpoint:kFireEventEndpoint forUser:user];
    url = [url URLbyAppendingParameterWithKey:@"key" andValue:eventType];
    if (value != nil){
        url = [url URLbyAppendingParameterWithKey:@"valuestring" andValue:value];
    }
    NSError *newError = nil;
    [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
    }
}

#pragma mark tagging methods

-(void)tagUserWithTag:(NSString *)tag forUser:(DCUser *)user andError:(NSError **)error{
    DCURL *url = [self getUserUrlFromEndpoint:kTagUserEndpoint forUser:user];
    url = [url URLbyAppendingParameterWithKey:@"tag" andValue:tag];
    NSError *newError = nil;
    [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
    }
}

-(void)untagUserWithTag:(NSString *)tag forUser:(DCUser *)user andError:(NSError **)error{
    DCURL *url = [self getUserUrlFromEndpoint:kUntagUserEndpoint forUser:user];
    url = [url URLbyAppendingParameterWithKey:@"tag" andValue:tag];
    NSError *newError = nil;
    [url getJsonResponseWithHTTPMethod:@"POST" andError:&newError];
    if (newError != nil){
        *error = newError;
    }
}

#pragma mark static methods

+(DCClient*) initWithClientId:(NSString*) clientId andClientSecret:(NSString*)clientSecret withRedirectUri:(NSString *)redirectUri{
    DCClient *client = [DCClient sharedClient];
    client = [client buildClientWithId:clientId andSecret:clientSecret andRedirectUri:redirectUri];
    return client;
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


#pragma mark client builder

-(DCClient *)buildClientWithId:(NSString *)clientId andSecret:(NSString *)clientSecret andRedirectUri:(NSString *)redirectUri{
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    self.redirectUri = redirectUri;
    self.baseUri = @"https://www.dailycred.com";
    self.identityProviders = [[NSArray alloc] initWithObjects:@"github",@"facebook",@"google",@"twitter",@"email", nil];
    return self;
}




@end
