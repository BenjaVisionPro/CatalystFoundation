Class {
	#name : 'CFPhysicsPresentation',
	#superclass : 'Object',
	#instVars : [ 'element', 'presentation', 'space' ],
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
	^ presentation notNil
]

{ #category : 'testing' }
CFPhysicsPresentation >> ownsCurrentTransformation [
	^ presentation notNil
		and: [ presentation ownsCurrentTransformation ]
]

{ #category : 'accessing' }
CFPhysicsPresentation >> presentation [
	^ presentation
]

{ #category : 'presenting' }
CFPhysicsPresentation >> presentTranslation: aPoint rotation: aNumber [
	self synchroniseSpace.
	presentation ifNotNil: [
		presentation translation: aPoint rotation: aNumber ]
]

{ #category : 'controlling' }
CFPhysicsPresentation >> release [
	presentation ifNotNil: [ :aPresentation |
		aPresentation release ].
	presentation := nil.
	space := nil
]

{ #category : 'private - space' }
CFPhysicsPresentation >> synchroniseSpace [
	| currentSpace |
	currentSpace := element isAttachedToSceneGraph
		ifTrue: [ element space ]
		ifFalse: [ nil ].
	currentSpace == space ifTrue: [ ^ self ].
	self release.
	currentSpace ifNil: [ ^ self ].
	space := currentSpace.
	presentation := CFMotionTransformPresentation
		on: element
		using: (space cfMotionCoordinator transformChannelFor: element)
]
