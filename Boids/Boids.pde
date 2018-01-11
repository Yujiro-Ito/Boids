Fish[] _fish;
public int _seconds;

void setup(){
  size((int)(displayWidth * 0.7), (int)(displayHeight * 0.7));
  _fish = new Fish[50];
  for(int i = 0; i < _fish.length; i++){
    _fish[i] = new Fish(color((int)random(255), (int)random(255), (int)random(255)));
    _fish[i].setPosition(random(width), random(height));
  }
}

void draw(){
  println();
  background(255);
  for(int i = 0; i < _fish.length; i++){
    _fish[i].update();
  }
}

public Fish[] getFishes(){
  return _fish;
}



int _oldMillis;
public double doubleTime(){
  double result;
  result = (double)(millis() - _oldMillis) / 1000;
  _oldMillis = millis();
  return result;
}
