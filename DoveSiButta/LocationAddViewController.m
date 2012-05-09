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
#import "NibLoadedCell.h"
#import "PictureFileViewController.h"
#import "LabelCell.h"
#import "CheckmarkCell.h"

//OData
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"

//UIImage extensions
#import "UIImage+Extensions.h"

//Xpath
#import "XPathQuery.h"

//NSdata
#import "NSData+Base64.h"

//MD5
#import "NSString+MD5.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define radians( degrees ) ( degrees * M_PI / 180 ) 

#define AlertViewMissingTypeSelection 0
#define AlertViewMissingPicture 1
#define AlertViewGeneralError 2
#define AlertViewOk 3

@implementation LocationAddViewController
@synthesize newItem;
@synthesize pictureFile;
@synthesize selectedTypes;
@synthesize setTypes;
@synthesize delegate;

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
//    [self.newItem release];
//    [self.pictureFile release];
//    [self.selectedTypes release];
//    [self.setTypes release];
//    self.newItem = nil;
//    self.pictureFile = nil;
//    self.selectedTypes = nil;
//    self.setTypes = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertViewOk || alertView.tag == AlertViewGeneralError) {
        [self dismissModalViewControllerAnimated:YES];
        [self.delegate addLocationDidFinish];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}

- (void)saveItem:(id)sender
{
    
    if([self.setTypes count] < 1)
    {
        //avviso che non può creare un cestino senza almeno un tipo!
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Devi selezionare almeno una tipologia dei cassonetti in foto!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
        [alert setTag:AlertViewMissingTypeSelection];
        [alert show];
        return;
    }
    
    if( ([newItem getLatitude] == [NSDecimalNumber zero] || [newItem getLongitude]  ==  [NSDecimalNumber zero] ) || [self.pictureFile length] < 1)
    {
        //avviso che non può creare un cestino senza foto!
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"È necessario scattare una fotografia! Scattarla ora?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert setTag:AlertViewMissingPicture];
        [alert show];
        return;
    }
            
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    HUD.delegate = self;
    HUD.labelText = @"Caricamento";
    [self.navigationController.view addSubview:HUD];
    [HUD show:YES];
    
    NSString *boxType = [[NSString alloc] init];
    for(NSString *s in self.setTypes)
    {
        boxType = [boxType stringByAppendingFormat:@"%@;",s];
    }
    
    [boxType retain];
//        NSLog(@"boxtype: %@", boxType);
    
    //1- Get item with ID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serviceURI= [defaults objectForKey:@"serviceURI"];

    
    NSString *udid = [[[UIDevice currentDevice] uniqueIdentifier] md5 ];
    [newItem setContactPhone:udid ];
    [newItem setBoxType:boxType];
    [newItem setDescription:@"Inviata con la App per iPhone DoveSiButta"];
    [newItem setPicture_Filename:@""];

    DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
    [proxy retain];
    NSData *pictureData = [NSData dataWithContentsOfFile:self.pictureFile];
    [pictureData retain];
    NSLog(@"Data length: %d", [pictureData length]);
    DoveSiButtaModel_Picture *newPicture = [[DoveSiButtaModel_Picture alloc] initWithUri:nil];
    
    
    @try {
        
        [proxy addToBoxes:newItem];

        [proxy saveChanges];  
        
        [proxy addToPictures:newPicture];
        DataServiceQuery *query = [[proxy boxes] orderBy:@"BoxID desc"];[query top:1];
        QueryOperationResponse *queryOperationResponse = [query execute];
        DoveSiButtaModel_Box *aNewBox =[[queryOperationResponse getResult] objectAtIndex:0];
        [aNewBox retain];
        NSLog(@"anewbox ID: %@", [aNewBox getBoxID]); 
        //            [newPicture setLinkedBoxID:[aNewBox getBoxID]];
        //            [proxy updateObject:newItem];
        //            [proxy addLink:newPicture sourceProperty:@"LinkedBoxID" targetObject:aNewBox];
        //Addlink non funziona
        [proxy setSaveStream:newPicture stream:pictureData closeStream:YES contentType:@"image/jpeg" slug:[NSString stringWithFormat:@"%@",[aNewBox getBoxID]]];
        
        [proxy saveChanges];
       
        [HUD hide:YES afterDelay:1];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Grazie!", @"") message:NSLocalizedString(@"Caricamento effettuato con successo", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert setTag:AlertViewOk];
        [alert show];
        

    }
    @catch (NSException *exception) {
        [HUD hide:YES];
        NSLog(@"Errore: %@:%@",exception.name, exception.reason);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Errore nel caricamento della foto.(%@)", @""),[exception reason]] delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        NSLog(@"%@", [exception description]);
        [alert setTag:AlertViewGeneralError];
        [alert show];
    }
    @finally {
        [HUD hide:YES afterDelay:1];
    }
        

}


