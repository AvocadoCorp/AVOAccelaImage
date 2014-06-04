#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (AVOAccelaImage)

/**
 *  Returns an affine transform that takes into account the image orientation when drawing a scaled image
 *
 *  @param newSize new size to generate a CGAffineTransform for
 *
 *  @return a CGAfineTransform that can be used for resizing or other operations
 */
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

/**
 *  Resizes the image according to the given content mode
 *
 *  @param newSize the new desired size of the image
 *
 * @return a new UIImage resizing has taken place
 */
- (UIImage *)resizedImage:(CGSize)newSize;

/**
 *  Resizes the image according to the given content mode, taking into account the image's orientation
 *
 * @param contentMode a UIViewContentMode of either UIViewContentModeScaleAspectFill or UIViewContentModeScaleAspectFit
 * @param bounds the new desired size of the image after the contentMode adjustments have been applied 
 *
 * @return a new UIImage after the adjustments and resizing has taken place
 */
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds;
@end