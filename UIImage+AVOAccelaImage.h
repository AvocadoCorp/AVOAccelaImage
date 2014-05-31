#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (AVOAccelaImage)
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
- (UIImage *)resizedImage:(CGSize)newSize;
@end