//
//  LoginViewController.m
//  DoveSiButta
//
//  Created by Giovanni on 3/4/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) NSMutableData *receivedData;

@end

@implementation LoginViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [self postLogin];
}


- (IBAction)registerButtonPressed:(id)sender {
}

- (void)postLogin
{
    //http://stackoverflow.com/questions/12658724/how-to-simulate-http-form-post-submit-on-ios
    
    //TODO: prova a loggarti
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.dovesibutta.com/Account/LogOn"]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//    //this is hard coded based on your suggested values, obviously you'd probably need to make this more dynamic based on your application's specific data to send
//    NSString *postString = [NSString stringWithFormat:@"UserName=%@&Password=%@", self.usernameField.text, self.passwordField.text];
//    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//    [request setValue:postString forHTTPHeaderField:@"Content-Length"];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    
//    
    // Create the request.
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.dovesibutta.com/Account/LogOn"]
                                              ];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];

    NSString *postString = [NSString stringWithFormat:@"UserName=%@&Password=%@", self.usernameField.text, self.passwordField.text];
    [theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [theRequest setValue:postString forHTTPHeaderField:@"Content-Length"];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        _receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
    
    
    //TODO: WORK ON THISq
   
//    NSURLResponse *response;
//    NSError *err;
//    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
//    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
//    NSLog(@"responseData: %@", content);
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);

}


//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    NSLog(@"Response: %@", response.description);
//}




- (void)viewDidUnload {
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
}
@end
