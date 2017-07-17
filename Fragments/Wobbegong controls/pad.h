//////////// pad.h

#pragma once


#define PAD_FOLLOW_EASING 0.2
#define KEYPAD_SENSITIVITY 25.0
#define PAD_DEADZONE 8.0 // only used for pad.moved

class Pad
{

public:

	Pad();
	~Pad();

	void Reset();
	void ResetKey( int key );

	void Update();
	
	unsigned int input;
	float radius;
	
	bool pressed, tapped, released, moved;
	float cX, cY, sX, sY, rX, rY;
	float angle;

//	int type; // 0 = touchscreen/mouse, 1 = keyboard
//
//	vec2 keyDest;

};


////////////////////// pad.cpp

#include "pad.h"
#include "tools.h"
#include "input.h"
#include "megainclude.h"


Pad::Pad()
{
	input = 0;
	
	radius = 32.0f;
	
	pressed = false;
    tapped = false;
	released = false;
	moved = false;
	
//	type = 0;
//	keyDest.x = 0.0f;
//	keyDest.y = 0.0f;
	
}

Pad::~Pad()
{

}

void Pad::Reset()
{
//	if ( type == 0 )
	{
		cX = Input::input[input].mouseStartX;
		cY = Input::input[input].mouseStartY;
	}
//	else
//	{
//		cX = 0.0f;
//		cY = 0.0f;
//		keyDest.x = 0.0f;
//		keyDest.y = 0.0f;
//		
//	}
	
	sX = cX;
	sY = cY;
	rX = 0.0f;
	rY = 0.0f;
	angle = 0.0;
}

void Pad::ResetKey( int key )
{

}

void Pad::Update()
{
    tapped = false;
	released = false;
	moved = false;

//	if ( type == 0 ) // touchscreen / mouse
	{
		if ( Input::input[input].mouseHit[0] )
		{
			Reset();
			tapped = true;
		}
		else if ( Input::input[input].mouseHit[1] )
		{
			released = true;
		}
		

		if ( !released )
		{
			pressed = Input::input[input].mouseDown[0];

			if ( pressed )
			{
				if ( Distance( sX, sY, Input::input[input].mouseX, Input::input[input].mouseY ) > PAD_DEADZONE )
				{
					moved = true;
				}
			
				sX = Input::input[input].mouseX;
				sY = Input::input[input].mouseY;
				
				if ( Distance( sX, sY, cX, cY ) > radius )
				{
					cX += ( sX - cX ) * PAD_FOLLOW_EASING;
					cY += ( sY - cY ) * PAD_FOLLOW_EASING;
				}

				rX = sX - cX;
				rY = sY - cY;

				angle = atan2( cX - sX, cY - sY );

			}
		}
	}
//	else // keyboard pad
//	{
//	}
}