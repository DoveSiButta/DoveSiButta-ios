//
//  ChiSiamoViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 24/02/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "ChiSiamoViewController.h"

@interface ChiSiamoViewController ()

@end

@implementation ChiSiamoViewController
@synthesize labelProdName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Chi siamo", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"59-info"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Top button (Help button)
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleBordered target:self action:@selector(showHelp:)] autorelease];
    
    //Bundle info
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    self.labelProdName.text = [NSString stringWithFormat:@"DoveSiButta v. %@ Build #%@",[info objectForKey:@"CFBundleShortVersionString"],[info objectForKey:@"CFBundleVersion"]] ;
}

- (void)viewDidUnload
{
    [self setLabelProdName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [labelProdName release];
    [super dealloc];
}
@end
