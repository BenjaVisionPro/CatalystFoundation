Class {
	#name : 'CFPhysicsWorldTestCase',
	#superclass : 'CFPhysicsContactTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'private - world fixtures' }
CFPhysicsWorldTestCase >> newWorldAfterOneStep [
	| owner ground box world groundBody boxBody |
	owner := BlElement new.
	ground := BlElement new size: 100 @ 20; yourself.
	box := BlElement new size: 60 @ 20; yourself.
	owner addChild: ground.
	owner addChild: box.
	world := owner physics beWorld.
	world containment disable.
	world
		gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	groundBody := world bodyStateFor: ground.
	boxBody := world bodyStateFor: box.
	groundBody
		position: 0 @ 0;
		beStatic.
	boxBody position: 20 @ 15.
	world step.
	^ world
]
