#import "UIImage+AVOAccelaImage.h"

@implementation UIImage(AVOAccelaImage)

- (UIImage *)avo_resizedImage:(CGSize)newSize {
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

    return [self avo_vImageScaledImageWithSize:newSize
                                    blurRadius:0.f
                                    iterations:0
                                     tintColor:nil
                                     transform:[self avo_transformForOrientation:newSize]
                                drawTransposed:drawTransposed];
}

- (UIImage *)avo_resizedImageWithContentMode:(UIViewContentMode)contentMode
                                      bounds:(CGSize)bounds {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;

    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;

        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;

        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %%@", PRIdLEAST8, contentMode];
    }

    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);

    return [self avo_resizedImage:newSize];
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)avo_transformForOrientation:(CGSize)newSize {
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

- (UIImage *)avo_vImageTransposeWithOtherImage:(UIImage *)image
                                       isOnTop:(BOOL)isOnTop {
    CGImageRef topImageRef = isOnTop ? [self CGImage] : [image CGImage];
    CGImageRef bottomImageRef = isOnTop ? [image CGImage] : [self CGImage];

    CGDataProviderRef topProvider = CGImageGetDataProvider(topImageRef);
    CFDataRef topBitmapData = CGDataProviderCopyData(topProvider);

    size_t width = CGImageGetWidth(topImageRef);
    size_t height = CGImageGetHeight(topImageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(topImageRef);

    vImage_Buffer topBuffer = {
        .data = (void *)CFDataGetBytePtr(topBitmapData),
        .width =  width,
        .height = height,
        .rowBytes = bytesPerRow
    };

    CGDataProviderRef bottomProvider = CGImageGetDataProvider(bottomImageRef);
    CFDataRef bottomBitmapData = CGDataProviderCopyData(bottomProvider);

    width = CGImageGetWidth(bottomImageRef);
    height = CGImageGetHeight(bottomImageRef);
    bytesPerRow = CGImageGetBytesPerRow(bottomImageRef);

    vImage_Buffer bottomBuffer = {
        .data = (void *)CFDataGetBytePtr(bottomBitmapData),
        .width =  width,
        .height = height,
        .rowBytes = bytesPerRow
    };

    void *outBytes = malloc(height * bytesPerRow);
    vImage_Buffer outBuffer = {
        .data = outBytes,
        .width = width,
        .height = height,
        .rowBytes = bytesPerRow
    };

    vImage_Error error = vImagePremultipliedAlphaBlend_ARGB8888(&topBuffer, &bottomBuffer, &outBuffer, kvImageDoNotTile);
    if (error) {
        NSLog(@"AccelaImage: Blend error %ld", error);
    }

    CGContextRef destContext = CGBitmapContextCreate(&outBuffer, width, height,
                                                     bytesPerRow, bytesPerRow, CGColorSpaceCreateDeviceRGB(),
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    CGImageRef destRef = CGBitmapContextCreateImage(destContext);
    CGContextDrawImage(destContext, CGRectMake(0, 0, width, height), destRef);
    UIImage *blendedImage = [UIImage imageWithCGImage:destRef scale:[UIScreen mainScreen].scale orientation:self.imageOrientation];
    return blendedImage;
}

- (UIImage *)avo_vImageScaledImageWithSize:(CGSize)newSize
                                blurRadius:(CGFloat)radius
                                iterations:(NSUInteger)iterations
                                 tintColor:(UIColor *)tintColor
                                 transform:(CGAffineTransform)transform
                            drawTransposed:(BOOL)transpose {

    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect newRect = CGRectIntegral(CGRectMake(0,
                                               0,
                                               newSize.width * scale,
                                               newSize.height * scale));

    CGRect transposedRect = CGRectIntegral(CGRectMake(0,
                                                      0,
                                                      newRect.size.height * scale,
                                                      newRect.size.width * scale));

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

    if (radius && iterations) {
        //boxsize must be an odd integer
        uint32_t boxSize = (uint32_t)(radius * self.scale);
        if (boxSize % 2 == 0) boxSize ++;

        // create image buffers
        vImage_Buffer buffer1, buffer2;
        buffer1.width = buffer2.width = destWidth;
        buffer1.height = buffer2.height = destHeight;
        buffer1.rowBytes = buffer2.rowBytes = destBytesPerRow;
        size_t bytes = buffer1.rowBytes * buffer1.height;
        buffer1.data = malloc(bytes);
        buffer2.data = malloc(bytes);

        //create temp buffer
        void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                     NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));

        //copy image data
        CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(destRef));
        memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
        CFRelease(dataSource);

        for (NSUInteger i = 0; i < iterations; i++)
        {
            //perform blur
            vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

            //swap buffers
            void *temp = buffer1.data;
            buffer1.data = buffer2.data;
            buffer2.data = temp;
        }
        
        //free buffers
        free(buffer2.data);
        free(tempBuffer);

        CGContextRelease(destContext);
        destContext = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                            8, buffer1.rowBytes, CGImageGetColorSpace(destRef),
                                            CGImageGetBitmapInfo(destRef));

        if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.f) {
            CGContextSetFillColorWithColor(destContext, [tintColor colorWithAlphaComponent:0.25].CGColor);
            CGContextSetBlendMode(destContext, kCGBlendModePlusLighter);
            CGContextFillRect(destContext, CGRectMake(0, 0, buffer1.width, buffer1.height));
        }
        
        CGImageRelease(destRef);
        destRef = CGBitmapContextCreateImage(destContext);
        free(buffer1.data);
    }

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
