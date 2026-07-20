Class {
	#name : 'CFPhysicsIslandSleepStage',
	#superclass : 'Object',
	#instVars : [ 'configuration', 'wokenBodiesByIsland' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
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
	wokenBodiesByIsland := IdentityDictionary new.
	islands do: [ :island |
		| dynamicBodies woken |
		dynamicBodies := island dynamicBodies.
		woken := OrderedCollection new.
		(dynamicBodies anySatisfy: [ :body | body isAwake ]) ifTrue: [
			dynamicBodies do: [ :body |
				body isSleeping ifTrue: [
					body wake.
					woken add: body ] ] ].
		wokenBodiesByIsland at: island put: woken asArray ]
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

	(dynamicBodies allSatisfy: [ :body | body isSleeping ]) ifTrue: [
		^ decision
			eligible: true;
			minimumSleepTime: configuration timeToSleep;
			yourself ].

	eligible := dynamicBodies allSatisfy: [ :body |
		| state |
		body allowsSleeping and: [
			state := bodyStates at: body.
			configuration
				acceptsLinearVelocity: state linearVelocity
				angularVelocity: state angularVelocity ] ].

	eligible
		ifTrue: [
			dynamicBodies do: [ :body | body advanceSleepTimeBy: seconds ].
			minimum := (dynamicBodies collect: #sleepTime) min.
			slept := minimum >= configuration timeToSleep.
			slept ifTrue: [
			dynamicBodies do: [ :body |
				| state |
				state := bodyStates at: body.
				state linearVelocity: 0 @ 0.
				state angularVelocity: 0.0.
				body sleep ] ] ]
		ifFalse: [
			dynamicBodies do: [ :body |
				body resetSleepTime.
				body wake ].
			minimum := 0.0.
			slept := false ].

	^ decision
		eligible: eligible;
		minimumSleepTime: minimum;
		slept: slept;
		yourself
]
