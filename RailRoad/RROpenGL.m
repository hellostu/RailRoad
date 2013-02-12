//
//  RROpenGL.m
//  RailRoad
//
//
//  ==== LICENCE ====
//
// This file is part of RailRoad.
//
// RailRoad is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// RailRoad is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with RailRoad.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import "RROpenGL.h"
#import "RRStaticMaths.h"

typedef struct {
    float Position[3];
    float TexCoord[2];
} Vertex;

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

typedef struct {
    GLSL_DATA_TYPE  dataType;
    GLuint          location;
} Uniform;

@interface RROpenGL ()
{
    @protected
    EAGLContext* _context;
    
    //OpenGL Buffers
    GLuint  _colorRenderBuffer;
    GLuint  _frameBuffer;
    
    //OpenGL Shader Variables
    NSMutableDictionary *_uniforms;
    GLuint      _programHandle;
    GLuint      _positionSlot;
    GLuint      _texCoordSlot;
    GLuint      _screenSizeUniform;
    GLuint      _textureUniform;
    
    //Image Info
    CGSize  _imgSize;
    Vertex  *_vertices;
    GLfloat _xPerc;
    GLfloat _yPerc;
    GLuint  _imageTexture;
    GLint   _maxTextureSize;
    
    CAEAGLLayer* _eaglLayer;
}

@end

@implementation RROpenGL

- (id)initWithLayer:(CAEAGLLayer *)layer vertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader
{
    if ( (self = [super init]) != nil)
    {
        _uniforms = [[NSMutableDictionary alloc] init];
        _vertices = malloc(sizeof(Vertex) * 4);
        _eaglLayer = layer;
        [self __setupContext];
        [self __setupRenderBuffer];
        [self __setupFrameBuffer];
        [self __compileVertexShader:vertexShader andFragmentShader:fragmentShader];
        [self __updateScreenSize];
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
    }
    return self;
}

