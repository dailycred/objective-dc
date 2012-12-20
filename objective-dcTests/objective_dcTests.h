//
//  objective_dcTests.h
//  objective-dcTests
//
//  Created by Hank Stoever on 12/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "DCUser.h"
#import "DCClient.h"

@interface objective_dcTests : SenTestCase{
    DCClient *dailycred;
    DCClient *badClient;
}

@end
