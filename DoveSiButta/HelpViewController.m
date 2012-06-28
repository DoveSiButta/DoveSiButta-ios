//
//  HelpViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 29/03/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
    self.title = NSLocalizedString(@"Come funziona", @"");
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ok" style:UIBarButtonItemStyleBordered target:self action:@selector(closeHelp:)];

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

//Button actions

-(IBAction)closeHelp:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
