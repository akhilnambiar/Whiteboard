//
//  SignupVC.m
//  ClassBoard
//
//  Created by Akhil Nambiar on 2/19/15.
//  Copyright (c) 2015 Akhil Nambiar. All rights reserved.
//

#import "SignupVC.h"


@interface SignupVC ()
@property (weak, nonatomic) IBOutlet UIPickerView *schoolPick;
@property (strong, nonatomic) IBOutlet UIPickerView *teacherPick;
@property (strong, nonatomic) IBOutlet UIPickerView *periodPick;
@property (strong, nonatomic) NSArray *schoolList;
@property (strong, nonatomic) NSArray *teacherList;
@property (strong, nonatomic) NSArray *periodList;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property UIAlertView* loginAlert;
@property NSString* userId;


@end

@implementation SignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",kClientSecret);
    self.schoolList = @[@"Wm. Fremd High School", @"Palatine High School"];
    self.teacherList = @[@"Jane Aldrin", @"Marissa Tomazuski"];
    self.periodList = @[@"4",@"5"];
    self.schoolPick.dataSource = self;
    self.schoolPick.delegate = self;
    self.teacherPick.dataSource = self;
    self.teacherPick.delegate = self;
    self.periodPick.dataSource = self;
    self.periodPick.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView==self.teacherPick){
        return [self.teacherList count];
    }
    else if (pickerView==self.periodPick){
        return [self.periodList count];
    }
    else if (pickerView==self.schoolPick){
        return [self.schoolList count];
    }
    NSLog(@"FATAL ERROR: THE PICKERVIEW IS INVALID. Check pickerviewnumberofRowsInComponent");
    return 0;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView==self.teacherPick){
        return (NSString*) [self.teacherList objectAtIndex:row];
    }
    else if (pickerView==self.periodPick){
        return (NSString*) [self.periodList objectAtIndex:row];
    }
    else if (pickerView==self.schoolPick){
        return (NSString*) [self.schoolList objectAtIndex:row];
    }
    NSLog(@"FATAL ERROR: THE PICKERVIEW IS INVALID. Check pickerViewTitleForRowrow");
    return nil;
}

- (IBAction)clickSignUp:(id)sender {
    //This calls the Google Drive View
    SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
    //Currently In Testing Mode
    [self testAddNewUser];
    /*
    GTMOAuth2ViewControllerTouch *authViewController =
    [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                               clientID:(NSString *)kClientId
                                           clientSecret:(NSString *)kClientSecret
                                       keychainItemName:(NSString *)kKeychainItemName
                                               delegate:self
                                       finishedSelector:finishedSelector];
    [self presentViewController:authViewController
                       animated:YES completion:nil];
     */
    
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error == nil) {
        //After they log in, we introduce the alert
        self.loginAlert = [DrEditUtilities showLoadingMessageWithTitle:@"Loading Classboard"
                                                              delegate:self];
        [[self driveService] setAuthorizer:auth];
        [self getUserInfo:self.driveService];
    }
}

- (void)getUserInfo:(GTLServiceDrive *)service {
    GTLQueryDrive *query = [GTLQueryDrive queryForAboutGet];
    // queryTicket can be used to track the status of the request.
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket, GTLDriveAbout *about,
                            NSError *error) {
            if (error == nil) {
                NSLog(@"Current user name: %@", about.name);
                NSLog(@"Root folder ID: %@", about.rootFolderId);
                NSLog(@"Permission ID: %@", about.permissionId);
                NSLog(@"The User: %@", about.user.displayName);
                self.userId = about.permissionId;
                [self addNewUser];
                
            } else {
                NSLog(@"An error occurred: %@", error);
            }
        }];
}

-(void) addNewUser{
    //we need to keep track of teacher variables here
    NSString *school = [self.schoolList objectAtIndex:[self.schoolPick selectedRowInComponent:0]];
    NSString *teacher = [self.teacherList objectAtIndex:[self.teacherPick selectedRowInComponent:0]];
    NSString *period = [self.periodList objectAtIndex:[self.periodPick selectedRowInComponent:0]];
    NSString *firstName = self.nameTextField.text;
    NSString *lastName = self.lnameTextField.text;
    NSString *email = self.emailTextField.text;
    [self makePostRequestwithKeys:@[@"username",@"school",@"teacher",@"period",@"first_name",@"last_name",@"email"] withValues:@[self.userId,school,teacher,period,firstName,lastName,email]];
    [self performSegueWithIdentifier:@"postSignon" sender:self];
    [self.loginAlert dismissWithClickedButtonIndex:0 animated:YES];
}


-(void) testAddNewUser{
    //we need to keep track of teacher variables here
    NSString *school = [self.schoolList objectAtIndex:[self.schoolPick selectedRowInComponent:0]];
    NSString *teacher = [self.teacherList objectAtIndex:[self.teacherPick selectedRowInComponent:0]];
    NSString *period = [self.periodList objectAtIndex:[self.periodPick selectedRowInComponent:0]];
    NSString *firstName = self.nameTextField.text;
    NSString *lastName = self.lnameTextField.text;
    NSString *email = self.emailTextField.text;
    [self makePostRequestwithKeys:@[@"username",@"school",@"teacher",@"period",@"first_name",@"last_name",@"email"] withValues:@[@"123",school,teacher,period,firstName,lastName,email]];
    [self performSegueWithIdentifier:@"signToSplash" sender:self];
    [self.loginAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)makePostRequestwithKeys:(NSArray *)keys withValues:(NSArray *)values{
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *x in keys){
        [dict setObject:[values objectAtIndex:i] forKey:x];
        i++;
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSLog(@"postData: %@",dict);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    const NSString *rU = rootURL;
    NSString *postURL = [rU stringByAppendingString:@"add_user/"];
    [request setURL:[NSURL URLWithString:postURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    //We don't need to call the segue because it already happends
    //[self performSegueWithIdentifier:@"groupsToHandout" sender:self];
    NSLog(@"Reply: %@", theReply);
}



//We Can Most Likely take out this method

/*
 BUG: People can technically add a different email which isn't one they use for google
 
 
- (IBAction)validFields{
    NSString* email = self.emailTextField.text;
    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"@"];
    NSRange range = [email rangeOfCharacterFromSet:cset];
    if (range.location == NSNotFound) {
        // no ( or ) in the string
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please use your school gmail account to proceed?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",@"Yaleh", nil];
        [alert show];
        return;
    } else {
        // ( or ) are present
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
