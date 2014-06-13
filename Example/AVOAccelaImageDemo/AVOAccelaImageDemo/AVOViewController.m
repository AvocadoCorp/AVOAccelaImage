//
//  AVOViewController.m
//  AVOAccelaImageDemo
//
//  Created by Ben Jones on 5/31/14.
//  Copyright (c) 2014 Avocado Software Inc. All rights reserved.
//

#import "AVOViewController.h"
#import <AVOAccelaImage/UIImage+AVOAccelaImage.h>

@import ImageIO;

@interface AVOViewController () <NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *runIncrementalButton;
@end

@implementation AVOViewController

static UIImage * sourceImage = nil;

+ (void)initialize {
    sourceImage = [UIImage imageNamed:@"ExampleLargeImage"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)blurButtonTapped:(id)sender {
    CGSize preferredSize = [self preferredSizeForImageSize:sourceImage.size constrainedToWidth:CGRectGetWidth(self.view.bounds)];

    self.imageView.image = [sourceImage avo_vImageScaledImageWithSize:preferredSize
                                                           blurRadius:10
                                                           iterations:1
                                                            tintColor:nil
                                                            transform:[sourceImage avo_transformForOrientation:preferredSize]
                                                       drawTransposed:NO];
}

- (IBAction)fillButtonTapped:(id)sender {
    self.imageView.image = [sourceImage avo_resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.view.bounds.size];
}

- (IBAction)resetButtonTapped:(id)sender {
    self.imageView.image = sourceImage;
}

- (CGSize)preferredSizeForImageSize:(CGSize)originalSize constrainedToWidth:(CGFloat)maxWidth {
    CGFloat aspectRatio = originalSize.height / originalSize.width;

    CGFloat imageWidth = maxWidth;
    CGFloat imageHeight = imageWidth * aspectRatio;

    return CGSizeMake(fabs(maxWidth), fabs(imageHeight));
}

@end
