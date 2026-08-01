"
I decide which islands may sleep and propagate wake state across their connections. I own the shared sleeping configuration used by wake and sleep stages.
"

Class {
	#name : 'CFPhysicsIslandSleepStage',
	#superclass : 'Object',
	#instVars : [ 'configuration', 'wokenBodiesByIsland' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'initialization' }
CFPhysicsIslandSleepStage >> initialize [
	super initialize.
	configuration := CFPhysicsSleepConfiguration standard.
	wokenBodiesByIsland := IdentityDictionary new
]

{ #category : 'accessing' }
CFPhysicsIslandSleepStage >> configuration [ ^ configuration ]

{ #category : 'accessing' }
CFPhysicsIslandSleepStage >> configuration: aConfiguration [ configuration := aConfiguration ]

{ #category : 'waking' }
CFPhysicsIslandSleepStage >> propagateWakeAcross: islands [
	wokenBodiesByIsland removeAll.
	islands do: [ :island |
		| dynamicBodies |
		dynamicBodies := island dynamicBodies.
		wokenBodiesByIsland
			at: island
			put: ((dynamicBodies anySatisfy: [ :body | body isAwake ])
				ifTrue: [ self wakeSleepingBodiesIn: dynamicBodies ]
				ifFalse: [ #() ]) ]
]

{ #category : 'private - waking' }
CFPhysicsIslandSleepStage >> wakeSleepingBodiesIn: dynamicBodies [
	| sleepingCount woken index |
	sleepingCount := dynamicBodies count: #isSleeping.
	sleepingCount = 0 ifTrue: [ ^ #() ].
	woken := Array new: sleepingCount.
	index := 1.
	dynamicBodies do: [ :body |
		body isSleeping ifTrue: [
			body wake.
			woken at: index put: body.
			index := index + 1 ] ].
	^ woken
]

{ #category : 'sleeping' }
CFPhysicsIslandSleepStage >> updateIslands: islands bodyStates: bodyStates elapsed: seconds [
	^ islands collect: [ :island |
		self updateIsland: island bodyStates: bodyStates elapsed: seconds ]
]

{ #category : 'private - sleeping' }
CFPhysicsIslandSleepStage >> updateIsland: island bodyStates: bodyStates elapsed: seconds [
	| dynamicBodies decision eligible minimum slept |
	dynamicBodies := island dynamicBodies.
	decision := CFPhysicsIslandSleepDecision new
		island: island;
		wokeBodies: (wokenBodiesByIsland at: island ifAbsent: [ #() ]);
		yourself.
	dynamicBodies isEmpty ifTrue: [ ^ decision ].

	(dynamicBodies allSatisfy: [ :body | (bodyStates at: body) isAwake not ]) ifTrue: [
		^ decision
			eligible: true;
			minimumSleepTime: configuration timeToSleep;
			yourself ].

	eligible := dynamicBodies allSatisfy: [ :body |
		| state |
		state := bodyStates at: body.
		state allowsSleeping and: [
			configuration acceptsStepState: state elapsed: seconds ] ].

	eligible
		ifTrue: [
			minimum := Float infinity.
			dynamicBodies do: [ :body |
				| state |
				state := bodyStates at: body.
				state advanceSleepTimeBy: seconds.
				minimum := minimum min: state sleepTime ].
			slept := minimum >= configuration timeToSleep.
			slept ifTrue: [
				dynamicBodies do: [ :body |
					| state |
					state := bodyStates at: body.
					state sleep ] ] ]
		ifFalse: [
			dynamicBodies do: [ :body |
				| state |
				state := bodyStates at: body.
				state resetSleepTime.
				state wake ].
			minimum := 0.0.
			slept := false ].

	^ decision
		eligible: eligible;
		minimumSleepTime: minimum;
		slept: slept;
		yourself
]

{ #category : 'waking' }
CFPhysicsIslandSleepStage >> propagateWakeAcross: islands bodyStates: bodyStates [
	wokenBodiesByIsland removeAll.
	islands do: [ :island |
		| dynamicBodies |
		dynamicBodies := island dynamicBodies.
		wokenBodiesByIsland
			at: island
			put: ((dynamicBodies anySatisfy: [ :body | (bodyStates at: body) isAwake ])
				ifTrue: [ self wakeSleepingBodiesIn: dynamicBodies bodyStates: bodyStates ]
				ifFalse: [ #() ]) ]
]

{ #category : 'private - waking' }
CFPhysicsIslandSleepStage >> wakeSleepingBodiesIn: dynamicBodies bodyStates: bodyStates [
	| sleepingCount woken index |
	sleepingCount := dynamicBodies count: [ :body | (bodyStates at: body) isAwake not ].
	sleepingCount = 0 ifTrue: [ ^ #() ].
	woken := Array new: sleepingCount.
	index := 1.
	dynamicBodies do: [ :body |
		| state |
		state := bodyStates at: body.
		state isAwake ifFalse: [
			state wake.
			woken at: index put: body.
			index := index + 1 ] ].
	^ woken
]

