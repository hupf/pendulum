/**
 * Download: https://www.funprogramming.org/VideoExport-for-Processing/
 */

import com.hamoid.*;

int cycleLength = 60;
int cycleCount = 2;
int targetFrameRate = 25; // Used to render movie
int renderFrameRate = 25; // Used to display on screen (may be set to low value, eg. 3, when saving movie)

boolean saveMovie = false;
boolean saveFrames = false;

IntDict skriabinKeyboard;
int skriabinDuration = 6000;
int skriabinTransition = 1000;
String[] skriabinBaseProgression =
  { "Db", "D", "B", "Gb", "G", "E", "G", "Gb", "B", "D" };
String[] skriabinIntervalProgression =
  { "D", "B", "Db", "G", "Eb", "Gb", "Eb", "G", "Db", "B" };
int skriabinStep = 0;

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
  
  if (duration % skriabinDuration == 0) {
    ++skriabinStep;
    if (skriabinStep >= skriabinBaseProgression.length) {
      skriabinStep = 0;
    }
  }
  
  SkriabinColors colors = getSkriabinColors(duration);
  
  drawScreen(start, stop, d, duration, t, currentCycle, colors.base, colors.interval);
  
  if (saveFrames) {
    drawPGraphics(start, stop, d, duration, t, currentCycle, frameCount, colors.base, colors.interval);
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

class SkriabinColors { 
  color base, interval;
  
  SkriabinColors(color b, color i) {
    base = b;
    interval = i;
  }
}

SkriabinColors getSkriabinColors(int duration) {
  int skriabinTime = duration % skriabinDuration;
  int nextSkriabinStep = (skriabinStep + 1) % skriabinBaseProgression.length;
  float transitionPercent = 0;
  if (skriabinTime >= skriabinDuration - skriabinTransition) {
    transitionPercent = (skriabinTime - skriabinDuration + skriabinTransition) / float(skriabinTransition);
  }
  
  color base = skriabinKeyboard.get(skriabinBaseProgression[skriabinStep]);
  color nextBase = skriabinKeyboard.get(skriabinBaseProgression[nextSkriabinStep]);
  base = lerpColor(base, nextBase, transitionPercent);
  
  color interval = skriabinKeyboard.get(skriabinIntervalProgression[skriabinStep]);
  color nextInterval = skriabinKeyboard.get(skriabinIntervalProgression[nextSkriabinStep]);
  interval = lerpColor(interval, nextInterval, transitionPercent);
  
  return new SkriabinColors(base, interval);
}

void drawScreen(float start, float stop, float d, int duration, float t, int currentCycle, color bg, color fg) {
  background(bg);
  smooth();
  
  noFill();
  strokeWeight(min(width, height)*0.06);
  strokeCap(SQUARE);
  stroke(fg);
  
  arc(width/2.0, height/2.0, d, d, start, stop);
  
  fill(fg);
  text(nf(currentCycle, 2)+"   "+nf(duration/1000, 2)+"   "+nf(t, 1, 3)+"   "+nf(start, 1, 3)+"   "+nf(stop, 1, 3)+"   "+nf(d, 3, 3), 0, 10);
  noFill();
}

void drawPGraphics(float start, float stop, float d, int duration, float t, int currentCycle, int currentFrame, color bg, color fg) {
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  
//  pg.background(bg);
  pg.smooth();
  
  pg.noFill();
  pg.strokeWeight(min(width, height)*0.06);
  pg.strokeCap(SQUARE);
  pg.stroke(fg);
  
  pg.arc(width/2.0, height/2.0, d, d, start, stop);
  
  pg.fill(fg);
  pg.text(nf(currentCycle, 2)+"   "+nf(duration/1000, 2)+"   "+nf(t, 1, 3)+"   "+nf(start, 1, 3)+"   "+nf(stop, 1, 3)+"   "+nf(d, 3, 3), 0, 10);
  pg.noFill();
  
  pg.save(filePrefix+ nf(currentFrame,5) +fileExt);
}