- (void)cancelNewItem:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate addLocationDidFinish];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //tipi delle checkmark
    self.setTypes = [[NSMutableSet alloc] init];
    self.selectedTypes = [[NSMutableArray alloc] init];
    
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
   
    
    //Creazione TableView
    
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
                              [NSNumber numberWithBool:NO], 
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
                              [NSNumber numberWithBool:NO], 
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
                              [NSNumber numberWithBool:NO], 
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
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
  
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Address", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
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
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
 
    [self appendRowToSection:1 cellClass:[LabelCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"Scatta una foto!",@""),
                               @"label",
                               @"addPicture", 
                               @"action", 
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 

    [dateFormat release];

    
    [self addSectionAtIndex:2 withAnimation:UITableViewRowAnimationNone];
    for (NSDictionary *dict in rifiutiTypes)
    {
        [self appendRowToSection:2 cellClass:[CheckmarkCell class] 
                        cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                   NSLocalizedString([dict objectForKey:@"type"],@""),
                                   @"label",
                                   [dict objectForKey:@"id"], 
                                   @"value",
                                   [NSNumber numberWithBool:NO],
                                   @"checked",
                                   nil] 
                   withAnimation:UITableViewRowAnimationNone];
    }
    
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
		//return;
	}
	
    if ([[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[LabelCell class]]) 
    {
        LabelCell *cell = (LabelCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
        if([cell.action isEqualToString:@"addPicture"])
        {
            UIImagePickerController *imgPicker = [[[UIImagePickerController alloc] init] autorelease];
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
        //return;
        
    }
    else if ([[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[CheckmarkCell class]])
    {
        CheckmarkCell *cell = (CheckmarkCell*)[aTableView cellForRowAtIndexPath:anIndexPath];
        if(!cell.checked)
        {
            cell.checked = YES;
            [self.setTypes addObject:cell.value];
            
        }
        else if (cell.checked)
        {
            cell.checked = NO;
            [self.setTypes removeObject:cell.value];
        }
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) 
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        //return;
    }
    
    PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
    [cell handleSelectionInTableView:aTableView];
    
	
}


#pragma mark - ImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    //Qui devo salvare l'immagine nella cache e resizarla
    UIImage *scaledImage = [img imageByScalingProportionallyToMinimumSize:CGSizeMake(640.0f, 480.0f)]; // [self imageWithImage:img scaledToSizeWithSameAspectRatio:CGSizeMake(640.0f, 480.0f)];
    NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.9f);
    
    // Give a name to the file
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString* imageName = [[dateFormat stringFromDate:[NSDate date]] stringByAppendingString:@".jpg"];
    
    // Now, we have to find the documents directory so we can save it
    // Note that you might want to save it elsewhere, like the cache directory,
    // or something similar.
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // Now we get the full path to the file
    NSString* fullPathToFile = [cachesDirectory stringByAppendingPathComponent:imageName];
    
    // and then we write it out
    [imageData writeToFile:fullPathToFile atomically:YES];
    self.pictureFile = fullPathToFile;
    NSLog(@"Picture path: %@", fullPathToFile);
//    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
//    [picker dismissModalViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    [dateFormat release];

}

/*
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
*/


@end
