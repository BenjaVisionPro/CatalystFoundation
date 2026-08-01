"
I build contact lifecycle events from a contact update batch. I distinguish contacts that began from contacts that ended during the step.
"

Class {
	#name : 'CFPhysicsContactEventBuilder',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'building' }
CFPhysicsContactEventBuilder >> eventsFrom: aContactResult [
	| began ended |
	began := aContactResult beganContacts collect: [ :contact |
		CFPhysicsContactBeganEvent contact: contact ].
	ended := aContactResult endedContacts collect: [ :contact |
		CFPhysicsContactEndedEvent contact: contact ].
	^ (began, ended) sorted: [ :left :right |
		left comesBefore: right ]
]
