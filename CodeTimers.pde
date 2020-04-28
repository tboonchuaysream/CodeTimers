/*
@author Tommy Boonchuaysream
 - this program contains 2 timers
 - one time runs the slideshow which show the images
 - the other keeps track of how long the shape behind the slideshow stays when a mouse click is registered
 */

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

String[] data;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

int serialIndex = 0;

// timing for slideshow
Timer displayTimer;
Timer blinkTimer;
float timePerLine = 0;
float minTimePerLine = 100;
float maxTimePerLine = 2000;
int defaultTimerPerLine = 1500;

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

//variables for the slideshow
PImage[] photoList;
int numImages = 6;
int currentImg = 0;

//triggers when to show or not show the shape when pressed
boolean toggle = false;

void setup ( ) {
  size (1000, 600);    

  // List all the available serial ports
  printArray(Serial.list());

  myPort  =  new Serial (this, Serial.list()[serialIndex], 115200); 

  // Allocate the timer
  displayTimer = new Timer(defaultTimerPerLine);
  blinkTimer = new Timer(1000);

  //start the slideshow
  startSlide();

  //create list
  photoList = new PImage[numImages];

  //input all images into the list
  photoList[0] = loadImage("assets/image1.jpg");
  photoList[1] = loadImage("assets/image2.jpg");
  photoList[2] = loadImage("assets/image3.jpg");
  photoList[3] = loadImage("assets/image4.jpg");
  photoList[4] = loadImage("assets/image5.jpg");
  photoList[5] = loadImage("assets/image6.jpg");
} 


//call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  

    print(inBuffer);

    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));

    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');

    //have THREE items — ERROR-CHECK HERE
    if ( data.length >= 3 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value

      // change the display timer
      timePerLine = map( potValue, minPotValue, maxPotValue, minTimePerLine, maxTimePerLine );
      displayTimer.setTimer( int(timePerLine));
      blinkTimer.setTimer( int(3000));
    }
  }
} 

//-- change background to red if we have a button
void draw ( ) {  
  // every loop, look for serial information
  checkSerial();

  drawBackground();
  checkTimer();
  checkMousePress();
  showSlide();
} 

// if input value is 1 (from ESP32, indicating a button has been pressed), change the background
void drawBackground() {
  background(174, 214, 241);
}



//-- resets all variables
void startSlide() {
  currentImg = 0;
  displayTimer.start();
}

//-- look at current value of the timer and change it
void checkTimer() {
  //-- if timer is expired, go to next  the line number
  if ( displayTimer.expired() ) {
    currentImg++;

    // check to see if we are at the end of the poem, then go to zero
    if ( currentImg == photoList.length ) 
      currentImg = 0;

    displayTimer.start();
  }
}


void showSlide() {

  image(photoList[currentImg], 200, 100, 600, 400);
}


void checkMousePress() {

  //if mouse is pressed, start the timer and toggle to true
  if (mousePressed == true) {
    blinkTimer.start();
    toggle = true;
  }

  //while toggle, draw the shape
  //if not, simply put the background
  if (toggle == true) {
    fill(195, 155, 211);
    ellipse(500, 300, 750, 750);
  } else if (toggle == false) {
    background(174, 214, 241);
  }

  //when timer has expired, turn it off
  // switch toggle to false
  if ( blinkTimer.expired() ) {
    toggle = false;
    blinkTimer.start();
  }
  
}
