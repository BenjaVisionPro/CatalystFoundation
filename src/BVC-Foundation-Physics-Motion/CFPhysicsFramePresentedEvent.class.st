Class {
	#name : 'CFPhysicsFramePresentedEvent',
	#superclass : 'BlEvent',
	#instVars : [ 'alpha' ],
	#category : 'BVC-Foundation-Physics-Motion',
	#package : 'BVC-Foundation-Physics-Motion'
}

CFPhysicsFramePresentedEvent comment: 'I announce that a Physics world presentation successfully committed one interpolated frame to its Motion transform channels. I am fired once after all body presentations have been updated. I am not a simulation-step, solver or raw-world-state event.'

{ #category : 'accessing' }
CFPhysicsFramePresentedEvent >> alpha [
	^ alpha
]

{ #category : 'accessing' }
CFPhysicsFramePresentedEvent >> alpha: aNumber [
	alpha := aNumber
]
