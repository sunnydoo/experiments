//
//  MyCustomOpenGLView.h
//  GoldenTriangle
//
//  Created by Jianping Wang on 10/14/14.
//  Copyright (c) 2014 Jianping Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NSOpenGLContext, NSOpenGLPixelFormat;

@interface MyCustomOpenGLView : NSView
{
@private
    NSOpenGLContext* _openGLContext;
    NSOpenGLPixelFormat* _pixelFormat;
}

+ (NSOpenGLPixelFormat*) defaultPixelFormat;

-(id) initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format;
-(void) setOpenGLContext: (NSOpenGLContext*) context;
-(NSOpenGLContext*) openGLContext;
-(void)clearGLContext;
-(void)prepareOpenGL;
-(void)update;
-(void)setPixFormat:(NSOpenGLPixelFormat*)pixelFormat;
-(NSOpenGLPixelFormat*) pixelFormat;

@end
