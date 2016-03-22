import deadpixel.keystone.*;
import SimpleOpenNI.*;
SimpleOpenNI kinect;

float closestValue;
int closestX;
int closestY;
int xcalculation = 640;
int ycalculation = 480;

int sensingArea = 610;
int sensingTolerance = 15;

float red = 0;
float green = 0;
float blue = 0;

PImage depthImg;
PGraphics offscreen;
Boolean renderKinectScreen =true;
Boolean drawing_mode = true;
Keystone ks;
CornerPinSurface surface;

void setup()
{
  size(1920, 1080, P3D);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  frameRate(60);
  kinect.setMirror(false);
  depthImg = new PImage(640, 480, ARGB);

  offscreen = createGraphics(640, 480, P3D);
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(640, 480, 20);
}

void draw()
{
  //Random color variables for the draw effect
  red = random(0,255);
  green = random(0,255);
  blue = random(0,255);
  PVector surfaceMouse = surface.getTransformedMouse();
  //Offscreen rendering for the keystone projection mapping library.
  offscreen.beginDraw();
  offscreen.background(255);
  offscreen.fill(0, 255, 0);
  offscreen.endDraw();
  background(0);
  
  //THis is the start of the Kinect code, it will start gathering data here
  closestValue = 8000;
  kinect.update();
  int[] depthValues = kinect.depthMap();
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  for (int y=0; y <ycalculation; y++) {
    for (int x = 0; x< xcalculation; x++) {
      //This is the magical i that will map out all of the depth data!
      int i = x + y * xcalculation;
      int currentDepthValue = depthValues[i];
      
      //This finds the closest point amongst the depth values
      if ((currentDepthValue/25.4) > 0 && (currentDepthValue/25.4) < 25.0) {
        closestValue = currentDepthValue;
        closestX = x;
        closestY = y;
      }
      
      //This is a rudimentary blob detector, detecting when something is at a certain depth and then drawing a blob around the detected surface
      if ( currentDepthValue > sensingArea - sensingTolerance && currentDepthValue < sensingArea + sensingTolerance) {
        depthImg.pixels[i] = color(red, green, blue);
        sumX += x;
        sumY += y;
        count++;
      }else if (drawing_mode == true){ depthImg.pixels[i] = color(0,0);}
    }
  }

  float avgX = 0;
  float avgY = 0;
  
  //This will find average values just in case you want to find the average center of each of the blob that is detected.
  if (count != 0) {
    avgX = sumX/count;
    avgY = sumY/count;
  }

  if (renderKinectScreen == true) {
    image(kinect.depthImage(), 0, 0);
  }
  depthImg.updatePixels();
  //image(depthImg, 0, 0);
  pushStyle();
  //fill(0, 0, 255);
  //ellipse(avgX, avgY, 50, 50);
  popStyle();
  if (renderKinectScreen == true) {
    surface.render(kinect.depthImage());
  }
  surface.render(depthImg);
  
  //surface.render is used towards the end to render the keystone mapping image.
}




void mousePressed()
{
  //  //int[] depthValues = kinect.depthMap();
  //  int clickPosition = mouseX + (mouseY * xcalculation);
  //  //int millimeters = depthValues[clickPosition];
  //  float inches = millimeters / 25.4;
  //  println("mm: " + millimeters + " " + "inches: " + inches);
  //  println(mouseX *3, mouseY*2.25);
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;

  case 'r':
    //Turns on the screen that shows "Kinect vision"
    if (renderKinectScreen == true) {
      renderKinectScreen = false;
    } else {
      renderKinectScreen = true;
    }
    break;


  case 'e':
  //This will erase blobs that are on the screen when the draw function is active.
    for (int y=0; y <ycalculation; y++) {
      for (int x = 0; x< xcalculation; x++) {
        int i = x + y * xcalculation;
        depthImg.pixels[i] = color(0, 0);
      }
    }
    break;
  
  case 'd':
  //Turns draw mode on and off
    if(drawing_mode == true){drawing_mode=false;}
    else{drawing_mode = true;}
  }
}

