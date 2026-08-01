"
I represent bodies advanced to a continuous-collision impact. I retain the impact together with the elapsed and remaining substep time.
"

Class {
	#name : 'CFPhysicsImpactAdvancementResult',
	#superclass : 'Object',
	#instVars : [ 'impact', 'elapsedTime', 'remainingTime' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsImpactAdvancementResult class >> impact: aPairTimeOfImpact elapsedTime: elapsedSeconds remainingTime: remainingSeconds [
	^ self new
		impact: aPairTimeOfImpact;
		elapsedTime: elapsedSeconds;
		remainingTime: remainingSeconds;
		yourself
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> impact [
	^ impact
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> impact: aPairTimeOfImpact [
	impact := aPairTimeOfImpact
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> elapsedTime [
	^ elapsedTime
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> elapsedTime: seconds [
	elapsedTime := seconds
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> remainingTime [
	^ remainingTime
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> remainingTime: seconds [
	remainingTime := seconds
]

{ #category : 'accessing' }
CFPhysicsImpactAdvancementResult >> fraction [
	^ impact fraction
]
