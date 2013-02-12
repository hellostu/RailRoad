varying lowp vec2 TexCoordOut; 
uniform sampler2D Texture; 

void main(void)
{
    lowp vec4 pixel = texture2D(Texture, TexCoordOut);
    gl_FragColor = pixel; 
}