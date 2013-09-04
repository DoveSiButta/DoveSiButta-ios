//
//  PictureFileViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "PictureFileViewController.h"
#import "ASIHTTPRequest.h"
//#import <regex.h>
//XPathQuery
#import "XPathQuery.h"

//OData
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"
//Service
//#import "NerdDinnerEntities.h"
#import "DoveSiButtaEntities.h"

//HUD
#import "SVProgressHUD.h"

#import "NSData+Base64.h"

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



/*
// searchIPAddressFrom
// search IP address from the passed sourceString
//
// returns a found string in NSString form.
//			nil, if not found
- (NSString *)searchRegexFrom:(NSString *)sourceString
{
	int isFail;
	
	char *regexPattern = "Node{+(?<id>[0-9]*)+}data_{+(?<name>[a-zA-Z]*)}key"; // For IP address
	
	regex_t regex;
	regmatch_t pmatch[5]; // track up to 5 maches. Actually only one is needed.
	
	const char *sourceCString;
	char errorMessage[512], foundCString[16];
	
	NSString *errorMessageString;
	NSString *foundString = nil;
	
	sourceCString = [sourceString UTF8String];
	
	// setup the regular expression
	
	@try{
		
		NSException *exception;
		
		if( isFail = regcomp(&regex, regexPattern, REG_EXTENDED) )
		{
			regerror(isFail, &regex, errorMessage, 512);
			errorMessageString = [NSString stringWithCString:errorMessage];
			
			exception = [NSException exceptionWithName:@"RegexException" 
												reason:errorMessageString 
											  userInfo:nil];
			@throw exception;
		}
		else
		{
			if( isFail = regexec( &regex, sourceCString, 5, pmatch, 0 ) )
			{
				regerror( isFail, &regex, errorMessage, 512 );
				errorMessageString = [NSString stringWithCString:errorMessage];
				exception = [NSException exceptionWithName:@"RegexException"
													reason:errorMessageString
												  userInfo:nil];
				@throw exception;
			}
			else
			{
				snprintf( foundCString, pmatch[0].rm_eo - pmatch[0].rm_so + 1, 
						 "%s", &sourceCString[pmatch[0].rm_so] );
				
				foundString = [NSString stringWithCString:foundCString];
			}
		}
	}
	@catch( NSException *caughtException ) {
		NSLog(@"%@ occurred due to %@", [caughtException name], [caughtException reason]);
	}
	@finally {
		regfree(&regex);		
	}	
	
	return foundString;
}
*/

#pragma mark - Data items

