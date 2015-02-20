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


@end

@implementation SignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
}

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
