Class {
	#name : 'CFPhysicsContinuousStepResult',
	#superclass : 'Object',
	#instVars : [ 'impact', 'impactSolveResult', 'bodyStates' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContinuousStepResult class >> impact: anImpact impactSolveResult: aSolveResult bodyStates: aDictionary [
	^ self new
		impact: anImpact;
		impactSolveResult: aSolveResult;
		bodyStates: aDictionary;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impact [ ^ impact ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impact: anObject [ impact := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impactSolveResult [ ^ impactSolveResult ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> impactSolveResult: anObject [ impactSolveResult := anObject ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> bodyStates [ ^ bodyStates ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> bodyStates: aDictionary [ bodyStates := aDictionary ]

{ #category : 'testing' }
CFPhysicsContinuousStepResult >> hasImpact [ ^ impact notNil ]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> fraction [
	^ impact ifNil: [ 1.0 ] ifNotNil: [ impact fraction ]
]

{ #category : 'accessing' }
CFPhysicsContinuousStepResult >> remainingTime [
	^ impactSolveResult
		ifNil: [ 0.0 ]
		ifNotNil: [ impactSolveResult remainingTime ]
]
