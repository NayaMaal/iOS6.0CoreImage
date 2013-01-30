//
//  Texture.h
//  RedactedFaces
//
//  Created by Praveen Jha on 31/01/13.
//  Copyright (c) 2013 Grok Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Texture : NSObject

@property (nonatomic,assign) BOOL shouldSmoothlyScaleOutput;
@property (nonatomic,assign) GLuint textureId;
@property (nonatomic,assign) CGSize textureSize;

-(Texture*)initWithImageName:(NSString*)imageName;
@end
