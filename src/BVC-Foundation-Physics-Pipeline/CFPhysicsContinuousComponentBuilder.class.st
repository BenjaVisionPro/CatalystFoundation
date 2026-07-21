Class {
	#name : 'CFPhysicsContinuousComponentBuilder',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsContinuousComponentBuilder >> bodiesForImpact: anImpact joints: joints [
	| bodies changed |
	bodies := IdentitySet new.
	bodies add: anImpact pair firstBody.
	bodies add: anImpact pair secondBody.
	[
		changed := false.
		joints do: [ :joint |
			| firstBody secondBody |
			firstBody := joint firstBody.
			secondBody := joint secondBody.
			((firstBody notNil and: [ bodies includes: firstBody ])
				or: [ secondBody notNil and: [ bodies includes: secondBody ] ]) ifTrue: [
				firstBody ifNotNil: [
					(bodies includes: firstBody) ifFalse: [
						bodies add: firstBody.
						changed := true ] ].
				secondBody ifNotNil: [
					(bodies includes: secondBody) ifFalse: [
						bodies add: secondBody.
						changed := true ] ] ] ].
		changed
	] whileTrue.
	^ bodies asArray sorted: [ :first :second |
		first sequence < second sequence ]
]

{ #category : 'building' }
CFPhysicsContinuousComponentBuilder >> bodyStatesForImpact: anImpact from: bodyStates joints: joints [
	| result |
	result := IdentityDictionary new.
	(self bodiesForImpact: anImpact joints: joints) do: [ :body |
		result at: body put: (bodyStates at: body) ].
	^ result
]

{ #category : 'building' }
CFPhysicsContinuousComponentBuilder >> jointsForBodies: bodies from: joints [
	^ joints select: [ :joint |
		| firstBody secondBody |
		firstBody := joint firstBody.
		secondBody := joint secondBody.
		(firstBody isNil or: [ bodies includes: firstBody ])
			and: [ secondBody isNil or: [ bodies includes: secondBody ] ] ]
]
