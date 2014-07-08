//
//  HandoutViewController.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 6/29/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "HandoutViewController.h"
#import "SplashPageViewController.h"

@interface HandoutViewController ()
@property (weak, nonatomic) IBOutlet UIView *availableHandouts;
@property (weak, nonatomic) IBOutlet UIButton *blankHandouts;
@property (weak, nonatomic) IBOutlet UIView *handoutView;
@end

@implementation HandoutViewController



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
    const NSString *rU = rootURL;
    NSString *handoutURL = [rU stringByAppendingString:@"/class/handouts"];
    NSString* json = [self getDataFrom:handoutURL];
    NSLog(@"%@",json);
    [self drawHandouts:@[]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

-(void) drawHandouts:(NSArray*) handouts{
    CGFloat height = [self.handoutView bounds].size.height;
    CGFloat width = [self.handoutView bounds].size.width;
    CGFloat cellHeight = height/7;
    CGFloat cellWidth = width*0.8;
    NSLog(@"the height is, %f",height);
    NSLog(@"the width is, %f",width);
    NSLog(@"the segment height is,%f",height/7);
    UIImage *image = [UIImage imageNamed:@"SignIn"];;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [iv setImage:image];
    [self.handoutView addSubview:iv];
    
    //SAVEPOINT: FIGURE OUT THE MATH TO SAVE AN IMAGE TO A PARTICULAR LOCATION
    
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
