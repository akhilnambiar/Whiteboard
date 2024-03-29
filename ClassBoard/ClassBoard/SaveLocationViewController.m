//
//  SaveLocationViewController.m
//  GTL
//
//  Created by Akhil Nambiar on 7/17/14.
//
//

#import "SaveLocationViewController.h"
#import "BoardViewController.h"

@interface SaveLocationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
- (IBAction)nextPage:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *chooseFileLabel;

@end

@implementation SaveLocationViewController

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
    [self.chooseFileLabel setFont:[UIFont fontWithName:@"WalkwaySemiBold" size:45]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"perpare for segue is called");
    if ([segue.identifier isEqualToString:@"SaveToBoard"]){
        BoardViewController *viewController = [segue destinationViewController];
        viewController.driveService = self.driveService;
        viewController.fileTitle = self.titleTextField.text;
        viewController.driveFile = self.driveFile;
        viewController.withHandout = self.withHandout;
        viewController.userData = self.userData;
    }
}
-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([self.titleTextField.text isEqualToString:@""]){
        [self needFileNameAlert];
        return NO;
    }
    NSLog(@"are we returning");
    return YES;
}

- (IBAction)nextPage:(id)sender {
    if([self shouldPerformSegueWithIdentifier:@"SaveToBoard" sender:self]){
        [self performSegueWithIdentifier:@"SaveToBoard" sender:self];
    }
}

-(void)needFileNameAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Please name your file"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
