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
	^ island bodies collect: [ :body | bodyStates at: body ]
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


{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> contactConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver contactConstraintCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> contactPointCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver contactPointCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> warmStartedContactPointCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver warmStartedContactPointCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> restitutionCandidatePointCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver restitutionCandidatePointCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> jointConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver jointConstraintCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> distanceJointConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver distanceJointConstraintCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> railJointConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver railJointConstraintCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> revoluteJointConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver revoluteJointConstraintCount ] ]
{ #category : 'accessing - telemetry' }
CFPhysicsIslandSolver >> fixedJointConstraintCount [ ^ softStepSolvers inject: 0 into: [ :total :solver | total + solver fixedJointConstraintCount ] ]
