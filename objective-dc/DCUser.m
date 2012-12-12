//
//  DCUser.m
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCUser.h"
#import "DCClient.h"

@implementation DCUser

@synthesize uuid, email, display, picture, identities, accessTokens, json;

-(DCUser *)initWithAccessToken:(NSString *)accessToken{
    NSDictionary *response = [[DCClient sharedClient] getUserJsonFromAccessToken:accessToken];
    self.uuid = [response objectForKey:@"id"];
    self.email = [response objectForKey:@"email"];
    self.display = [response objectForKey:@"display"];
    self.picture = [response objectForKey:@"picture"];
    self.identities = [response objectForKey:@"identities"];
    self.accessTokens = [response objectForKey:@"access_tokens"];
    self.json = response;
    return self;
}

-(BOOL)hasIdentity:(NSString *)provider{
    return NO;
}
-(NSDictionary *)getIdentityForProvider:(NSString *)provider{
    return [identities objectForKey:provider];
}

-(NSString *)getAccessTokenForProvider:(NSString *)provider{
    return [accessTokens objectForKey:provider];
}

-(NSString *)description{
    return self.display;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.display forKey:@"display"];
    [encoder encodeObject:self.picture forKey:@"picture"];
    [encoder encodeObject:self.uuid forKey:@"uuid"];
    [encoder encodeObject:self.identities forKey:@"identities"];
    [encoder encodeObject:self.accessTokens forKey:@"access_tokens"];
    [encoder encodeObject:self.json forKey:@"json"];
}

-(id)initWithCoder:(NSCoder *)decoder{
    if((self = [super init])) {
        self.picture = [decoder decodeObjectForKey:@"picture"];
        self.display = [decoder decodeObjectForKey:@"display"];
        self.uuid = [decoder decodeObjectForKey:@"uuid"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.identities = [decoder decodeObjectForKey:@"identities"];
        self.accessTokens = [decoder decodeObjectForKey:@"access_tokens"];
        self.json = [decoder decodeObjectForKey:@"json"];
    }
    return self;
}

@end
