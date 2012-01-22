//
//  PictureFileViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "PictureFileViewController.h"
#import "ASIHTTPRequest.h"

@implementation PictureFileViewController
@synthesize imageView,selectedItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Data items

- (void) getPictureFile
{
    
    //http://c0061e8a94b24692b9f5c2fff622b38c.cloudapp.net/Services/Odata.svc/GetFile=1

    /*
    //http://stackoverflow.com/questions/5445106/asihttp-asynchrounous-pdf-download
    // SAVED PDF PATH
    // Get the Document directory
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // Add your filename to the directory to create your saved pdf location
    NSString *pdfLocation = [documentDirectory stringByAppendingPathComponent:@"test.pdf"];
    
    // TEMPORARY PDF PATH
    // Get the Caches directory
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // Add your filename to the directory to create your temp pdf location
    NSString *tempPdfLocation = [cachesDirectory stringByAppendingPathComponent:@"test.pdf"];
    
    // Tell ASIHTTPRequest where to save things:
    [request setTemporaryFileDownloadPath:tempPdfLocation];     
    [request setDownloadDestinationPath:pdfLocation]; 
    
    // If you've stored documentDirectory or pdfLocation somewhere you won't need one or both of these lines
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pdfLocation = [documentDirectory stringByAppendingPathComponent:@"test.pdf"];
    
    // Now tell your UIWebView to load that file
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfLocation]]];
    */
    
//    NSData *fileData =  [NSData dataWithBase64EncodedString:[result objectForKey:@"FileByte"] ];
    //        NSLog(@"GetFileProfileByDocumentId returned the file: %@", [result objectForKey:@"FileByte"]);
    NSString *fileprofile = (NSString*)[result objectForKey:@"GetFileProfileByDocumentIdResult"];
    NSLog(@"FileProfile: %@", fileprofile);
    NSArray *fileprofileArr = PerformXMLXPathQuery([fileprofile dataUsingEncoding:NSUTF8StringEncoding],@"//FILENAME");
    NSString *filename = [[fileprofileArr objectAtIndex:0] objectForKey:@"nodeContent"];
    NSLog(@"GetFileProfileByDocumentId returned the filename: %@",  filename);
    
    
    // Get the Document directory
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // Add your filename to the directory to create your saved pdf location
    NSString *fileLocation = [documentDirectory stringByAppendingPathComponent:filename];
    NSURL *fileURL = [NSURL fileURLWithPath:fileLocation];

}


#pragma mark - View lifecycle

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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
