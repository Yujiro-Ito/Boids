class Fish {
  //----Cosnts----
  public static final float SIZE = 10;
  public static final float ADD_SPEED = 1;
  public static final float COHESION_RANGE = 100;
  public static final float SEPARATION_RANGE = 80;

  //----Fields----
  private float _angle;
  //-position-
  private PVector _position;
  public PVector getPosition(){ return _position; }
  public void setPosition(float x, float y){ _position.set(x, y); }
  //-speed-
  private PVector _oldSpeed;
  private PVector _speed;
  public PVector getSpeed(){ return _speed; }
  public void setSpeed(PVector value){ _speed = value; }
  //-other-
  private color _color;
  private Fish[] _cohesionAndAlignFishes;
  private Fish[] _separateFishes;
  private int _approachFishCount;
  private int _separateFishCount;
  private PVector _calVec;
  private boolean _debug;

  public Fish(color col) {
    //--initialize variable--
    _angle = (int)random(0, 360 + 1);
    _position = new PVector();
    _color = col;
    _speed = new PVector();
    _oldSpeed = new PVector();
    _speed.set(sin(_angle), cos(_angle));
    _cohesionAndAlignFishes = new Fish[getFishes().length];
    _separateFishes = new Fish[getFishes().length];
    _approachFishCount = 0;
    _calVec = new PVector();
    _debug = false;
  }

  public void update() {
    if(_debug)println("----------");
    Debug();
    _calVec.set(0, 0, 0);
    getIntoRangeFishes();
    
    //execute of boids algorism
    alignmentAndCohesion();
    separation();
    
    //calclation speed vector
    PVector unitVectorSpeed = _speed;
    if(!(_calVec.x == 0 && _calVec.y == 0)){
      _speed.add(_calVec);
      unitVectorSpeed = getUnitVector(_speed);
    }
    //add the speed to position
    _position.x += unitVectorSpeed.x * ADD_SPEED;
    _position.y += unitVectorSpeed.y * ADD_SPEED;
    
    
    //show me
    fill(_color);
    ellipse(_position.x, _position.y, SIZE, SIZE);
    if(_position.x > width) _position.x = 0;
    else if(_position.x < 0) _position.x = width;
    if(_position.y > height) _position.y = 0;
    else if(_position.y < 0) _position.y = height;
  }
  
  public void separation(){
    //---separation----
    //if when could find fishes calcuration direction
    if(_separateFishCount != 0){
      PVector avg = new PVector();
      for(int i = 0; i < _separateFishCount; i++){
        PVector calc = new PVector();
        calc.x = _separateFishes[i].getPosition().x - _position.x;
        calc.y = _separateFishes[i].getPosition().y - _position.y;
        calc.x = 1 / calc.x;
        calc.y = 1 / calc.y;
        avg.sub(calc);
        if(_debug){
          fill(255, 100, 50);
          ellipse(_separateFishes[i].getPosition().x,
                  _separateFishes[i].getPosition().y,
                  SIZE * 0.7, SIZE * 0.7);
        }
      }
      avg.div(_separateFishCount);
      avg = getUnitVector(avg);
      _calVec.add(avg);
      if(_debug){
        stroke(255, 100, 50);
        println("separation : " + avg);
        float x = _position.x + avg.x * 40;
        float y = _position.y + avg.y * 40;
        line(_position.x, _position.y, x, y);
      }
    } else if(_debug == true) {
      println("separation is Boooom");
    }
  }
  
  public void alignmentAndCohesion(){
    //if when could find fishes calcuration direction
    if(_approachFishCount != 0){
      //---alignment---
      PVector avg = new PVector();
      for(int i = 0; i < _approachFishCount; i++){
        avg.add(_cohesionAndAlignFishes[i].getSpeed());
      }
      avg.div(_approachFishCount);
      avg = getUnitVector(avg);
      _calVec.add(avg);
      if(_debug){
        stroke(0, 0, 255);
        println("alignment : " + avg);
        float x = _position.x + avg.x * 40;
        float y = _position.y + avg.y * 40;
        line(_position.x, _position.y, x, y);
      }
      
      //---cohesion---
      avg.set(0, 0);
      for(int i = 0; i < _approachFishCount; i++){
        avg.add(_cohesionAndAlignFishes[i].getPosition());
      }
      avg.div(_approachFishCount);
      avg.sub(_position);
      avg = getUnitVector(avg);
      _calVec.add(avg);
      if(_debug){
        stroke(0, 255, 0);
        println("cohesion : " + avg);
        float x = _position.x + avg.x * 40;
        float y = _position.y + avg.y * 40;
        line(_position.x, _position.y, x, y);
      }
    } else if(_debug){
      println("alignment is Boooom");
      println("cohesion is Boooom");
    }
  }
  
  public void Debug(){
    OnDebug();
    if(_debug)strokeWeight(5);
    else strokeWeight(1);
    stroke(255, 0, 0);
    PVector unitVectorSpeed = getUnitVector(_speed);
    //add the speed to position
    float posX = _position.x + unitVectorSpeed.x * ADD_SPEED * 40;
    float posY = _position.y + unitVectorSpeed.y * ADD_SPEED * 40;
    line(_position.x, _position.y, posX, posY);
    stroke(0);
  }
  
  public void OnDebug(){
    float dist = sqrt( sq(mouseX - _position.x) + sq(mouseY - _position.y));
    if(dist < 20)_debug = true;
    else _debug = false;
  }
  
  public void getIntoRangeFishes(){
    _approachFishCount = 0;
    _separateFishCount = 0;
    //get into approach range fishes
    for(int i = 0; i < getFishes().length; i++){
      float dx = getFishes()[i].getPosition().x - _position.x;
      float dy = getFishes()[i].getPosition().y - _position.y;
      float dist = sqrt(sq(dx) + sq(dy));
      if(dist < COHESION_RANGE && dist > SEPARATION_RANGE){
        _cohesionAndAlignFishes[_approachFishCount] = getFishes()[i];
        _approachFishCount++;
      }
      if(dist < SEPARATION_RANGE && dist != 0){
        _separateFishes[_separateFishCount] = getFishes()[i];
        _separateFishCount++;
      }
    }
  }
  
  //comvert to unit vector
  public PVector getUnitVector(PVector vec){
    PVector result = vec;
    float vectorSize = vec.mag();
    result.div(vectorSize);
    return result;
  }
}

