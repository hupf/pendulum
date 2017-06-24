/**
 * Download: https://www.funprogramming.org/VideoExport-for-Processing/
 */

import com.hamoid.*;

int cycleLength = 60;
int cycleCount = 2;
int targetFrameRate = 25;
int renderFrameRate = 25; // Default 3

boolean saveMovie = true;
boolean saveFrames = false;


VideoExport videoExport;
String movieFile = "pendulum.mp4";

PGraphics pg;
String filePrefix = "frame-";
String fileExt = ".png";

int cycleStart = 0;
int currentCycle = 0;
int t = 0;

void setup() {
  // https://de.wikipedia.org/wiki/Farbenklavier
  skriabinKeyboard = new IntDict();
  skriabinKeyboard.set("C", #ff0000);
  skriabinKeyboard.set("Db", #ce9aff);
  skriabinKeyboard.set("D", #ffff00);
  skriabinKeyboard.set("Eb", #656599);
  skriabinKeyboard.set("E", #e3fbff);
  skriabinKeyboard.set("F", #ac1c02);
  skriabinKeyboard.set("Gb", #00ccff);
  skriabinKeyboard.set("G", #ff6501);
  skriabinKeyboard.set("Ab", #ff00ff);
  skriabinKeyboard.set("A", #33cc33);
  skriabinKeyboard.set("Bb", #8c8a8c);
  skriabinKeyboard.set("B", #0000fe);
  
  size(1280, 720);
  frameRate(renderFrameRate);
  if (saveMovie) { 
    videoExport = new VideoExport(this, movieFile);
    videoExport.startMovie();
  }
}

void draw() {
  int duration = int(float(frameCount+1) / float(targetFrameRate) * 1000.0) - cycleLength*1000 * currentCycle;
  float t = float(duration) / float(cycleLength*1000);
  
  float start;
  float stop;
  if (currentCycle % 2 == 0) {
    start = (cos(t*2.0*PI)-0.5)*PI;
    stop = -sin(t*t*1.5*PI)*2*PI*t +0.5*PI;
  } else {
    stop = (cos(t*2.0*PI)-0.5)*PI+2*PI;
    start = -sin(t*t*1.5*PI)*2*PI*t +0.5*PI;
  }
  
  float ds = 0.8; // diameter scaling ratio
  float dv = 0.3; // diameter scaling variability
  float d = min(width, height)*ds * (cos(t*2.0*PI)*dv+1.0-dv);
  
  drawScreen(start, stop, d, duration, t, currentCycle);
  
  if (saveFrames) {
    drawPGraphics(start, stop, d, duration, t, currentCycle, frameCount);
  }
  
  if (saveMovie) {
    videoExport.saveFrame();
  }
  
  ++t;
  
  if (duration % (cycleLength*1000) == 0) {
    currentCycle++;
    if (currentCycle == cycleCount) {
      if (saveMovie) {
        videoExport.endMovie();
      }
      exit();
    }
  }
}

void drawScreen(float start, float stop, float d, int duration, float t, int currentCycle) {
  background(255);
  smooth();
  
  noFill();
  strokeWeight(min(width, height)*0.06);
  strokeCap(SQUARE);
  stroke(0);
  
  arc(width/2.0, height/2.0, d, d, start, stop);
  
  fill(0);
  text(nf(currentCycle, 2)+"   "+nf(duration/1000, 2)+"   "+nf(t, 1, 3)+"   "+nf(start, 1, 3)+"   "+nf(stop, 1, 3)+"   "+nf(d, 3, 3), 0, 10);
  noFill();
}

void drawPGraphics(float start, float stop, float d, int duration, float t, int currentCycle, int currentFrame) {
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  
//  pg.background(255);
  pg.smooth();
  
  pg.noFill();
  pg.strokeWeight(min(width, height)*0.06);
  pg.strokeCap(SQUARE);
  pg.stroke(0);
  
  pg.arc(width/2.0, height/2.0, d, d, start, stop);
  
  pg.fill(0);
  pg.text(nf(currentCycle, 2)+"   "+nf(duration/1000, 2)+"   "+nf(t, 1, 3)+"   "+nf(start, 1, 3)+"   "+nf(stop, 1, 3)+"   "+nf(d, 3, 3), 0, 10);
  pg.noFill();
  
  pg.save(filePrefix+ nf(currentFrame,5) +fileExt);
}
