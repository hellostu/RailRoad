varying lowp vec2 TexCoordOut; // New
uniform sampler2D Texture; // New
uniform lowp float BrightnessValue;

void main(void)
{
    lowp vec4 pixel = texture2D(Texture, TexCoordOut);
    
    gl_FragColor = pixel*Brightness; 
}