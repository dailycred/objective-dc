//
//  DCAuthViewController.m
//  objective-dc
//
//  Created by Hank Stoever on 12/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DCAuthViewController.h"

@interface DCAuthViewController ()

@end

@implementation DCAuthViewController
@synthesize loginField;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [loginField setFrame:CGRectMake(10, 100, 300, 30)];
        [passwordField setFrame:CGRectMake(10, 150, 300, 30)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLoginField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
