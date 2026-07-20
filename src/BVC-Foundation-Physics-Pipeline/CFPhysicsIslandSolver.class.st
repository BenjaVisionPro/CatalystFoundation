Class {
	#name : 'CFPhysicsIslandSolver',
	#superclass : 'Object',
	#instVars : [ 'step', 'bodyStates', 'islands', 'softStepSolvers' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsIslandSolver class >> step: aStep bodyStates: aDictionary islands: aCollection [
	^ self new
		step: aStep;
		bodyStates: aDictionary;
		islands: aCollection;
		yourself
]

{ #category : 'initialization' }
CFPhysicsIslandSolver >> initialize [
	super initialize.
	softStepSolvers := #()
]

{ #category : 'solving' }
CFPhysicsIslandSolver >> solveWithRestitutionThreshold: restitutionThreshold [
	softStepSolvers := (islands select: [ :island |
		island dynamicBodies anySatisfy: [ :body | body isAwake ] ]) collect: [ :island |
		| solver |
		solver := CFPhysicsSoftStepSolver
			step: step
			bodyStates: (self bodyStatesFor: island)
			constraints: island constraints.
		solver solveWithRestitutionThreshold: restitutionThreshold.
		solver ]
]

{ #category : 'private - solving' }
CFPhysicsIslandSolver >> bodyStatesFor: island [
	| result |
	result := IdentityDictionary new.
	island bodies do: [ :body | result at: body put: (bodyStates at: body) ].
	^ result
]

{ #category : 'accessing' }
CFPhysicsIslandSolver >> step: anObject [ step := anObject ]
{ #category : 'accessing' }
CFPhysicsIslandSolver >> bodyStates: aDictionary [ bodyStates := aDictionary ]
{ #category : 'accessing' }
CFPhysicsIslandSolver >> islands: aCollection [ islands := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsIslandSolver >> islands [ ^ islands ]
{ #category : 'accessing' }
CFPhysicsIslandSolver >> softStepSolvers [ ^ softStepSolvers ]
