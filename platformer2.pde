Unicorn u;
Platform [] platforms;
// Platform p;
boolean left,right,up,down,space, shift;

PImage [] spriteImages;
PImage laser;
int frames;

// Bullet b;
Bullet [] bullets;
int nextBullet;

Timer firingTimer;

void setup() {
	size(800,600);

	frames = 12;
	spriteImages = new PImage[frames];
	for (int i = 0; i<frames; i++){
		spriteImages[i]=loadImage("unicorn"+nf(i+1,4)+".png");
	}
	laser = loadImage("laser.png");

	u = new Unicorn();
	platforms = new Platform[4];
	platforms[0] = new Platform (300,460,200,25,"safe");
	platforms[1] = new Platform (0,300,200,25,"safe");
	platforms[2] = new Platform (600,300,200,25,"safe");
	platforms[3] = new Platform (300,140,200,25,"safe");

	// b = new Bullet();
	bullets = new Bullet [50];
	for (int i = 0; i < bullets.length; ++i) {
		bullets[i] = new Bullet();
	}
	nextBullet = 0;

	left = false;
	right = false;
	up = false;
	down = false;
	space = false;
	shift = false;

	firingTimer = new Timer(300);
	firingTimer.start();
}

void draw() {
	background(255);
	u.update();
	// rectangleCollisions(u,p);
	for (int i = 0; i < platforms.length; ++i) {
		rectangleCollisions(u,platforms[i]);
		u.checkPlatforms();
		// if (u.collisionSide != "none"){
		// 	break;
		// }
	}
	// u.checkPlatforms();
	u.checkBoundaries();
	if (space){
		if (firingTimer.isFinished()){
			bullets[nextBullet].fire(u.x, u.y, u.w, u.facingRight);
			nextBullet = (nextBullet+1)%bullets.length;
			firingTimer.start();
		}
	}
	u.display();
	// p.display();
	for (int i = 0; i < platforms.length; ++i) {
		platforms[i].display();
	}
	for (int i = 0; i < bullets.length; ++i) {
		bullets[i].update();
		bullets[i].display();
		
	}
	// displayPositionData();
}

// void displayPositionData(){
// 	float dx = (u.x+u.w/2) - (p.x+p.w/2);
// 	float dy = (u.y+u.h/2) - (p.y+p.h/2);

// 	float combinedHalfWidths = u.halfWidth + p.halfWidth;
// 	float combinedHalfHeights = u.halfHeight + p.halfHeight;
// 	String s = "dx:"+dx+"   dy:"+dy+"\n"+
// 				"chw:"+combinedHalfWidths+"   chh:"+combinedHalfHeights;
// 	text(s, 50,50);	
// }
void keyPressed(){
	switch (keyCode){
		case 37://left
			left = true;
			break;
		case 39://right
			right = true;
			break;
		case 38://up
			up = true;
			break;
		case 40://down
			down = true;
			break;
		case 32: //space
			space = true;
			break;
		case 16: //shift
			shift = true;
	}
}
void keyReleased(){
		switch (keyCode){
		case 37://left
			left = false;
			break;
		case 39://right
			right = false;
			break;
		case 38://up
			up = false;
			break;
		case 40://down
			down = false;
			break;
		case 32: //space
			space = false;
			break;
		case 16: //shift
			shift = false;
	}
}
void rectangleCollisions(Unicorn r1, Platform r2){
	////r1 is the player
	////r2 is the platform rectangle
	float dx = (r1.x+r1.w/2) - (r2.x+r2.w/2);
	float dy = (r1.y+r1.h/2) - (r2.y+r2.h/2);

	float combinedHalfWidths = r1.halfWidth + r2.halfWidth;
	float combinedHalfHeights = r1.halfHeight + r2.halfHeight;

	if (abs(dx) < combinedHalfWidths){
		////a collision may be happening
		////now check on the y axis
		if (abs(dy) < combinedHalfHeights){
			////excellent. they are overlapping
			//determine the overlap on each axis
			float overlapX = combinedHalfWidths - abs(dx);
			float overlapY = combinedHalfHeights - abs(dy);
			////the collision is on the axis with the 
			////SMALLEST about of overlap
			if (overlapX >= overlapY){
				if (dy > 0){
					r1.collisionSide = "top";
					////move the rectangle back to eliminate overlap
					////before calling its display to prevent
					////drawing object inside each other
					r1.y += overlapY;
					// println("collisionSide: "+r1.collisionSide);
				}else{
					r1.collisionSide = "bottom";
					r1.y -= overlapY;
					// println("collisionSide: "+r1.collisionSide);
				}
			}else{
				if (dx > 0){
					r1.collisionSide = "left";
					r1.x += overlapX;
					// println("collisionSide: "+r1.collisionSide);
				}else{
					r1.collisionSide = "right";
					r1.x -= overlapX;
					// println("collisionSide: "+r1.collisionSide);
				}
			}
		} else {
			r1.collisionSide = "none";
		}
	}else {
		r1.collisionSide = "none";
	}
	// return collisionSide;
}
class Unicorn {

	float w,h,x,y,vx,vy,
	accelerationX,accelerationY,
	speedLimit,friction,bounce,gravity;
	boolean isOnGround;
	float jumpForce;
	float halfWidth,halfHeight;
	int currentFrame;
	String collisionSide;
	boolean facingRight;
	int frameSequence;

