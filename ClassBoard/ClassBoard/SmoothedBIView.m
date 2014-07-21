//
//  SmoothedBIView.m
//  Board
//
//  Created by Akhil Nambiar on 4/3/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import "SmoothedBIView.h"
@interface SmoothedBIView()
@property (weak, nonatomic) IBOutlet UILabel *lifeCycleTest;
@property (weak, nonatomic) UIImage *recievedData;

@end

@implementation SmoothedBIView
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}


@synthesize delegate;

-(void)updateLabel:(NSData *)imageData;
{
    self.lifeCycleTest.text = @"Changed";
    
    UIImage *image = [UIImage imageWithData:imageData];
    //[image drawAtPoint:CGPointZero];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    //[self addSubview: imageView];
    self.recievedData = image;
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [self.recievedData drawInRect:rect];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    
    //added Code
    //UITouch *touch = [touches anyObject];
    //[delegate recivedTouch:touch fromUIView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"pooping Monkey");
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    //NSData *bezierData = [NSKeyedArchiver archivedDataWithRootObject:path];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(incrementalImage)];
    [delegate recivedTouch:touch fromUIView:self andData: imageData];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"me fin los tocas");
    UITouch *touch = [touches anyObject];
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(incrementalImage)];
    [delegate recivedTouch:touch fromUIView:self andData: imageData];
    ctr = 0;
    //New Line taht will take care of the white board showing up in between
    //self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

-(void)updateBoard:(NSData *)message
{
    UIImage *newImage = [UIImage imageWithData:message];
    [newImage drawAtPoint:CGPointZero];
    //[[UIColor blackColor] setStroke];
    //[path stroke];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    incrementalImage = newImage;
}

- (void)drawBitmap
{
    //AT SOME POINT, WE NEED TO INSTALL INCREMENTAL CACHING
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[[UIColor whiteColor] colorWithAlphaComponent:0.0] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
