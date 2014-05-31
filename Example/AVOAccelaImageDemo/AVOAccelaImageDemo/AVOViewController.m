//
//  AVOViewController.m
//  AVOAccelaImageDemo
//
//  Created by Ben Jones on 5/31/14.
//  Copyright (c) 2014 Avocado Software Inc. All rights reserved.
//

#import "AVOViewController.h"
#import <AVOAccelaImage/UIImage+AVOAccelaImage.h>

@interface AVOViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation AVOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *largeImage = [UIImage imageNamed:@"ExampleLargeImage"];
    CGSize preferredSize = [self preferredSizeForImageSize:largeImage.size constrainedToWidth:CGRectGetWidth(self.view.bounds)];
    self.imageView.image = [largeImage resizedImage:preferredSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)preferredSizeForImageSize:(CGSize)originalSize constrainedToWidth:(CGFloat)maxWidth {
    CGFloat aspectRatio = originalSize.height / originalSize.width;

    CGFloat imageWidth = maxWidth;
    CGFloat imageHeight = imageWidth * aspectRatio;

    return CGSizeMake(fabs(maxWidth), fabs(imageHeight));
}

@end
