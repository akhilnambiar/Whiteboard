//
//  TestControllerViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 8/6/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "TestControllerViewController.h"
#import "SmoothedBIView.h"

@interface TestControllerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *handoutImageView;
@property (weak, nonatomic) IBOutlet SmoothedBIView *smooth2;

@end

@implementation TestControllerViewController

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
    // Do any additional setup after loading the view.
        //The following block is mainly for testing purposes. It checks to see if the websocket is working
        if(self.smooth2){
            NSLog(@"yea");
            NSLog(@"the image %@",self.handoutImage);
            self.smooth2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
            [self.handoutImageView setImage:self.handoutImage];
            NSString *url = @"http://glacial-castle-5433.herokuapp.com/paint";
            //This will make a get request
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setHTTPMethod:@"GET"];
            [request setURL:[NSURL URLWithString:url]];
            
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *responseCode = nil;
            
            NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
            NSString* response;
            if([responseCode statusCode] != 200){
                NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
                response = @"no hay response";
            }
            
            response = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
            NSLog(@"response is %@",response);
            [self.smooth2 updateLabel:oResponseData];
        }
        
        //end of testing code block
        
        
        self.navigationController.toolbarHidden = NO;
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
