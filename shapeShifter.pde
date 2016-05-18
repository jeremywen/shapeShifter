import themidibus.*;

/*********************************************************************************************
 * When you run this, the console will list "Available MIDI Devices"
 * Change the outDeviceNum to the midi output device number you want to use.
 * You may want to use a virtual midi bus -> https://www.ableton.com/en/help/article/using-virtual-MIDI-buses-live/
 *********************************************************************************************/
int outDeviceNum = 2;

float pulseSpeed = 2; 
float mouseDragOffsetX = 0;
float mouseDragOffsetY = 0;
float midX = 0;
float midY = 0;
ArrayList<Handle> handles;
PVector center;
MidiBus midiBus;

//////////////////////////////////////////////////////////////////////////////////////////////
//ideas
//maybe the middle one send pulses out and the sequence eminates out from the closest handle
//maybe the pulses push out the closest handle
//maybe the distance between handles corresponds to a pitch value
//handles determine synth params
//handles determine synth sequence
//////////////////////////////////////////////////////////////////////////////////////////////
void settings(){
  size(800,800);
}
void setup(){
  MidiBus.list();
  midiBus = new MidiBus(this, -1, outDeviceNum);
  background(255);
  rectMode(CENTER);
  midX = width/2;
  midY = height/2;  
  center = new PVector(0,0);
  resetHandles();
}

//////////////////////////////////////////////////////////////////////////////////////////////
void draw(){
  translate(midX, midY);
  background(255);
  
  //update handles
  for(int i=0;i<handles.size();i++){
   Handle curr = handles.get(i);
   curr.update();
  }
  
  //draw connections
  for(int i=0;i<handles.size();i++){
   strokeWeight(1);
   Handle curr = handles.get(i);
   stroke(50);
   if(i==0){
     Handle last = handles.get(handles.size() - 1);
     line(last.vect.x, last.vect.y, curr.vect.x, curr.vect.y);
   } else {
     Handle prev = handles.get(i - 1);
     line(prev.vect.x, prev.vect.y, curr.vect.x, curr.vect.y);
   }
   
   //line from center
   stroke(200);
   line(0, 0, curr.vect.x, curr.vect.y);
   
   //pulse from center
   stroke(200);
   strokeWeight(3);
   PVector pulseVect = curr.pulseVect();
   line(0, 0, pulseVect.x, pulseVect.y);
  }
  
  //draw center
  fill(150);
  strokeWeight(3);
  float ellSize = 20;//sin(frameCount*0.04)*20;
  rect(0, 0, ellSize, ellSize);

  //draw handles
  for(int i=0;i<handles.size();i++){
   Handle curr = handles.get(i);
   curr.draw();
  }
  
}

//////////////////////////////////////////////////////////////////////////////////////////////
void resetHandles(){
  handles = new ArrayList<Handle>();
  PVector maxVect = new PVector(width*0.45, height*0.45);
  for(int i=0;i<10;i++){
    Handle handle = new Handle();
    float sinVal = sin(i*0.65);
    float cosVal = cos(i*0.65);
    handle.vect.x = sinVal * ((maxVect.x/2)+random(maxVect.x/2));
    handle.vect.y = cosVal * ((maxVect.y/2)+random(maxVect.y/2));
    handles.add(handle);
  }
}

Handle getHandleAtMouse(){
    for(Handle handle : handles){
      if(handle.contains(mouseX-midX, mouseY-midY)){
        return handle;
      }
    }
    return null;
}

void mouseClicked(){
  if(mouseButton==LEFT){
  }else if(mouseButton==RIGHT){
    resetHandles();
  } else {
  }
}

void mousePressed(){
  if(mouseButton==LEFT){
    Handle handle = getHandleAtMouse();
    if(handle!=null){
      handle.dragging = true;
      mouseDragOffsetX = mouseX - handle.vect.x;
      mouseDragOffsetY = mouseY - handle.vect.y;
      
      //move to bottom so it's painted last (on top)
      //handles.remove(handle);
      //handles.add(handle);
    }
  }else if(mouseButton==RIGHT){
  } else {
  }
}

void mouseReleased(){
  for(Handle handle : handles){
   handle.dragging = false;
  }
}

void mouseDragged(){
  for(Handle handle : handles){
    if(handle.dragging){
      handle.vect.x = mouseX - mouseDragOffsetX;
      handle.vect.y = mouseY - mouseDragOffsetY;
      break;
    }
  }
}

void mouseMoved(){
}

void keyPressed(){
  if(key==' '){
    Handle handle = getHandleAtMouse();
    if(handle!=null){
      println("---------");
      println("dist "+handle.vect.dist(center));
      println("mag "+handle.vect.mag());
      println("pulse dist "+handle.pulseVect().dist(center));
      println("pulse mag "+handle.pulseVect().mag());
    }
  } else if(key=='w'){
  } else if(key=='e'){
  } else if(key=='r'){
  } else if(key=='t'){
  } else if(key=='y'){
  } else if(keyCode==10){//enter key    
  } else if(keyCode==8){//backspace key    
  } else if(keyCode==9){//tab key
  } else if(keyCode==127){//Delete button
  }
//  println("key = " + key + ", keyCode = " + keyCode + ", CODED = " + (key == CODED));
}

void keyReleased(){
  if(key == CODED){
    if(keyCode == 17){//CTRL
    }
    if(keyCode == 18){//ALT
    }
  }
}

///////////////////////////////////////////////////////////////
// Handle Class
///////////////////////////////////////////////////////////////
class Handle {
  
  boolean dragging = false;
  boolean pulseInHandle = false;
  boolean noteSent = false;
  PVector vect = new PVector(0,0);
  float pulseDist = 0;
  int w = 20;
  int h = 20;
  int pitch = 24+(int)random(48);
  color c = color(100);
  
  void update(){
    if(pulseDist < vect.dist(center)){
      pulseDist+=pulseSpeed;
    } else {
      pulseDist=0;
      noteSent = false;      
    }
    PVector pulseVect = pulseVect();
    pulseInHandle = contains(pulseVect.x, pulseVect.y);
    if(pulseInHandle && !noteSent){
      sendNote(0, pitch, 100, 100);
      noteSent = true;
    }
  }
  
  void draw(){
    stroke(200);
    strokeWeight(3);
    if(pulseInHandle){
      fill(200,200,220);
    } else {
      fill(c);
    }
    rect(vect.x,vect.y,w,h);
  }
  
  PVector pulseVect(){
    PVector p = vect.get();
    p.setMag(pulseDist);
    return p;
  }
  
  boolean contains(float pointX, float pointY){
    return pointX > vect.x-w/2 
        && pointX < vect.x+w/2 
        && pointY > vect.y-h/2
        && pointY < vect.y+h/2;
  }
}

public void sendNote(final int channel, final int pitch, final int velocity, final int duration){
    Thread thread = new Thread(new Runnable(){
      public void run(){
        //println("sending note c:"+channel+" p:"+pitch+", v:"+velocity+", d:"+duration+", ");
        midiBus.sendNoteOn(channel, pitch, velocity);
        delay(duration);
        midiBus.sendNoteOff(channel, pitch, velocity);
      }
    }
    );
    thread.start();
  }