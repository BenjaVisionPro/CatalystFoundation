Class {
	#name : 'CFMotionTransformPresentation',
	#superclass : 'Object',
	#instVars : [ 'element', 'channel', 'translation', 'scale', 'rotation', 'active' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTransformPresentation class >> on: anElement [
	^ self new element: anElement; yourself
]

{ #category : 'instance creation' }
CFMotionTransformPresentation class >> on: anElement using: aTransformChannel [
	^ self new
		element: anElement;
		channel: aTransformChannel;
		yourself
]

{ #category : 'initialization' }
CFMotionTransformPresentation >> initialize [
	super initialize.
	translation := 0 @ 0.
	scale := 1 @ 1.
	rotation := 0.
	active := false
]

{ #category : 'private - applying' }
CFMotionTransformPresentation >> addContributionTo: aCompositeTransformation [
	| motionTransformation origin |
	motionTransformation := BlAffineCompositeTransformation new.
	origin := BlAffineTransformationCenterOrigin new.
	scale = (1 @ 1) ifFalse: [
		motionTransformation addTransformation:
			((BlScalingTransformation scale: scale) origin: origin) ].
	rotation isZero ifFalse: [
		motionTransformation addTransformation:
			(BlRotationTransformation new
				angle: rotation;
				axis: BlVector zAxis;
				origin: origin) ].
	translation isZero ifFalse: [
		motionTransformation addTransformation:
			((BlTranslationTransformation translation: translation) origin: origin) ].
	motionTransformation hasTransformations ifTrue: [
		aCompositeTransformation add: (BlElementLocalTransformation with: motionTransformation) ]
]

{ #category : 'private - applying' }
CFMotionTransformPresentation >> apply [
	(channel apply) ifFalse: [ self relinquishOwnership ]
]

{ #category : 'controlling' }
CFMotionTransformPresentation >> begin [
	active ifTrue: [ ^ self ].
	channel ifNil: [ channel := CFMotionTransformChannel on: element ].
	translation := 0 @ 0.
	scale := 1 @ 1.
	rotation := 0.
	active := true.
	(channel register: self) ifFalse: [ self relinquishOwnership ]
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> channel [ ^ channel ]

{ #category : 'accessing' }
CFMotionTransformPresentation >> channel: aTransformChannel [
	aTransformChannel element == element ifFalse: [
		self error: 'A transform presentation must use a channel for its element' ].
	channel := aTransformChannel
]

{ #category : 'controlling' }
CFMotionTransformPresentation >> adoptCurrentPresentation [
	active ifFalse: [ ^ self ].
	(channel adopt: self) ifTrue: [ self relinquishOwnership ]
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> baseTransformation [
	^ channel ifNil: [ nil ] ifNotNil: [ channel baseTransformation ]
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionTransformPresentation >> element: anElement [ element := anElement ]

{ #category : 'testing' }
CFMotionTransformPresentation >> isActive [ ^ active ]

{ #category : 'testing' }
CFMotionTransformPresentation >> ownsCurrentTransformation [
	^ active and: [ channel ownsCurrentTransformation ]
]

{ #category : 'controlling' }
CFMotionTransformPresentation >> release [
	active ifFalse: [ ^ self ].
	channel release: self.
	self relinquishOwnership
]

{ #category : 'private - controlling' }
CFMotionTransformPresentation >> relinquishOwnership [ active := false ]

{ #category : 'accessing' }
CFMotionTransformPresentation >> scale [ ^ scale ]

{ #category : 'controlling' }
CFMotionTransformPresentation >> scale: aPoint [
	active ifFalse: [ self begin ].
	active ifFalse: [ ^ self ].
	scale := aPoint.
	self apply
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> rotation [ ^ rotation ]

{ #category : 'controlling' }
CFMotionTransformPresentation >> rotation: aNumber [
	active ifFalse: [ self begin ].
	active ifFalse: [ ^ self ].
	rotation := aNumber.
	self apply
]

{ #category : 'accessing' }
CFMotionTransformPresentation >> translation [ ^ translation ]

{ #category : 'controlling' }
CFMotionTransformPresentation >> translation: aPoint [
	active ifFalse: [ self begin ].
	active ifFalse: [ ^ self ].
	translation := aPoint.
	self apply
]
