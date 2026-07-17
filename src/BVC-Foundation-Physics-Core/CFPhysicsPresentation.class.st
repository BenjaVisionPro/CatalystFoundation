Class {
	#name : 'CFPhysicsPresentation',
	#superclass : 'Object',
	#instVars : [ 'element', 'motionPresentation', 'space' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsPresentation class >> on: anElement [
	^ self new
		element: anElement;
		yourself
]

{ #category : 'accessing' }
CFPhysicsPresentation >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsPresentation >> element: anElement [
	element := anElement
]

{ #category : 'testing' }
CFPhysicsPresentation >> isAttached [
	^ motionPresentation notNil
]

{ #category : 'testing' }
CFPhysicsPresentation >> ownsCurrentTransformation [
	^ motionPresentation notNil
		and: [ motionPresentation ownsCurrentTransformation ]
]

{ #category : 'accessing' }
CFPhysicsPresentation >> motionPresentation [
	^ motionPresentation
]

{ #category : 'presenting' }
CFPhysicsPresentation >> presentTranslation: aPoint rotation: aNumber [
	self synchroniseAttachment.
	motionPresentation ifNotNil: [
		motionPresentation translation: aPoint rotation: aNumber ]
]

{ #category : 'controlling' }
CFPhysicsPresentation >> release [
	motionPresentation ifNotNil: [ :aPresentation |
		aPresentation release ].
	motionPresentation := nil.
	space := nil
]

{ #category : 'private - attachment' }
CFPhysicsPresentation >> synchroniseAttachment [
	| currentSpace |
	currentSpace := element isAttachedToSceneGraph
		ifTrue: [ element space ]
		ifFalse: [ nil ].
	currentSpace == space ifTrue: [ ^ self ].
	self release.
	currentSpace ifNil: [ ^ self ].
	space := currentSpace.
	motionPresentation := CFMotionTransformPresentation
		on: element
		using: (space cfMotionCoordinator transformChannelFor: element)
]
