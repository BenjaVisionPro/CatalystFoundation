Class {
	#name : 'CFMotionFrozenTransformContribution',
	#superclass : 'Object',
	#instVars : [ 'translation', 'scale', 'rotation' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionFrozenTransformContribution class >> scale: aScale rotation: aRotation translation: aTranslation [
	^ self new
		scale: aScale;
		rotation: aRotation;
		translation: aTranslation;
		yourself
]

{ #category : 'private - applying' }
CFMotionFrozenTransformContribution >> addContributionTo: aCompositeTransformation [
	| motionTransformation origin |
	motionTransformation := BlAffineCompositeTransformation new.
	origin := BlAffineTransformationTopLeftOrigin new.
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

{ #category : 'testing' }
CFMotionFrozenTransformContribution >> isActive [ ^ false ]

{ #category : 'private - controlling' }
CFMotionFrozenTransformContribution >> relinquishOwnership [ ]

{ #category : 'accessing' }
CFMotionFrozenTransformContribution >> scale: aPoint [ scale := aPoint ]

{ #category : 'accessing' }
CFMotionFrozenTransformContribution >> rotation: aNumber [ rotation := aNumber ]

{ #category : 'accessing' }
CFMotionFrozenTransformContribution >> translation: aPoint [ translation := aPoint ]
