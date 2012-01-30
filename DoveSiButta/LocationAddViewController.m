//
//  LocationAddViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 15/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "LocationAddViewController.h"
//Pageviewcontroller
#import "TextFieldCell.h"
#import "DetailDisclosureCell.h"
#import "NibLoadedCell.h"
#import "PictureFileViewController.h"

//OData
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"



#define radians( degrees ) ( degrees * M_PI / 180 ) 

@implementation LocationAddViewController
@synthesize newItem;
@synthesize pictureFile;

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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


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


- (void)saveItem:(id)sender
{
    
    if( [newItem getLatitude] != [NSDecimalNumber zero] || [newItem getLongitude]  !=  [NSDecimalNumber zero])
    {
        //1- Get dinner with ID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];

        
        //SOLO PER DEBUG!!!
        [newItem setBoxType:@"1"];
        [newItem setPicture_Filename:@"prova.jpg"];
        
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
    //    NSString *odataResult = [[proxy GetFileWithdinnerid:self.selectedItem] retain];
    //    odataResult = [[odataResult stringByReplacingOccurrencesOfString:@"xmlns=\"http://schemas.microsoft.com/ado/2007/08/dataservices\"" withString:@"" ] stringByReplacingOccurrencesOfString:@"standalone=\"true\"" withString:@""];
        NSString *retString = [proxy CreateNewItemWithtitle:[newItem getTitle] latitude:[newItem getLatitude] longitude:[newItem getLongitude] address:[[newItem getAddress] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] boxtype:[newItem getBoxType] picture_filename:[newItem getPicture_Filename]];
        NSLog(@"Returned: %@", retString);
        //TODO: controllare l'indirizzo, ma la stringa funziona
//            http://192.168.138.2/Services/OData.svc/CreateNewItem?longitude=10.32752f&title='Nuovo'&latitude=45.51141f    }
    //TODO: Controlla che i dati ci siano tutti i dati
    //TODO:  Controlla che ci sia la foto
}


- (void)cancelNewItem:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Tasto Cancel
    UIBarButtonItem *cancelButton =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self
      action:@selector(cancelNewItem:)]
     autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Tasto Salva
    UIBarButtonItem *saveButton =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemSave
      target:self
      action:@selector(saveItem:)]
     autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //TODO: fare in modo che le celle assomiglino a quelle di CoreDataBooks
         
    //Icons
    
    // read property list into memory as an NSData object
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IconForType" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSError *error = [[NSError alloc] init];
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    NSDictionary *plistDictionary = (NSDictionary*)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    
    if (!plistDictionary) 
    {
        NSLog(@"Error reading plist: %@, format: %d", error, format);
    }
    NSDictionary *iconsDictionary = [plistDictionary copy ];
    [iconsDictionary retain];
    
    //Types
    path = [[NSBundle mainBundle] pathForResource:@"RifiutiTypes" ofType:@"plist"];
    plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    
    // convert static property list into dictionary object
    plistDictionary =(NSDictionary*)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error]; 
    if (!plistDictionary) 
    {
        NSLog(@"Error reading plist: %@, format: %d", error, format);
    }
    NSMutableArray* rifiutiTypes = [[NSMutableArray alloc] init];
    for(NSString *dic in plistDictionary)
    {
        NSDictionary *i = [plistDictionary objectForKey:dic];
        [rifiutiTypes addObject:i];
    }
    [rifiutiTypes retain];
    NSLog(@"rifiutitypes: %@", rifiutiTypes);

    
    
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
   	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];
    
    [self appendRowToSection:0 cellClass:[NibLoadedCell class] 
                    cellData:[NSDictionary dictionaryWithObjectsAndKeys:
                              [newItem getTitle],@"labelText",
                              [NSString stringWithString:@"indifferenziata_300px"],@"imageName",                               NSLocalizedString(@"Nuovo Cestino", @"Title Label"),@"titleLabelText", 
                              nil] 
               withAnimation:UITableViewRowAnimationNone];
    
    [self addSectionAtIndex:1 withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Dove", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"When", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getEventDate] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Latitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getLatitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Longitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getLongitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    /*
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"ID", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getDinnerID] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
     */
    /*
     [self appendRowToSection:1 cellClass:[TextFieldCell class] 
     cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(@"Hosted By", @""),
     @"label",
     [NSString stringWithFormat:@"%@",[selectedDinner getHostedBy] ], @"value",
     NSLocalizedString(@"Value goes here", @""),
     @"placeholder", 
     NO, 
     @"editable",
     nil]
     withAnimation:UITableViewRowAnimationNone];
     [self appendRowToSection:1 cellClass:[TextFieldCell class] 
     cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(@"Description", @""),
     @"label",
     [NSString stringWithFormat:@"%@",[selectedDinner getDescription] ], @"value",
     NSLocalizedString(@"Value goes here", @""),
     @"placeholder", 
     NO, 
     @"editable",
     nil]
     withAnimation:UITableViewRowAnimationNone];
     [self appendRowToSection:1 cellClass:[TextFieldCell class] 
     cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(@"Phone", @""),
     @"label",
     [NSString stringWithFormat:@"%@",[selectedDinner getContactPhone] ], @"value",
     NSLocalizedString(@"Value goes here", @""),
     @"placeholder", 
     NO, 
     @"editable",
     nil]
     withAnimation:UITableViewRowAnimationNone];
     [self appendRowToSection:1 cellClass:[TextFieldCell class] 
     cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(@"Hosted by ID", @""),
     @"label",
     [NSString stringWithFormat:@"%@",[selectedDinner getHostedById] ], @"value",
     NSLocalizedString(@"Value goes here", @""),
     @"placeholder", 
     NO, 
     @"editable",
     nil]
     withAnimation:UITableViewRowAnimationNone];
     */
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Address", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Country", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getCountry] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    /*
     [self appendRowToSection:1 cellClass:[DetailDisclosureCell class] 
     cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
     NSLocalizedString(@"View RSVPs",@""),
     @"label",
     @"showRSVP", 
     @"action", //TODO: Mostra chi l'ha trovata interessante
     nil] 
     withAnimation:UITableViewRowAnimationNone]; 
     */
    [self appendRowToSection:1 cellClass:[DetailDisclosureCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"Scatta una foto!",@""),
                               @"label",
                               @"addPicture", 
                               @"action", 
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 
    
    //TODO: qui ci vanno le celle (che sono poi delle normali LabelCell ma con accanto il checkbox
    
    [dateFormat release];

    
}


