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
  mm = new MovieMaker(this, width, height, "pendulum5b.mov",
                      30, MovieMaker.H263, MovieMaker.HIGH);
}

void draw() {
  int currentTime = millis();
  if (currentTime > cycleStart+cycleLength*1000) {
    cycleStart = currentTime;
    cycleCount++;
    if (cycleCount == 4) {
    mm.finish();
      exit();
    }
  }
  background(255);
  smooth();
  
  int duration = currentTime-cycleStart;
  float t = float(duration) / float(cycleLength*1000);
  
  float start;
  float stop;
  


  if (cycleCount % 2 == 0) {
    start = (cos(t*2.0*PI)-0.5)*PI;
    stop = -sin(t*t*1.5*PI)*2*PI*t +0.5*PI;
  } else {
    start = (cos(t*2.0*PI)-0.5)*PI;
    stop = -sin(t*t*1.5*PI)*2*PI*t +0.5*PI;
  }
  
  float d = 2*r;
//  float ds = 0.3;
//  float d = 2*r * (cos(t*2.0*PI)*ds+1.0-ds);
  
  noFill();
  strokeWeight(30);
  strokeCap(SQUARE);
  stroke(0);
  
  arc(cx, cy, d, d, start, stop);
  
  fill(0);
  text(duration/1000, 10, 10);
  text(t, 30, 10);
  text(start, 150, 10);
  text(stop, 200, 10);
  noFill();
  
  t++;
  mm.addFrame();
}

