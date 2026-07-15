Class {
	#name : 'CFMotionNextLayoutReadiness',
	#superclass : 'Object',
	#instVars : [ 'container', 'completion', 'handler', 'state' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionNextLayoutReadiness class >> on: anElement then: aBlock [
	^ self new
		container: anElement;
		completion: aBlock;
		yourself
]

{ #category : 'controlling' }
CFMotionNextLayoutReadiness >> cancel [
	state = #waiting ifFalse: [ ^ self ].
	container removeEventHandler: handler.
	handler := nil.
	state := #cancelled.
	^ self
]

{ #category : 'accessing' }
CFMotionNextLayoutReadiness >> completion: aBlock [ completion := aBlock ]

{ #category : 'private - completing' }
CFMotionNextLayoutReadiness >> complete [
	state = #waiting ifFalse: [ ^ self ].
	container removeEventHandler: handler.
	handler := nil.
	state := #completed.
	completion value
]

{ #category : 'accessing' }
CFMotionNextLayoutReadiness >> container: anElement [ container := anElement ]

{ #category : 'initialization' }
CFMotionNextLayoutReadiness >> initialize [
	super initialize.
	state := #idle
]

{ #category : 'testing' }
CFMotionNextLayoutReadiness >> isCancelled [ ^ state = #cancelled ]

{ #category : 'testing' }
CFMotionNextLayoutReadiness >> isCompleted [ ^ state = #completed ]

{ #category : 'testing' }
CFMotionNextLayoutReadiness >> isWaiting [ ^ state = #waiting ]

{ #category : 'accessing' }
CFMotionNextLayoutReadiness >> state [ ^ state ]

{ #category : 'controlling' }
CFMotionNextLayoutReadiness >> start [
	state = #idle ifFalse: [ self error: 'A Motion readiness can only start once' ].
	handler := BlEventHandler
		on: BlElementLayoutComputedEvent
		do: [ :anEvent | self complete ].
	container addEventHandler: handler.
	state := #waiting.
	^ self
]
