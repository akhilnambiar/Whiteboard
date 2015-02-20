//
//  SaveLocationViewController.h
//  GTL
//
//  Created by Akhil Nambiar on 7/17/14.
//
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"

@interface SaveLocationViewController : UIViewController

@property (strong, nonatomic) GTLServiceDrive *driveService;
@property (strong, nonatomic) GTLDriveFile *driveFile;
@property BOOL withHandout;
@property (weak, nonatomic) NSDictionary *userData;

@end
