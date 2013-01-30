//
//  UIImageView+Filters.m
//  Filters
//
//  Created by NayaMaal on 30/01/12
//  Copyright (c) 2012 NayaMaal. All rights reserved.
//

#import "UIImageView+Filters.h"
#import <CoreImage/CoreImage.h>


NSString *const kFiltersErrorDomain          = @"com.NayaMaal.filter_additions";
CGFloat const   kFiltersDefaultBlurRadius    = 20.0;


@implementation UIImageView (Filters)

#pragma mark - Filters Additions

- (void)setImageToBlur: (UIImage *)image
            blurRadius: (CGFloat)blurRadius
       completionBlock: (FiltersCompletionBlock) completion

{
    CIContext *context   = [CIContext contextWithOptions:nil];
    CIImage *sourceImage = [CIImage imageWithCGImage:image.CGImage];
    
    // Apply clamp filter:
    // this is needed because the CIGaussianBlur when applied makes
    // a trasparent border around the image

    /*
     In iOS 6, Core Image adds the following filters to the set provided in iOS 5:
     CIAffineClamp, CIAffineTile, CIBarsSwipeTransition, CIBlendWithMask, CIBloom, CIBumpDistortion, CIBumpDistortionLinear, CICircleSplashDistortion,CICircularScreen, CIColorMap, CIColorPosterize, CICopyMachineTransition, CIDisintegrateWithMaskTransition, CIDissolveTransition, CIDotScreen, CIEightfoldReflectedTile, CIFlashTransition, CIFourfoldReflectedTile, CIFourfoldRotatedTile, CIFourfoldTranslatedTile, CIGaussianBlur, CIGlideReflectedTile, CIGloom, CIHatchedScreen, CIHoleDistortion, CILanczosScaleTransform, CILineScreen, CIMaskToAlpha, CIMaximumComponent, CIMinimumComponent, CIModTransition, CIPerspectiveTile, CIPerspectiveTransform, CIPinchDistortion, CIPixellate, CIRandomGenerator, CISharpenLuminance, CISixfoldReflectedTile, CISixfoldRotatedTile, CISmoothLinearGradient, CIStarShineGenerator, CISwipeTransition, CITriangleKaleidoscope, CITwelvefoldReflectedTile, CIUnsharpMask, CIVortexDistortion
     // One could use a combination of any of these
     */
    NSString *clampFilterName = @"CIAffineClamp";
    CIFilter *clamp = [CIFilter filterWithName:clampFilterName];
    
    if (!clamp) {
        
        NSError *error = [self errorForNotExistingFilterWithName:clampFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [clamp setValue:sourceImage
             forKey:kCIInputImageKey];
    
    CIImage *clampResult = [clamp valueForKey:kCIOutputImageKey];
    
    // Apply Gaussian Blur filter
    
    NSString *gaussianBlurFilterName = @"CIGaussianBlur";
    CIFilter *gaussianBlur           = [CIFilter filterWithName:gaussianBlurFilterName];
    
    if (!gaussianBlur) {
        
        NSError *error = [self errorForNotExistingFilterWithName:gaussianBlurFilterName];
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [gaussianBlur setValue:clampResult
                    forKey:kCIInputImageKey];
    [gaussianBlur setValue:[NSNumber numberWithFloat:blurRadius]
                    forKey:@"inputRadius"];
    
    CIImage *gaussianBlurResult = [gaussianBlur valueForKey:kCIOutputImageKey];
    
    __weak UIImageView *selfWeak = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGImageRef cgImage = [context createCGImage:gaussianBlurResult
                                           fromRect:[sourceImage extent]];
        
        UIImage *blurredImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            selfWeak.image = blurredImage;
            if (completion){
                completion(nil);
            }
        });
    });
}

/**
 Internal method for generate an NSError if the provided CIFilter name doesn't exists
 */
- (NSError *)errorForNotExistingFilterWithName:(NSString *)filterName
{
    NSString *errorDescription = [NSString stringWithFormat:@"The CIFilter named %@ doesn't exist",filterName];
    NSError *error             = [NSError errorWithDomain:kFiltersErrorDomain
                                                     code:FiltersErrorFilterNotAvailable
                                                 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    return error;
}

@end
