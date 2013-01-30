//
//  Texture.m
//  RedactedFaces
//
//  Created by Praveen Jha on 31/01/13.
//  Copyright (c) 2013 Grok Software. All rights reserved.
//

#import "Texture.h"
#import "GPUImageOpenGLESContext.h"

@implementation Texture
@synthesize shouldSmoothlyScaleOutput=_shouldSmoothlyScaleOutput;
@synthesize textureSize=_textureSize;

-(Texture*)initWithImageName:(NSString*)imageName
{
    self = [super init];
    if (!self)
        return nil;
    
    UIImage *newImageSource = [UIImage imageNamed:imageName];

    CGSize pointSizeOfImage = [newImageSource size];
    CGFloat scaleOfImage = [newImageSource scale];
    CGSize pixelSizeOfImage = CGSizeMake(scaleOfImage * pointSizeOfImage.width, scaleOfImage * pointSizeOfImage.height);
    CGSize pixelSizeToUseForTexture = pixelSizeOfImage;

    BOOL shouldRedrawUsingCoreGraphics = YES;

    // For now, deal with images larger than the maximum texture size by resizing to be within that limit
    CGSize scaledImageSizeToFitOnGPU = [GPUImageOpenGLESContext sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
    if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
    {
        pixelSizeOfImage = scaledImageSizeToFitOnGPU;
        pixelSizeToUseForTexture = pixelSizeOfImage;
        shouldRedrawUsingCoreGraphics = YES;
    }

    if (self.shouldSmoothlyScaleOutput)
    {
        // In order to use mipmaps, you need to provide power-of-two textures, so convert to the next largest power of two and stretch to fill
        CGFloat powerClosestToWidth = ceil(log2(pixelSizeOfImage.width));
        CGFloat powerClosestToHeight = ceil(log2(pixelSizeOfImage.height));

        pixelSizeToUseForTexture = CGSizeMake(pow(2.0, powerClosestToWidth), pow(2.0, powerClosestToHeight));

        shouldRedrawUsingCoreGraphics = YES;
    }

    GLubyte *imageData = NULL;
    CFDataRef dataFromImageDataProvider;

    if (shouldRedrawUsingCoreGraphics)
    {
        // For resized image, redraw
        imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);

        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 8, (int)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), [newImageSource CGImage]);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
    }
    else
    {
        // Access the raw image bytes directly
        dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider([newImageSource CGImage]));
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    }
    GLuint outputTexture=0;
    glBindTexture(GL_TEXTURE_2D, outputTexture);
    self.textureId = outputTexture;
    if (self.shouldSmoothlyScaleOutput)
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    }
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, imageData);
    
    if (self.shouldSmoothlyScaleOutput)
    {
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    if (shouldRedrawUsingCoreGraphics)
    {
        free(imageData);
    }
    else
    {
        CFRelease(dataFromImageDataProvider);
    }
    self.textureSize = pixelSizeToUseForTexture;
    return self;
}

@end
