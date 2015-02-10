//
//  SmoothedBIView.h
//  Board
//
//  Created by Akhil Nambiar on 4/3/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol boardViewDelegate
- (void)recivedTouch:(UITouch *)touch fromUIView:(UIView *)uiView andData:(NSData *)incrImage;

@end
@interface SmoothedBIView : UIView
{
    // Delegate to respond back
    //id <boardViewDelegate> delegate;
}
@property (nonatomic, assign) id <boardViewDelegate> delegate;
//-(void)updateBoard:(NSData *)message;
-(void)updateLabel:(NSData *)imageData;
@end
