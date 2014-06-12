AVOAccelaImage
==============

Avocado Image Utils using the Accelerate framework
--------------------------------------------------

### Simple Usage

> UIImage *image = [UIImage imageNamed:@"ExampleLargeImage"];
> image = [image avo_resizedImage:CGSizeMake(40, 40)];

### Resize with content mode options

> UIImage *image = [UIImage imageNamed:@"ExampleLargeImage"];
> image = [image avo_resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(100, 200)]

### Direct access to Accelerate to resize with blur

> CGSize newSize = CGSizeMake(40, 40)
> UIImage *image = [UIImage imageNamed:@"ExampleLargeImage"];
> image = [image avo_vImageScaledImageWithSize:newSize blurRadius:10.f iterations:1 tintColor:nil transform:[self avo_transformForOrientation:newSize] drawTransposed:NO]
