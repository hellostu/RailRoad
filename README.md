RailRoad
========

Process the Frames of an iOS device Camera in realtime quickly and easily 
 \author Stuart Lynch stuart.lynch@uea.ac.uk

 
 This is a completely Open Source project that provides a simple framework to process the live camera frames of an iOS device. It is distributed under the \link<License>GNU General Public License\endlink. I developed this because I wanted an easy way to code image processing algorithms on a mobile device. OpenGL ES 2 can be quite complex to set up and use, so this project aims to simplify the setup, and target it for a specific single texture application. 
 More detailed documentation can be found in the Doc folder of this project.
 
 The flow of processing is:
 
1) Retrieve a UIImage of the frame (a UIImage is a class developed by Apple to represent a stored image).

2) Get the bytes that make up the image and do any global processing on the CPU.
 
3) Take any output from the CPU processing and send to the GPU for super fast pixel-by-pixel processing. 

4) Display the frame. 

Setup
-----
 
If you are familar with iOS and Cocoa then you can embed this in your own project. Simply add an instance of RRCameraView and embed it where you like in your interface. Follow the instructions for further setup below.
 
 If you are not familar with iOS then you can still used this project. The main class of interest to you is RRMainViewController. You can develop your own algorithm just by adding your own code here.  RRMainViewController is already setup with initalization code, but the following documentation (for tutorial purposes) will talk you through the initalization as if it wasn't. 
 
 In the `viewDidLoad` method, the first thing to do is intialize a new instance of RRCameraView. 
```Objective-C
_cameraView = [[RRCameraView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
 ```
 We want to recieve the delegate methods from the RRCameraCaptureSession in the RRCameraView. So we set our class (RRMainViewController) to implement the `<RRCameraCaptureSessionDelegate>`. Then add this code below the initialization of `_cameraView`:
 
```objective-c
_cameraView.cameraCaptureSession.delegate = self;
```
 
 
We then want to initalize OpenGL on the view. We pass in the name of a fragment shader. This is a file in the bundle which has a suffix '.glsl' and contains the code for the pixel-by-pixel processing on the GPU. If we don't want to do any processing we can pass in 'DoNothing' which is a shader that does no processing, it simply just displays the pixels. For this tutorial we will pass in the 'Brightness' shader. 
 
```objective-c
[_cameraView intializeOpenGLWithShader:@"Brightness"];
```
 
The brightness shader simply scales the pixel by a given amount. We have to provide it with the scaler that we want to change the brightness to. We can pass in a Uniform Variable to the shader, which is a variable that will remain constant for all of the pixels of that image. The Brightness shader contains a variable `BrightnessValue`. So we will we define this using the following code:

```objective-c
[_cameraView.openGL initShaderUniform:@"BrightnessValue" ofDataType:GLSL_DATA_TYPE_FLOAT];
```
 
The method above defines the shader uniform variable and defines it's datatype. In this case it is a float. We can then set the value of this variable by calling the following code:

```objective-c
GLfloat brightnessValue = 0.5f;`
[_cameraView.openGL shaderUniform:@"BrightnessValue" setValue:&brightnessValue];
```
 
 We have to provide a pointer to the data as the value. This is because the value could be one of several datatypes, including an array. We now want to implement the delegate method. Create a new method:

```objective-c
- (void)cameraCaptureSession:(RRCameraCaptureSession *)session capturedImage:(UIImage *)image
```

In this method we want to send the UIImage to the GPU using OpenGL. We can do this by calling the following method on the OpenGL instance contained in the RRCameraView:
 
```objective-c
[_cameraView.openGL setupTextureWithImage:image processImageBytesBlock:nil];
```
 For the moment we won't do any processing on the CPU of the image. We will just send it straight to the GPU for display, therefore we set the `processImageBytesBlock` argument to `nil`. Finally we render the image by calling this function directly after:

```objective-c
[_cameraView.openGL render];
```
 
 If you run the code, you will see the camera frames displayed at 50% brightness.
