attribute vec4 Position;
attribute vec4 SourceColor;

uniform vec2 ScreenSize;
varying vec4 DestinationColor;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void)
{
    DestinationColor = SourceColor;
    vec4 newPosition = Position;
    newPosition.x = Position.x / ScreenSize.x;
    newPosition.y = Position.y / ScreenSize.y;
    gl_Position = newPosition;
    
    TexCoordOut = TexCoordIn; 
}