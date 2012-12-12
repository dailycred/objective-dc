//
//  DCClient.m
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
    NSString *code = [parser valueForVariable:@"code"];
    NSString *accessToken = [self getAccessTokenFromCode:code];
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

-(DCURL *)getAuthURLFromEndpoint:(NSString *)endpoint{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",baseUri,endpoint];
    DCURL *url = [DCURL URLWithString: urlString];
    url = [url URLbyAppendingParameterWithKey:@"client_id" andValue:clientId];
    if (redirectUri != nil){
        url = [url URLbyAppendingParameterWithKey:@"redirect_uri" andValue:redirectUri];
    }
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
