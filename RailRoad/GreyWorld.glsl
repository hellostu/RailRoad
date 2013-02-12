varying lowp vec2 TexCoordOut; // New
uniform sampler2D Texture; // New
uniform lowp vec3 Avg;

void main(void)
{
    lowp vec4 pixel = texture2D(Texture, TexCoordOut);
    lowp float r = pixel.r;
    lowp float g = pixel.g;
    lowp float b = pixel.b;
    
    r = pow(pow(r,2.2)/Avg.r,1.0/2.2);
    g = pow(pow(g,2.2)/Avg.g,1.0/2.2);
    b = pow(pow(b,2.2)/Avg.b,1.0/2.2);
    
    pixel = vec4(r,g,b,1.0);
    
    gl_FragColor = pixel; 
}