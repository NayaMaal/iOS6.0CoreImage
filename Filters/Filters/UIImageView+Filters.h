//
//  UIImageView+Filters.h
//  Filters
//
//  Created by NayaMaal on 30/01/12
//  Copyright (c) 2012 NayaMaal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FiltersCompletionBlock)(NSError *error);

extern NSString *const kFiltersErrorDomain;

extern CGFloat   const kFiltersDefaultBlurRadius;

enum FiltersError {
    FiltersErrorFilterNotAvailable = 0,
};


@interface UIImageView (Filters)

/**
 Set the blurred version of the provided image to the UIImageView
 
 @param UIImage the image to blur and set as UIImageView's image
 @param CGFLoat the radius of the blur used by the Gaussian filter
 *param FiltersCompletionBlock a completion block called after the image
    was blurred and set to the UIImageView (the block is dispatched on main thread)
 */
- (void)setImageToBlur: (UIImage *)image
            blurRadius: (CGFloat)blurRadius
       completionBlock: (FiltersCompletionBlock) completion;

@end
