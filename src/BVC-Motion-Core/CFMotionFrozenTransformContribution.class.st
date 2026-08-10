"
I represent a transform contribution that has been frozen into Motion composition.

I preserve translation, scale, rotation and transform origin after an active presentation is adopted, so the shared transform channel can retain that visual result without retaining an active presentation owner.
"
Class {
	#name : 'CFMotionFrozenTransformContribution',
	#superclass : 'Object',
	#instVars : [ 'translation', 'scale', 'rotation', 'transformOrigin' ],
	#category : 'BVC-Motion-Core',
	#package : 'BVC-Motion-Core'
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
	| motionTransformation |
	motionTransformation := BlAffineCompositeTransformation new.
	scale = (1 @ 1) ifFalse: [
		motionTransformation addTransformation:
			((BlScalingTransformation scale: scale) origin: transformOrigin) ].
	rotation isZero ifFalse: [
		motionTransformation addTransformation:
			(BlRotationTransformation new
				angle: rotation;
				axis: BlVector zAxis;
				origin: transformOrigin) ].
	translation isZero ifFalse: [
		motionTransformation addTransformation:
			((BlTranslationTransformation translation: translation) origin: transformOrigin) ].
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

{ #category : 'accessing' }
CFMotionFrozenTransformContribution >> transformOrigin: anOrigin [ transformOrigin := anOrigin ]
