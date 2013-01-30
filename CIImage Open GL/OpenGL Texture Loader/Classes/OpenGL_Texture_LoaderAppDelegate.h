//
//  OpenGL_Texture_LoaderAppDelegate.h
//  OpenGL Texture Loader
//
//  Created by numata on 09/09/12.
//  Copyright Satoshi Numata 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface OpenGL_Texture_LoaderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end

