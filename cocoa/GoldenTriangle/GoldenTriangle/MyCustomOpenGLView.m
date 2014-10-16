//
//  MyCustomOpenGLView.m
//  GoldenTriangle
//
//  Created by Jianping Wang on 10/14/14.
//  Copyright (c) 2014 Jianping Wang. All rights reserved.
//

#import "MyCustomOpenGLView.h"

@implementation MyCustomOpenGLView

-(id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format
{
    self = [super initWithFrame: frameRect];
    
    if (self != nil) {
        _pixelFormat = [ format retain];
        [[ NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(_surfaceNeedsUpdate:)
                                                      name:NSViewGlobalFrameDidChangeNotification
                                                    object:self];
    }
    return self;
}

-(void) _surfaceNeedsUpdate: (NSNotification*) notification
{
    [self update];
}

-(void) lockFocus
{
    NSOpenGLContext* context = [self openGLContext];
    
    [super lockFocus];
    
    if( [context view] != self) {
        [ context setView: self];
    }
    
    [context makeCurrentContext];
}

static void drawAnObject()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(0.0, 0.6, 0.0);
        glVertex3f(-0.2, -0.3, 0.0);
        glVertex3f(0.2, -0.3, 0.0);
    }
    glEnd();
}

-(void) drawRect:(NSRect)dirtyRect
{
    NSOpenGLContext* context = [self openGLContext];
    [context makeCurrentContext];
    
    glClearColor(0, 0, 0, 0);
    glClear( GL_COLOR_BUFFER_BIT);
    drawAnObject();
    glFlush();
    
    [context flushBuffer];
}

@end













