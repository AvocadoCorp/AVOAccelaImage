#import "UIImage+AVOAccelaImage.h"

@implementation UIImage(AVOAccelaImage)

- (UIImage *)resizedImage:(CGSize)newSize {
    BOOL drawTransposed;

    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;

        default:
            drawTransposed = NO;
    }

    return [self vImageScaledImageWithSize:newSize transform:[self transformForOrientation:newSize] drawTransposed:drawTransposed];
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
        default:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        default:
            break;
    }

    return transform;
}

- (UIImage *)vImageScaledImageWithSize:(CGSize)newSize
transform:(CGAffineTransform)transform
drawTransposed:(BOOL)transpose
{

    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width * scale, newSize.height * scale));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height * scale, newRect.size.width * scale);

    if (transpose) {
        newRect = transposedRect;
    }

    CGSize desiredSize = newRect.size;
    UIImage *scaledImage = nil;

    // Convert UIImage to array of bytes in ARGB8888 pixel format
    CGImageRef sourceRef = [self CGImage];
    NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
    NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *sourceData = (unsigned char*)calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight,
                                                 bitsPerComponent, sourceBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);

    if (context == NULL){
#if DEBUG
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale source context ref null"];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];
        NSLog(@"%@: %@", errorReason, errorInfo);
#endif
    }

    CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
    CGContextRelease(context);

    NSUInteger destWidth = (NSUInteger)desiredSize.width;
    NSUInteger destHeight = (NSUInteger)desiredSize.height;
    NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
    unsigned char *destData = (unsigned char*)calloc(destHeight * destWidth * 4, sizeof(unsigned char));

    // Create vImage_Buffers for both arrays
    vImage_Buffer src = {
        .data = sourceData,
        .height = sourceHeight,
        .width = sourceWidth,
        .rowBytes = sourceBytesPerRow
    };

    vImage_Buffer dest = {
        .data = destData,
        .height = destHeight,
        .width = destWidth,
        .rowBytes = destBytesPerRow
    };

    // Resize image
    vImage_Error err = vImageScale_ARGB8888(&src, &dest, NULL, kvImageNoAllocate + kvImageHighQualityResampling);
    CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight,
                                                     bitsPerComponent, destBytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    if (destContext == NULL){
#if DEBUG
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale destination context ref null"];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];
        NSLog(@"%@: %@", errorReason, errorInfo);
#endif
    }

    free(sourceData);

    CGImageRef destRef = CGBitmapContextCreateImage(destContext);
    scaledImage = [UIImage imageWithCGImage:destRef scale:[UIScreen mainScreen].scale orientation:self.imageOrientation];
    free(destData);

    CGImageRelease(destRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(destContext);

    // Error handling
    if (err != kvImageNoError) {
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale returned error code %zd", err];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:newSize], @"destSize",
                                   nil];

        NSException *exception = [NSException exceptionWithName:@"HighQualityImageScalingFailureException" reason:errorReason userInfo:errorInfo];

        @throw exception;
    }

    return scaledImage;
}

@end