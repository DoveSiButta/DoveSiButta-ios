//
//  NoConnectionViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 12/06/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "NoConnectionViewController.h"

@interface NoConnectionViewController ()

@end

@implementation NoConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(DeviceIsPad())
    {
        return YES;
    }
    else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

@end
