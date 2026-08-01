"
I represent the accumulated result of a continuous-impact loop. I report impacts, solve results, sensor contacts, completed bodies and remaining time.
"

Class {
	#name : 'CFPhysicsContinuousStepResult',
	#superclass : 'Object',
	#instVars : [ 'impacts', 'impactSolveResults', 'sensorContacts', 'bodyStates', 'remainingTime', 'iterationLimitReached', 'completedBodies' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContinuousStepResult class >> impacts: impacts impactSolveResults: solveResults sensorContacts: contacts bodyStates: aDictionary remainingTime: seconds iterationLimitReached: aBoolean completedBodies: bodies [
	^ self new
		impacts: impacts;
		impactSolveResults: solveResults;
		sensorContacts: contacts;
		bodyStates: aDictionary;
		remainingTime: seconds;
		iterationLimitReached: aBoolean;
		completedBodies: bodies;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impacts [ ^ impacts ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impacts: aCollection [ impacts := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impactSolveResults [ ^ impactSolveResults ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impactSolveResults: aCollection [ impactSolveResults := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> sensorContacts [ ^ sensorContacts ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> sensorContacts: aCollection [ sensorContacts := aCollection asArray ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> bodyStates [ ^ bodyStates ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> bodyStates: aDictionary [ bodyStates := aDictionary ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> remainingTime [ ^ remainingTime ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> remainingTime: seconds [ remainingTime := seconds ]

{ #category : 'testing' }
CFPhysicsContinuousStepResult >> iterationLimitReached [ ^ iterationLimitReached ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> iterationLimitReached: aBoolean [ iterationLimitReached := aBoolean ]

{ #category : 'testing' }
CFPhysicsContinuousStepResult >> hasImpacts [ ^ impacts notEmpty ]

{ #category : 'testing' }
CFPhysicsContinuousStepResult >> hasImpact [
	^ self hasImpacts
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impact [
	^ impacts
		ifEmpty: [ nil ]
		ifNotEmpty: [ impacts last ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impactSolveResult [
	^ impactSolveResults
		ifEmpty: [ nil ]
		ifNotEmpty: [ impactSolveResults last ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> fraction [
	^ impacts
		ifEmpty: [ nil ]
		ifNotEmpty: [ impacts first fraction ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> completedBodies [ ^ completedBodies ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> completedBodies: aCollection [ completedBodies := aCollection asArray ]
