#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <float.h>

@interface UIImage (AVOAccelaImage)
- (UIImage *)resizedImage:(CGSize)newSize;
@end