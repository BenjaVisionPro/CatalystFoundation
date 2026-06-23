Class {
	#name : 'CFRubberBandAnimatorExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> animatorCanBeCreatedOnExistingMotion [
	<gtExample>
	| motion animator |
	motion := CFRubberBandMotion new.
	motion moveTo: 10 @ 20.

	animator := CFRubberBandAnimator on: motion.

	self assert: animator motion == motion.
	self assert: animator motion logicalPosition = (10 @ 20).
	self assert: animator isIdle.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> animatorForVerticalMotion [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.
	animator vertical
		minimum: 0;
		maximum: 1000;
		dimension: 500.

	self assert: animator motion hasProjectionPlane.
	self assert: (animator motion projectionPlane hasHorizontal) not.
	self assert: animator motion projectionPlane hasVertical.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> configurableSpringAndDecayParameters [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.
	animator
		springStiffness: 200;
		springDamping: 28;
		decelerationRate: 3;
		positionEpsilon: 0.1;
		velocityEpsilon: 0.2.

	self assert: animator springStiffness = 200.
	self assert: animator springDamping = 28.
	self assert: animator decelerationRate = 3.
	self assert: animator positionEpsilon = 0.1.
	self assert: animator velocityEpsilon = 0.2.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> deceleratingCrossesBoundsAndStartsSettling [
	<gtExample>
	| animator |
	animator := self animatorForVerticalMotion.
	animator motion moveTo: 0 @ 990.
	animator decelerateWithVelocity: 0 @ 200.

	animator stepBy: 0.1.

	self assert: animator isSettling.
	self assert: animator hasTargetPosition.
	self assert: animator targetPosition = (0 @ 1000).

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> deceleratingStepMovesAndReducesVelocity [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.
	animator motion moveTo: 0 @ 0.
	animator decelerateWithVelocity: 100 @ 0.

	animator stepBy: 0.1.

	self assert: animator isDecelerating.
	self assert: animator motion logicalPosition = (10.0 @ 0.0).
	self assert: animator motion logicalVelocity = (50.0 @ 0.0).

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> decelerateWithZeroVelocityStopsImmediately [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.
	animator decelerateWithVelocity: 0 @ 0.

	self assert: animator isIdle.
	self assert: animator motion logicalVelocity = (0 @ 0).

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> newAnimatorIsIdleWithNeutralMotion [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.

	self assert: animator isIdle.
	self assert: (animator isAnimating) not.
	self assert: (animator isDecelerating) not.
	self assert: (animator isSettling) not.
	self assert: animator motion logicalPosition = (0 @ 0).
	self assert: animator motion logicalVelocity = (0 @ 0).
	self assert: (animator hasTargetPosition) not.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> settlingEventuallySnapsToBounds [
	<gtExample>
	| animator |
	animator := self animatorForVerticalMotion.
	animator motion moveTo: 0 @ 1200.
	animator settleToBounds.

	1 to: 200 do: [ :index |
		animator isAnimating
			ifTrue: [ animator stepBy: 0.016 ] ].

	self assert: animator isIdle.
	self assert: animator motion logicalPosition = (0 @ 1000).
	self assert: animator motion logicalVelocity = (0 @ 0).
	self assert: animator motion projectedPosition = (0 @ 1000).

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> settlingInsideBoundsStopsImmediately [
	<gtExample>
	| animator |
	animator := self animatorForVerticalMotion.
	animator motion moveTo: 0 @ 500.
	animator settleToBounds.

	self assert: animator isIdle.
	self assert: animator motion logicalPosition = (0 @ 500).
	self assert: animator motion logicalVelocity = (0 @ 0).
	self assert: (animator hasTargetPosition) not.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> settlingStepMovesTowardReleaseTarget [
	<gtExample>
	| animator |
	animator := self animatorForVerticalMotion.
	animator motion moveTo: 0 @ 1200.
	animator settleToBounds.

	self assert: animator isSettling.
	self assert: animator targetPosition = (0 @ 1000).

	animator stepBy: 0.016.

	self assert: animator isSettling.
	self assert: animator motion logicalPosition y < 1200.
	self assert: animator motion logicalPosition y > 1000.
	self assert: animator motion logicalVelocity y < 0.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> stepByNegativeDurationRaisesError [
	<gtExample>
	| animator didRaise |
	animator := CFRubberBandAnimator new.
	didRaise := false.

	[ animator stepBy: -1 ]
		on: Error
		do: [ :error | didRaise := true ].

	self assert: didRaise.

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> stepWhileIdleDoesNothing [
	<gtExample>
	| animator |
	animator := CFRubberBandAnimator new.
	animator motion
		moveTo: 10 @ 20;
		logicalVelocity: 3 @ 4.

	animator stepBy: 1.

	self assert: animator isIdle.
	self assert: animator motion logicalPosition = (10 @ 20).
	self assert: animator motion logicalVelocity = (3 @ 4).

	^ animator
]

{ #category : 'examples' }
CFRubberBandAnimatorExamples >> stopClearsModeTargetAndVelocity [
	<gtExample>
	| animator |
	animator := self animatorForVerticalMotion.
	animator motion
		moveTo: 0 @ 1200;
		logicalVelocity: 0 @ 10.
	animator settleToBounds.
	self assert: animator isSettling.

	animator stop.

	self assert: animator isIdle.
	self assert: (animator hasTargetPosition) not.
	self assert: animator motion logicalVelocity = (0 @ 0).

	^ animator
]
