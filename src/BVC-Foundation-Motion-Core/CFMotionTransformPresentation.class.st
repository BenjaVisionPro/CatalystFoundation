Class {
	#name : 'CFMotionTransformPresentation',
	#superclass : 'Object',
	#instVars : [ 'element', 'baseTransformation', 'appliedTransformation', 'translation', 'active' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTransformPresentation class >> on: anElement [
	^ self new element: anElement; yourself
]

{ #category : 'initialization' }
CFMotionTransformPresentation >> initialize [
	super initialize.
	translation := 0 @ 0.
	active := false
]

{ #category : 'controlling' }
CFMotionTransformPresentation >> begin [
	active ifTrue: [
		self ownsCurrentTransformation ifTrue: [ ^ self ].
		self relinquishOwnership ].
	baseTransformation := element transformation.
	translation := 0 @ 0.
	active := true.
	self apply
]

{ #category : 'private - applying' }
CFMotionTransformPresentation >> apply [
	| composite |
	composite := BlElementCompositeTransformation new.
	composite add: baseTransformation asElementTransformation.
	translation isZero ifFalse: [
		composite add: (BlElementLocalTransformation with:
			(BlTranslationTransformation translation: translation)) ].
	appliedTransformation := composite asCachedTransformation.
	element transformation: appliedTransformation
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> baseTransformation [ ^ baseTransformation ]

{ #category : 'accessing' }
CFMotionTransformPresentation >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionTransformPresentation >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionTransformPresentation >> isActive [ ^ active ]

{ #category : 'testing' }
CFMotionTransformPresentation >> ownsCurrentTransformation [
	^ active and: [ element transformation == appliedTransformation ]
]

{ #category : 'controlling' }
CFMotionTransformPresentation >> release [
	active ifFalse: [ ^ self ].
	self ownsCurrentTransformation ifTrue: [
		element transformation: baseTransformation ].
	self relinquishOwnership
]

{ #category : 'private - controlling' }
CFMotionTransformPresentation >> relinquishOwnership [
	active := false.
	appliedTransformation := nil
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> translation [ ^ translation ]

{ #category : 'controlling' }
CFMotionTransformPresentation >> translation: aPoint [
	active ifFalse: [ self begin ].
	self ownsCurrentTransformation ifFalse: [
		self relinquishOwnership.
		^ self ].
	translation := aPoint.
	self apply
]
