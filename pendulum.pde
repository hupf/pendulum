import processing.video.*;

int cycleLength = 10;
int cycleCount = 0;
int cycleStart = 0;
int t = 0;

int cx = 250;
int cy = 250;
int r = 200;

MovieMaker mm;

void setup() {
  size(500, 500);
  frameRate(30);
//  mm = new MovieMaker(this, width, height, "pendulum5b.mov",
//                      30, MovieMaker.H263, MovieMaker.HIGH);
}

void draw() {
  int currentTime = millis();
  if (currentTime > cycleStart+cycleLength*1000) {
    cycleStart = currentTime;
    cycleCount++;
    if (cycleCount == 2) {
//    mm.finish();
      exit();
    }
  }
  background(255);
  smooth();
  
  int duration = currentTime-cycleStart;
  float t = float(duration) / float(cycleLength*1000);
  
  fill(0);
  text(duration/1000, 10, 10);
  noFill();
  
  int x = 250;
  int y = 250;
  float d = 2.0*r;
  float start;
  float stop;
  
//  start = (cos(t*2.0*PI)-0.5)*PI;
//  stop = start+0.1;
  
  stop = cos(t*2.0*PI)*0.5*PI;
//  stop = cos(t*2.0*PI+PI)+cos(t*1.5*PI)*PI;
//  cos(x*2.0*PI)+sin(x*1.0*PI)
  start=stop-0.1;

  /*if (cycleCount % 2 == 0) {
    start = (cos(t*2.0*PI)-0.5)*PI;
    stop = cos(t*PI)*0.5*PI;
  } else {
  }*/
  
//  d = d * cos(t*2.0*PI);
  
  noFill();
  strokeWeight(30);
  strokeCap(SQUARE);
  stroke(0);
  
  arc(cx, cy, d, d, start, stop);
  
  t++;
//  mm.addFrame();
}

