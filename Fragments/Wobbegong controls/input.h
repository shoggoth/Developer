//////////////// input.h

#pragma once

#define MOUSE_SENSITIVITY 0.4
#define MOUSE_DEADZONE 0.01

#define MAX_TOUCHES 2

enum inputKeys { KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J, KEY_K,
				KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z, KEY_0, KEY_1,
				KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_SPACE, KEY_ENTER, KEY_ESC, NUM_INPUTKEYS };


struct TInput
{
	float prevMouseX, prevMouseY;
	float mouseX, mouseY;
	bool mouseDown[ 2 ], mouseHit[ 2 ], mouseRelease[ 2 ], mouseLock[ 2 ];
	float mouseStartX, mouseStartY;

	bool usesKeys; // (if false, this input is only used for multitouch, so don't bother with all the keys stuff)
	bool keyDown[ NUM_INPUTKEYS ], keyHit[ NUM_INPUTKEYS ], keyReleased[ NUM_INPUTKEYS ], keyLock[ NUM_INPUTKEYS ];
	
	
};

namespace Input
{
	extern TInput input[ MAX_TOUCHES ];

	void ResetInput();
	void UpdateInput();
	
};


/////////////////// input.cpp

#include "input.h"
#include "app.h"

namespace Input
{
	TInput input[ MAX_TOUCHES ];
	
	void ResetInput()
	{
		for (int i = 0; i < MAX_TOUCHES; i++)
		{
			input[i].mouseX = App::halfW; // App::gameW / 2.0;
			input[i].mouseY = App::halfH; //App::gameH / 2.0;
			input[i].prevMouseX = input[i].mouseX;
			input[i].prevMouseY = input[i].mouseY;
			input[i].mouseStartX = input[i].mouseX;
			input[i].mouseStartY = input[i].mouseY;
			input[i].mouseDown[0] = false; input[i].mouseDown[1] = true;
			input[i].mouseHit[0] = false; input[i].mouseHit[1] = false;
			
			for (int k = 0; k < NUM_INPUTKEYS; k++)
			{
				input[i].keyDown[k] = false;
				input[i].keyHit[k] = false;
				input[i].keyReleased[k] = false;
				input[i].keyLock[k] = false;
			}
			
			if (i == 0) { input[i].usesKeys = true; }
			else { input[i].usesKeys = false; }
		}

	}
	
	void UpdateInput()
	{
		for (int i2 = 0; i2 < MAX_TOUCHES; i2++)
		{
			for (int i = 0; i < 2; i++)
			{
				input[ i2 ].mouseHit[ i ] = false;
				if (input[ i2 ].mouseDown[ i ]) { if (!input[ i2 ].mouseRelease[ i ]) { input[ i2 ].mouseHit[ i ] = true; input[ i2 ].mouseRelease[ i ] = true; } }
				else { input[ i2 ].mouseRelease[ i ] = false; }
			}

			if ( input[ i2 ].mouseHit[ 0 ] ) //|| input[ i2 ].mouseHit[ 1 ] ) // sync mouseStart position and current mouse position each time you touch or stop touching
			{
				input[ i2 ].mouseStartX = input[ i2 ].mouseX;
				input[ i2 ].mouseStartY = input[ i2 ].mouseY;
			}

			input[ i2 ].prevMouseX = input[ i2 ].mouseX;
			input[ i2 ].prevMouseY = input[ i2 ].mouseY;
			
			if ( input[ i2 ].usesKeys )
			{
				for (int i = 0; i < NUM_INPUTKEYS; i++)
				{
					input[ i2 ].keyHit[ i ] = false; 
					input[ i2 ].keyReleased[ i ] = false;
					if ( input[ i2 ].keyDown[ i ] ) { if (!input[ i2 ].keyLock[ i ]) { input[ i2 ].keyHit[ i ] = true; input[ i2 ].keyLock[ i ] = true; } }
					else { if ( input[ i2 ].keyLock[ i ] ) { input[ i2 ].keyReleased[ i ] = true; } input[ i2 ].keyLock[ i ] = false; }
				}
			}


		}
	
	}


};