- (void)dealloc
{
    [_uniforms release];
    free(_vertices);
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods - Public
//////////////////////////////////////////////////////////////////////////

- (void)initShaderUniform:(NSString *)name ofDataType:(GLSL_DATA_TYPE)dataType
{
    GLuint location = glGetUniformLocation(_programHandle, [name UTF8String]);
    Uniform uniform = {dataType,location};
    NSValue *uniformWrapper = [NSValue value:&uniform withObjCType:@encode(Uniform)];
    _uniforms[name] = uniformWrapper;
}

- (void)shaderUniform:(NSString *)name setValue:(void *)value
{
    Uniform uniform;
    NSValue *uniformWrapper = _uniforms[name];
    [uniformWrapper getValue:&uniform];
    
    switch (uniform.dataType)
    {
        case GLSL_DATA_TYPE_FLOAT:
        {
            GLfloat *floatArray = (GLfloat *)value;
            glUniform1f(uniform.location, floatArray[0]);
            break;
        }
        case GLSL_DATA_TYPE_VEC2:
        {
            GLfloat *floatArray = (GLfloat *)value;
            glUniform2f(uniform.location, floatArray[0], floatArray[1]);
            break;
        }
        case GLSL_DATA_TYPE_VEC3:
        {
            GLfloat *floatArray = (GLfloat *)value;
            glUniform3f(uniform.location, floatArray[0], floatArray[1], floatArray[2]);
            break;
        }
        case GLSL_DATA_TYPE_VEC4:
        {
            GLfloat *floatArray = (GLfloat *)value;
            glUniform4f(uniform.location, floatArray[0], floatArray[1], floatArray[2],floatArray[3]);
            break;
        }
        case GLSL_DATA_TYPE_INT:
        {
            GLint *intArray = (GLint *)value;
            glUniform1i(uniform.location, intArray[0]);
            break;
        }
        case GLSL_DATA_TYPE_IVEC2:
        {
            GLint *intArray = (GLint *)value;
            glUniform2i(uniform.location, intArray[0], intArray[1]);
            break;
        }
        case GLSL_DATA_TYPE_IVEC3:
        {
            GLint *intArray = (GLint *)value;
            glUniform3i(uniform.location, intArray[0], intArray[1], intArray[2]);
            break;
        }
        case GLSL_DATA_TYPE_IVEC4:
        {
            GLint *intArray = (GLint *)value;
            glUniform4i(uniform.location, intArray[0], intArray[1], intArray[2], intArray[3]);
            break;
        }
        case GLSL_DATA_TYPE_MAT2:
        {
            GLfloat *matrix = (GLfloat *)value;
            glUniformMatrix2fv(uniform.location, 1, NO, matrix);
            break;
        }
        case GLSL_DATA_TYPE_MAT3:
        {
            GLfloat *matrix = (GLfloat *)value;
            glUniformMatrix3fv(uniform.location, 1, NO, matrix);
            break;
        }
        case GLSL_DATA_TYPE_MAT4:
        {
            GLfloat *matrix = (GLfloat *)value;
            glUniformMatrix4fv(uniform.location, 1, NO, matrix);
            break;
        }
            
        default:
            break;
    }
}

- (void)render
{
    glClearColor(0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1
    glViewport(0, 0, _eaglLayer.frame.size.width, _eaglLayer.frame.size.height);
    
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _imageTexture);
    glUniform1i(_textureUniform, 0);
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupTextureWithImageBytes:(void *)bytes imageSize:(CGSize)imgSize
{
    glDeleteTextures(1, &_imageTexture);
    
    int width = imgSize.width;
    int height = imgSize.height;
    
    size_t wpo2 = [RRStaticMaths nextPowerOfTwo:width];
    size_t hpo2 = [RRStaticMaths nextPowerOfTwo:height];
    
    _xPerc = imgSize.width  /(float)wpo2;
    _yPerc = imgSize.height /(float)hpo2;
    
    void * texData = (GLubyte *) malloc(wpo2*hpo2*4*sizeof(GLubyte));
    memset(texData, 1, sizeof(GLubyte)*width*4);
    
    for(int i=0;i<height;i++)
    {
        memcpy(&texData[wpo2*i*4], &bytes[width*i*4], sizeof(GLubyte)*width*4);
    }
    
    glGenTextures(1, &_imageTexture);
    glBindTexture(GL_TEXTURE_2D, _imageTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, wpo2, hpo2, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
    
    free(texData);
    [self __setupVBOs];
}

- (void)setupTextureWithImage:(UIImage *)img processImageBytesBlock:(void (^)(GLubyte *bytes, size_t width, size_t height))processImageBytes
{
    _imgSize = img.size;
 
    
    glDeleteTextures(1, &_imageTexture);
    CGImageRef spriteImage = img.CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image");
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    
    GLubyte * imgData = (GLubyte *) malloc(width*height*4*sizeof(GLubyte));
    
    
    CGContextRef spriteContext = CGBitmapContextCreate(imgData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    UIGraphicsPushContext(spriteContext);
    CGContextSaveGState(spriteContext);
    [img drawInRect:CGRectMake(0, 0, width, height)];
    CGContextRestoreGState(spriteContext);
    UIGraphicsPopContext();
    CGContextRelease(spriteContext);
    
    if (processImageBytes != nil)
    {
        processImageBytes((GLubyte *)imgData, width,height);
    }
    
    [self setupTextureWithImageBytes:imgData imageSize:CGSizeMake(width, height)];
    
    free(imgData);
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods - Private
//////////////////////////////////////////////////////////////////////////

- (void)__setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
    {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)__setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)__setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (GLuint)__compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString)
    {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)__compileVertexShader:(NSString *)vertexShaderFile andFragmentShader:(NSString *)fragmentShaderFile
{
    
    // 1
    GLuint vertexShader = [self __compileShader:vertexShaderFile
                                       withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self __compileShader:fragmentShaderFile
                                         withType:GL_FRAGMENT_SHADER];
    
    // 2
    _programHandle = glCreateProgram();
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    glLinkProgram(_programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(_programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(_programHandle, "Position");
    _texCoordSlot = glGetAttribLocation(_programHandle, "TexCoordIn");
    _screenSizeUniform = glGetUniformLocation(_programHandle, "ScreenSize");
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    
    _texCoordSlot = glGetAttribLocation(_programHandle, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _textureUniform = glGetUniformLocation(_programHandle, "Texture");
}

- (void)__updateScreenSize
{
    glUniform2f(_screenSizeUniform, _eaglLayer.frame.size.width, _eaglLayer.frame.size.height);
}

- (void)__setupVBOs
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat ratio = screenWidth/_imgSize.width;
    CGFloat width = screenWidth;
    CGFloat height = _imgSize.height*ratio;
    if (height>screenWidth)
    {
        ratio = screenWidth/_imgSize.height;
        width = _imgSize.width*ratio;
        height = screenWidth;
    }
    
    Vertex vertices[] = {{{ width,   height, 0}, {_xPerc, _yPerc}},
        {{ width,  -height, 0}, {_xPerc, 0}},
        {{-width,  -height, 0}, {0, 0}},
        {{-width,   height, 0}, {0, _yPerc}}
    };
    
    memcpy(_vertices, vertices, sizeof(vertices));
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), _vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}


@end
