Class {
	#name : 'CFPhysicsPresentation',
	#superclass : 'Object',
	#instVars : [ 'presentation' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

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
	presentation ifNotNil: [
		presentation translation: aPoint rotation: aNumber ]
]

{ #category : 'controlling' }
CFPhysicsPresentation >> release [
	presentation ifNotNil: [ :aPresentation |
		aPresentation release ].
	presentation := nil
]

{ #category : 'controlling' }
CFPhysicsPresentation >> use: aPresentation [
	presentation == aPresentation ifTrue: [ ^ self ].
	self release.
	presentation := aPresentation
]
