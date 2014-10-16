//
//  MyOpenGLView.m
//  GoldenTriangle
//
//  Created by Jianping Wang on 10/14/14.
//  Copyright (c) 2014 Jianping Wang. All rights reserved.
//

#import "MyOpenGLView.h"
#include <OpenGL/gl.h>

@implementation MyOpenGLView

static void drawAnObject()
{
    glColor3f(1.0f, 0, 0);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(0.0, 0.8, 0.2);
        glVertex3f(-0.2, -0.3, 0.0);
        glVertex3f(0.2, -0.3, 0.0);
    }
    glEnd();
}

- (void) drawRect:(NSRect)dirtyRect
{
    glClearColor(0, 0, 0, 0);
    glClear( GL_COLOR_BUFFER_BIT);
    drawAnObject();
    glFlush();
}

@end
