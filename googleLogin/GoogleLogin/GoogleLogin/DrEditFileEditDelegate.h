//
//  DrEditFileEditDelegate.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/23/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLDrive.h"

#import "DrEditFileEditDelegate.h"

@protocol DrEditFileEditDelegate
- (NSInteger)didUpdateFileWithIndex:(NSInteger)index
                          driveFile:(GTLDriveFile *)driveFile;
@end
