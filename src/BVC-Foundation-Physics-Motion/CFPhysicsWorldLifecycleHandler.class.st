Class {
	#name : 'CFPhysicsWorldLifecycleHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [ 'world' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
}

{ #category : 'instance creation' }
CFPhysicsWorldLifecycleHandler class >> on: aWorld [
	^ self new
		world: aWorld;
		yourself
]

{ #category : 'events' }
CFPhysicsWorldLifecycleHandler >> elementAddedToSceneGraphEvent: anEvent [
	world startStepping
]

{ #category : 'events' }
CFPhysicsWorldLifecycleHandler >> elementRemovedFromSceneGraphEvent: anEvent [
	world stopStepping
]

{ #category : 'events' }
CFPhysicsWorldLifecycleHandler >> eventsToHandle [
	^ {
		BlElementAddedToSceneGraphEvent.
		BlElementRemovedFromSceneGraphEvent }
]

{ #category : 'accessing' }
CFPhysicsWorldLifecycleHandler >> world: aWorld [
	world := aWorld
]