- (void) getPictureFile
{    
    
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
    NSString *picturesURI = [defaults objectForKey:@"picturesURI"];
    DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
    /* //OLD METHOD
     //1- Get dinner with ID
    NSString *odataResult = [[proxy GetFileWithitemid:self.selectedItem] retain];
    odataResult = [[odataResult stringByReplacingOccurrencesOfString:@"xmlns=\"http://schemas.microsoft.com/ado/2007/08/dataservices\"" withString:@"" ] stringByReplacingOccurrencesOfString:@"standalone=\"true\"" withString:@""];
    
    //
//    <?xml version="1.0" encoding="UTF-8" standalone="true"?>
//    <GetFile xmlns="http://schemas.microsoft.com/ado/2007/08/dataservices">/Pictures/nippon_sun_by_mcdeesh.jpg</GetFile>
//    NSString *fileRemotePath = [self searchRegexFrom:odataResult];


    NSArray *prova = PerformXMLXPathQuery([odataResult dataUsingEncoding:NSASCIIStringEncoding], @"/GetFile");
    NSString *fileRemotePath = [[prova objectAtIndex:0] objectForKey:@"nodeContent"];
//    NSString *odataResult = [[proxy GetFileWithdinnerid:self.selectedItem] retain];
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression         
//                                  regularExpressionWithPattern:@"Node{+(?<id>[0-9]*)+}data_{+(?<name>[a-zA-Z]*)}key"
//                                  options:NSRegularExpressionCaseInsensitive
//                                  error:&error];
//    [regex enumerateMatchesInString:odataResult options:0 range:NSMakeRange(0, [odataResult length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
//        // your code to handle matches here
//        fileRemotePath = match;
//    }];
    NSString *fileName = [fileRemotePath lastPathComponent];
    NSLog(@"fileRemotePath %@", fileRemotePath);
    NSLog(@"fileName %@", fileName);    
    //    NSArray *resultArr = [[proxy FindUpcomingDinners] retain]; //??? Returns no results as of 2012-01-12
    //        NSArray *resultArr =[[proxy GetMostRecentDinners] retain]; //Method with custom OData Query


    
    
    //http://c0061e8a94b24692b9f5c2fff622b38c.cloudapp.net/Services/Odata.svc/GetFile=1

    
    //http://stackoverflow.com/questions/5445106/asihttp-asynchrounous-pdf-download
    // SAVED PDF PATH
    // Get the Document directory
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // Add your filename to the directory to create your saved pdf location
    NSString *fileLocation = [documentDirectory stringByAppendingPathComponent:@"prova.jpg"];
    
    // TEMPORARY PDF PATH
    // Get the Caches directory
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // Add your filename to the directory to create your temp pdf location
    NSString *tempFileLocation = [cachesDirectory stringByAppendingPathComponent:@"prova.jpg"];
    
    NSURL *url = [NSURL URLWithString: [appURI stringByAppendingString:fileRemotePath] ];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    // Tell ASIHTTPRequest where to save things:
    [request setTemporaryFileDownloadPath:tempFileLocation];     
    [request setDownloadDestinationPath:fileLocation]; 
    [request startSynchronous];
    // If you've stored documentDirectory or pdfLocation somewhere you won't need one or both of these lines
//    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *pdfLocation = [documentDirectory stringByAppendingPathComponent:@"test.pdf"];
    
    // Now tell your UIWebView to load that file
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfLocation]]];
    self.imageView.image = [UIImage imageWithContentsOfFile:fileLocation];
    
//    NSData *fileData =  [NSData dataWithBase64EncodedString:[result objectForKey:@"FileByte"] ];
    //        NSLog(@"GetFileProfileByDocumentId returned the file: %@", [result objectForKey:@"FileByte"]);
   */
    
    //ODATA
    @try {

        DataServiceQuery *query = [proxy pictures];
        [query filter:[NSString stringWithFormat:@"LinkedBoxID eq %@",selectedItem]];
        QueryOperationResponse *queryOperationResponse = [query execute];

        DoveSiButtaModel_Picture *thePicture =[[queryOperationResponse getResult] objectAtIndex:0];
        NSLog(@"pictureID ID: %@", [thePicture getID]); 
        
        if([[thePicture getPicture_Filename] length ] >0)
        {
        
            // TEMPORARY  PATH
            // Get the Caches directory
            NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            // Add your filename to the directory to create your temp pdf location
            NSString *tempFileLocation = [cachesDirectory stringByAppendingPathComponent:[thePicture getPicture_Filename]];
    //        NSString *debugURL = @"http://192.168.138.2/Pictures/";
    //        NSURL *url = [NSURL URLWithString: [debugURL stringByAppendingString:[thePicture getPicture_Filename]] ];
            NSURL *url = [NSURL URLWithString: [picturesURI stringByAppendingString:[thePicture getPicture_Filename]] ];

            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            // Tell ASIHTTPRequest where to save things:
    //        [request setTemporaryFileDownloadPath:tempFileLocation];     
            [request setDownloadDestinationPath:tempFileLocation]; 
            [request startSynchronous];
            self.imageView.image = [UIImage imageWithContentsOfFile:tempFileLocation];
        }
        else
        {
            self.imageView.image = [UIImage imageNamed:@"NoPicture.jpg"];
        }
          /*
           //DI 'STA ROBA QUI SOTTO NON VA UN CAZZO
        DataServiceStreamResponse *streamresponse  = [proxy getReadStream:thePicture];
        [streamresponse retain];
        NSData *pictData = [proxy getReadStream:thePicture];
        self.imageView.image = [UIImage imageWithData:pictData];
      
        
        NSString *streamURI = [proxy getReadStreamUri:thePicture];
        NSLog(@"streamURI %@", streamURI);

        NSLog(@"%@", streamresponse);
        NSString *stream =[streamresponse getStream];

        NSData *decodedStream = [NSData dataFromBase64String:stream]; 
        NSLog(@"content-type %@", [streamresponse getContentType]);
        
        // TEMPORARY PDF PATH
        // Get the Caches directory
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // Add your filename to the directory to create your temp pdf location
        NSString *tempFileLocation = [cachesDirectory stringByAppendingPathComponent:[thePicture getPicture_Filename]];
        
        [decodedStream writeToFile:tempFileLocation atomically:YES];
        self.imageView.image = [UIImage imageWithContentsOfFile:tempFileLocation];
*/
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@", exception.name, exception.reason);
    }
    @finally {
        [SVProgressHUD dismiss];
    }


}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Caricamento", @"Caricamento") maskType:SVProgressHUDMaskTypeBlack];
    //        [self retrieveDinnersWithAddress:self.address];
    //        [self retrieveDinners];
    [self getPictureFile];
    [SVProgressHUD dismiss];
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
