Class {
	#name : 'CFMotionOverlay',
	#superclass : 'Object',
	#instVars : [ 'container', 'referenceElement', 'overlay' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionOverlay class >> on: anElement in: aContainer [
	^ self new
		container: aContainer;
		referenceElement: anElement;
		install;
		yourself
]

{ #category : 'accessing' }
CFMotionOverlay >> container [ ^ container ]

{ #category : 'accessing' }
CFMotionOverlay >> container: anElement [ container := anElement ]

{ #category : 'testing' }
CFMotionOverlay >> isInstalled [ ^ overlay notNil and: [ overlay hasParent ] ]

{ #category : 'controlling' }
CFMotionOverlay >> install [
	self isInstalled ifTrue: [ ^ self ].
	overlay ifNotNil: [ self release ].
	self validateBeforeInstalling.
	overlay := BlOverlayElement on: referenceElement.
	container addChild: overlay.
	^ self
]

{ #category : 'accessing' }
CFMotionOverlay >> overlay [ ^ overlay ]

{ #category : 'accessing' }
CFMotionOverlay >> referenceElement [ ^ referenceElement ]

{ #category : 'accessing' }
CFMotionOverlay >> referenceElement: anElement [ referenceElement := anElement ]

{ #category : 'controlling' }
CFMotionOverlay >> release [
	overlay ifNil: [ ^ self ].
	overlay detach.
	overlay hasParent ifTrue: [ overlay parent removeChild: overlay ].
	^ self
]

{ #category : 'private - validation' }
CFMotionOverlay >> validateBeforeInstalling [
	container isAttachedToSceneGraph ifFalse: [
		self error: 'A Motion overlay container must be attached to a BlSpace' ].
	referenceElement isAttachedToSceneGraph ifFalse: [
		self error: 'A Motion overlay reference must be attached to a BlSpace' ].
	container space == referenceElement space ifFalse: [
		self error: 'A Motion overlay container and reference must share a BlSpace' ]
]
