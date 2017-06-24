import processing.video.*;

int cycleLength = 5;
int cycleCount = 0;
int lastTime = 0;
int t = 0;

int cx = 250;
int cy = 250;
int r = 200;
int fg = 0;

MovieMaker mm;

void setup() {
  size(500, 500);
  frameRate(30);
  //mm = new MovieMaker(this, width, height, "pendulum.mov",
  //                    30, MovieMaker.H263, MovieMaker.HIGH);
}

void draw() {
  int currentTime = millis();
  if (currentTime > lastTime+cycleLength*1000) {
    fg = 0;
    lastTime = currentTime;
    cycleCount++;
    if (cycleCount == 3) {
      mm.finish();
    }
  } else if (currentTime > lastTime+cycleLength*1000/2) {
    fg = 255;
  }
  background(255);
  stroke(0);
  strokeWeight(30);
  strokeCap(SQUARE);
  //fill(0);
  noFill();
  //rect(250, 0, 250, 500);
  
  //stroke(fg);
  //fill(fg);
  smooth();
  
  int duration = currentTime-lastTime;
  float t = float(duration) / float(cycleLength*1000) * 2.0*PI;
  
  int x = (int)(cx+r*cos(t+PI*1.5));
  int y = (int)(cy+r*sin(t+PI*1.5));
  ellipse(x, y, 50, 50);
  
  //int x = 250;
  //int y = 250;
  int width = 400;
  int height = 400;
  float start;
  float stop;
  /*if (cycleCount % 2 == 0) {
    start = -0.5*PI;
    stop = t-0.5*PI;
  } else {*/
    start = -0.5*PI+t;
    stop = 1.5*PI;
  //}
  arc(x, y, width, height, start, stop);
  
  t++;
  //mm.addFrame();
}

