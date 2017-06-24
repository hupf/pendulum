import processing.video.*;

int cycleLength = 60;
int cycleCount = 2;
int targetFrameRate = 25;
int renderFrameRate = 3;

boolean saveMovie = false;
boolean saveFrames = true;



MovieMaker mm;
String movieFile = "movie.mov";

PGraphics pg;
String filePrefix = "frame-";
String fileExt = ".png";

int cycleStart = 0;
int currentCycle = 0;
int t = 0;

void setup() {
  size(1280, 720);
  frameRate(renderFrameRate);
  if (saveMovie) { 
    mm = new MovieMaker(this, width, height, movieFile,
                        targetFrameRate, MovieMaker.H263, MovieMaker.LOSSLESS);
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
    mm.addFrame();
  }
  
  ++t;
  
  if (duration % (cycleLength*1000) == 0) {
    currentCycle++;
    if (currentCycle == cycleCount) {
      if (saveMovie) {
        mm.finish();
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