	Unicorn(){
		w = 140;
		h = 95;
		x = 10;
		y = 150;
		vx = 0;
		vy = 0;
		accelerationX = 0;
		accelerationY = 0;
		speedLimit = 5;
		friction = 0.96;
		bounce = -0.7;
		gravity = 3;
		isOnGround = false;
		jumpForce = -10;

		halfWidth = w/2;
		halfHeight = h/2;

		currentFrame = 0;
		collisionSide = "";
		frameSequence = 6;
	}

	void update(){
		if (left){
			// vx =-5;
			accelerationX = -0.2;
			friction = 1;
			facingRight = false;
			// if(currentFrame <= startLeft){currentFrame=startLeft;}

		}
		if (right){
			// vx =5;
			accelerationX = 0.2;
			friction = 1;
			facingRight = true;
		}
		if(!left&&!right) {
			// vx=0;
			accelerationX = 0;
			friction = 0.96;
			gravity = 0.3;
		}else if (left&&right){
			// vx=0;
			accelerationX = 0;
			friction = 0.96;
			gravity = 0.3;
		}

		// if (up){
		// 	vy =-5;
		// }
		// if (down){
		// 	vy =5;
		// }
		// if(!up&&!down) {
		// 	vy=0;
		// }else if (up&&down){
		// 	vy=0;
		// }
		// if (!up&&!down&&!left&&!right){
		// 	// walking = false;
		// }

		if (up && isOnGround){
			vy += jumpForce;
			isOnGround = false;
			friction = 1;
		}

		vx += accelerationX;
		vy += accelerationY;

		////apply the forces of the universe
		if (isOnGround){
			vx *= friction;
		}
		vy += gravity;

		////correct for maximum speeds
		if (vx > speedLimit){
			vx = speedLimit;
		}
		if (vx < -speedLimit){
			vx = -speedLimit;
		}
		if (vy > speedLimit * 2){
			vy = speedLimit * 2;
		}

		////move the player
		x+=vx;
		y+=vy;

	}
	void checkPlatforms(){
		////update for platform collisions
		if (collisionSide == "bottom" && vy >= 0){
			isOnGround = true;
			////flip gravity to neutralize gravity's effect
			vy = -gravity;
		}else if (collisionSide == "top" && vy <= 0){
			vy = 0;
		}else if (collisionSide == "right" && vx >= 0){
			vx = 0;
		}else if (collisionSide == "left" && vx <= 0){
			vx = 0;
		}
		if (collisionSide != "bottom" && vy > 0){
			isOnGround = false;
		}
	}
	void checkBoundaries(){
		////check boundaries
		////left
		if (x < -w){
			// vx *= bounce;
			// x = 0;
			x = width;
		}
		if (x  > width){
		//// right
			// vx *= bounce;
			// x = width - w;
			x = -w;
		}
		////top
		if (y < 0){
			// vy *= bounce;
			// y = 0;
		}
		if (y + h > height){
			y = height - h;
			isOnGround = true;
			vy = -gravity;
		}		
	}
	void display(){
		fill(0,255,0,128);
		rect(x ,y ,w ,h);
		if (facingRight){
			image(spriteImages[currentFrame],x,y+3);
		}else{
			image(spriteImages[currentFrame+6],x,y+3);

		}
		// image(spriteImages[currentFrame],x,y+3);
		if (abs(vx)>1 && isOnGround){
			println("currentFrame: "+currentFrame);
				currentFrame = (currentFrame+1)%frameSequence;
		}else{
			currentFrame = 0;
		}

	}

}
class Bullet {
	float w,h,x,y;
	float halfWidth,halfHeight;
	float vx,vy;
	boolean firing;

	Bullet(){
		w = 35;
		h = 10;
		x = 0;
		y = -h;
		halfWidth = w/2;
		halfHeight = h/2;
		vx = 0;
		vy = 0;
		boolean firing = false;

	}
	void fire(float _x, float _y, float _w, boolean _facingRight){
		if (!firing){
			y = _y+24;
			firing = true;
			if (_facingRight == true){
				vx = 15;
				x = _x + _w - 35;
			}else{
				vx = -15;
				x = _x;
			}

		}
	}
	void reset(){
		x = 0;
		y = -h;
		vx = 0;
		vy = 0;
		firing = false;
	}
	void update(){
		if (firing){
			x += vx;
			y += vy;			
		}
		////check boundaries
		if (x < 0 || x > width || y < 0 || y > height){
			reset();
		}
	}
	void display(){
		// fill(255,0,0);
		// rect(x,y,w,h);
		image(laser,x,y);
	}
}

class Platform{
	float w,h,x,y;
	String typeof;
	float halfWidth, halfHeight;

	Platform(float _x, float _y, float _w, float _h, String _typeof){
		w = _w;
		h = _h;
		x = _x;
		y = _y;
		typeof = _typeof;

		halfWidth = w/2;
		halfHeight = h/2;
	}

	void display(){
		fill(0,0,255);
		rect(x,y,w,h);
	}
}

class Timer{
	int startTime;
	int interval;

	Timer(int tempTime){
		interval=tempTime;
	}

	void start(){
		startTime=millis();
	}

	boolean isFinished(){
		int elapsedTime = millis() - startTime;
		if(elapsedTime>interval){
			return true;
		}else{
			return false;
		}
	}
}
