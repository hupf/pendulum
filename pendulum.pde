/**
 * Download: https://www.funprogramming.org/VideoExport-for-Processing/
 */

import com.hamoid.*;

static class PLSettings {
  static int cycleLength = 60000; // ms
  static int cycleCount = 2;
  
  static boolean displayCaption = true;
  
  static float maxStrokeWeight = 45.0;
  static float minStrokeWeight = 10.0;
  static int strokeWeightCycle = 30000 * 2; // ms

  static int skriabinDuration = 6000; // ms
  static int skriabinTransition = 3000; // ms
  static String[] skriabinBaseProgression =
    { "Db", "D", "B", "Gb", "G", "E", "G", "Gb", "B", "D" };
  static String[] skriabinIntervalProgression =
    { "D", "B", "Db", "G", "Eb", "Gb", "Eb", "G", "Db", "B" };

  // Used to render frames/movie
  static int targetFrameRate = 25;

  // Used to display on screen
  // (may be set to low value, eg. 3, when saving movie/frames)
  static int renderFrameRate = 25;

  static boolean saveMovie = false;
  static String movieFile = "pendulum.mp4";

  static boolean saveFrames = false;
  static String framePrefix = "frame-";
  static String frameExt = ".png";
}

VideoExport videoExport;
PGraphics pg;

int cycleStart = 0;
int currentCycle = 0;
int t = 0;
IntDict skriabinKeyboard;
int skriabinStep = 0;

void setup() {
  size(1280, 720);
  frameRate(PLSettings.renderFrameRate);

  if (PLSettings.saveMovie) { 
    videoExport = new VideoExport(this, PLSettings.movieFile);
    videoExport.startMovie();
  }

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
}

void draw() {
  int duration = int(float(frameCount + 1) / float(PLSettings.targetFrameRate) * 1000.0)
    - PLSettings.cycleLength * currentCycle;
  float t = float(duration) / float(PLSettings.cycleLength);

  float start;
  float stop;
  if (currentCycle % 2 == 0) {
    start = (cos(t * 2.0 * PI) - 0.5) * PI;
    stop = -sin(t * t * 1.5 * PI) * 2 * PI * t + 0.5 * PI;
  } else {
    stop = (cos(t * 2.0 * PI) - 0.5) * PI + 2 * PI;
    start = -sin(t * t * 1.5 * PI) * 2 * PI * t + 0.5 * PI;
  }

  float ds = 0.8; // diameter scaling ratio
  float dv = 0.3; // diameter scaling variability
  float d = min(width, height) * ds * (cos(t * 2.0 * PI) * dv + 1.0 - dv);
  
  int strokeWeightDuration;
  if ((duration % PLSettings.strokeWeightCycle * 2) < PLSettings.strokeWeightCycle) {
    strokeWeightDuration = duration % PLSettings.strokeWeightCycle;
  } else {
    strokeWeightDuration = PLSettings.strokeWeightCycle - (duration % PLSettings.strokeWeightCycle);
  }
  float stroke = strokeWeightDuration / float(PLSettings.strokeWeightCycle) * 2.0
    * (PLSettings.maxStrokeWeight - PLSettings.minStrokeWeight) + PLSettings.minStrokeWeight;

  if (duration % PLSettings.skriabinDuration == 0) {
    ++skriabinStep;
    if (skriabinStep >= PLSettings.skriabinBaseProgression.length) {
      skriabinStep = 0;
    }
  }
  
  new PLRenderer(this.g).renderFrame(start, stop, d, stroke,
                                     duration, t, currentCycle);

  if (PLSettings.saveMovie) {
    videoExport.saveFrame();
  }

  if (PLSettings.saveFrames) {
    pg = createGraphics(width, height, JAVA2D);
    pg.beginDraw();
    new PLRenderer(pg).renderFrame(start, stop, d, stroke,
                                   duration, t, currentCycle);
    pg.save(PLSettings.framePrefix + nf(frameCount, 5) + PLSettings.frameExt);
  }

  ++t;

  if (duration % (PLSettings.cycleLength) == 0) {
    currentCycle++;
    if (currentCycle == PLSettings.cycleCount) {
      if (PLSettings.saveMovie) {
        videoExport.endMovie();
      }
      exit();
    }
  }
}


class PLRenderer {
  private PGraphics g;

  PLRenderer(PGraphics g) {
    this.g = g;
  }

  void renderFrame(float start, float stop, float d, float stroke,
                   int duration, float t, int currentCycle) {
    SkriabinColors colors = getSkriabinColors(duration);
    color bg = colors.base;
    color fg = colors.interval;
    
    this.g.background(bg);
    this.g.smooth();

    this.g.noFill();
    //this.g.strokeWeight(min(width, height) * 0.06);
    this.g.strokeWeight(stroke);
    this.g.strokeCap(SQUARE);
    this.g.stroke(fg);

    this.g.arc(width/2.0, height/2.0, d, d, start, stop);

    if (PLSettings.displayCaption) {
      this.g.fill(fg);
      String[] captionValues = {
        nf(currentCycle, 2), 
        nf(duration/1000, 2), 
        nf(t, 1, 3), 
        nf(start, 1, 3), 
        nf(stop, 1, 3), 
        nf(d, 3, 3)
      };
      this.g.text(join(captionValues, "   "), 0, 10);
      this.g.noFill();
    }
  }
  
  private SkriabinColors getSkriabinColors(int duration) {
    int skriabinTime = duration % PLSettings.skriabinDuration;
    int nextSkriabinStep = (skriabinStep + 1) % PLSettings.skriabinBaseProgression.length;
    float transitionPercent = 0;
    if (skriabinTime >= PLSettings.skriabinDuration - PLSettings.skriabinTransition) {
      transitionPercent = (skriabinTime - PLSettings.skriabinDuration + PLSettings.skriabinTransition)
        / float(PLSettings.skriabinTransition);
    }
  
    color base = skriabinKeyboard.get(PLSettings.skriabinBaseProgression[skriabinStep]);
    color nextBase = skriabinKeyboard.get(PLSettings.skriabinBaseProgression[nextSkriabinStep]);
    base = lerpColor(base, nextBase, transitionPercent);
  
    color interval = skriabinKeyboard.get(PLSettings.skriabinIntervalProgression[skriabinStep]);
    color nextInterval = skriabinKeyboard.get(PLSettings.skriabinIntervalProgression[nextSkriabinStep]);
    interval = lerpColor(interval, nextInterval, transitionPercent);
  
    return new SkriabinColors(base, interval);
  }
  
}

class SkriabinColors { 
  color base, interval;

  SkriabinColors(color b, color i) {
    base = b;
    interval = i;
  }
}