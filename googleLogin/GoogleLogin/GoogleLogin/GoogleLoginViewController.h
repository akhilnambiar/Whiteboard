//
//  GoogleLoginViewController.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 5/31/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface GoogleLoginViewController : UIViewController<UIWebViewDelegate,GoogleOAuthDelegate>
- (IBAction)showProfile:(id)sender;
- (IBAction)revokeAccess:(id)sender;
@end