#pragma mark - Table view delegates

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //	PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
	if (![[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[PageCell class]])
	{
		return;
	}
	
    if ([[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[DetailDisclosureCell class]]) {
        DetailDisclosureCell *cell = (DetailDisclosureCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
        if([cell.action isEqualToString:@"addPicture"])
        {
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            [imgPicker setAllowsEditing:YES];
            imgPicker.delegate = self;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else 
            {
                imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            [self.navigationController presentModalViewController:imgPicker animated:YES];
//            [self presentModalViewController:self.imgPicker animated:YES];
                
        }
        
        return;
    }
    
    PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
    [cell handleSelectionInTableView:aTableView];
    
	
}


#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    //Qui devo salvare l'immagine nella cache e resizarla
    UIImage *scaledImage = [self imageWithImage:img scaledToSizeWithSameAspectRatio:CGSizeMake(640.0f, 480.0f)];
    NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.9f);
    
    // Give a name to the file
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString* imageName = [dateFormat stringFromDate:[NSDate date]];
    
    // Now, we have to find the documents directory so we can save it
    // Note that you might want to save it elsewhere, like the cache directory,
    // or something similar.
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // Now we get the full path to the file
    NSString* fullPathToFile = [cachesDirectory stringByAppendingPathComponent:imageName];
    
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:NO];
    self.pictureFile = fullPathToFile;
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
}


- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{  
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }     
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }   
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}



@end
