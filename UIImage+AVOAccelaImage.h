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


/**
 *  Resizes the image to the desired size using the Accelerate framework. Values can be passed for the transform operation to apply to the resized image or if the image should be drawn transposed. Optionally values can be passed for blur effects (radius, interations, tintColor).
 *
 *  @param newSize the new desired size of the image
 *  @param radius radius of the iOS 7 style blur effect to apply to the resized image (resize is performed first)
 *  @param interations the number of times the blur effect is calculated and applied. More interations will result in a crisper effect but it will also take longer to compute
 *  @param tintColor the tint color to apply to the image
 *  @param transform CGAfineTransform that will be used calculating the resized image
 *  @param transpose if the image should be drawn transposed
 *
 * @return a new UIImage after the adjustments and resizing has taken place
 */
- (UIImage *)vImageScaledImageWithSize:(CGSize)newSize
                            blurRadius:(CGFloat)radius
                           interations:(NSUInteger)iterations
                             tintColor:(UIColor *)tintColor
                             transform:(CGAffineTransform)transform
                        drawTransposed:(BOOL)transpose;

@end