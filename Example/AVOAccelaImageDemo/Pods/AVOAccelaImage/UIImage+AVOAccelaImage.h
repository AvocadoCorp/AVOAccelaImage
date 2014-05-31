#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (AVOAccelaImage)
- (UIImage *)resizedImage:(CGSize)newSize;
@end