"
I am the compatibility name for CFMotionValueInterpolation.

Use CFMotionValueInterpolation and CFMotionValue's interpolate... protocol for new code. I remain so existing clients can continue to construct their value tweens without changing behaviour.
"
Class {
	#name : 'CFMotionValueTransition',
	#superclass : 'CFMotionValueInterpolation',
	#category : 'BVC-Motion-Core-Values',
	#package : 'BVC-Motion-Core'
}
