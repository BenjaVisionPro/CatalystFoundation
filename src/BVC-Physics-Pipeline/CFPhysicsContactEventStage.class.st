Class {
	#name : 'CFPhysicsContactEventStage',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsContactEventStage >> eventsFrom: aContactResult [
	| began ended |
	began := aContactResult beganContacts collect: [ :contact |
		CFPhysicsContactBeganEvent contact: contact ].
	ended := aContactResult endedContacts collect: [ :contact |
		CFPhysicsContactEndedEvent contact: contact ].
	^ (began, ended) sorted: [ :left :right |
		left comesBefore: right ]
]
