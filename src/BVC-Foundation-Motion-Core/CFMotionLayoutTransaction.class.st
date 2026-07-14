Class {
	#name : 'CFMotionLayoutTransaction',
	#superclass : 'Object',
	#instVars : [
		'coordinateSpace', 'elements', 'mutation', 'duration', 'easing',
		'beforeSnapshots', 'animation', 'generation'
	],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionLayoutTransaction class >> in: anElement [
	^ self new coordinateSpace: anElement; yourself
]

{ #category : 'initialization' }
CFMotionLayoutTransaction >> initialize [
	super initialize.
	elements := OrderedCollection new.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	generation := 0
]

{ #category : 'accessing' }
CFMotionLayoutTransaction >> coordinateSpace: anElement [ coordinateSpace := anElement ]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> affecting: aCollection [
	elements := aCollection asOrderedCollection
]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> mutate: aBlock [ mutation := aBlock ]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> duration: aDuration [ duration := aDuration ]

{ #category : 'configuration' }
CFMotionLayoutTransaction >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'playing' }
CFMotionLayoutTransaction >> play [
	| currentGeneration |
	generation := generation + 1.
	currentGeneration := generation.
	self captureBeforeSnapshots.
	mutation value.
	coordinateSpace space universe postpone: [
		generation = currentGeneration ifTrue: [ self animateFromBeforeSnapshots ] ].
	^ self
]

{ #category : 'private - snapshots' }
CFMotionLayoutTransaction >> captureBeforeSnapshots [
	beforeSnapshots := elements collect: [ :each |
		CFMotionSnapshot
			element: each
			bounds: (self boundsOf: each) ]
]

{ #category : 'private - snapshots' }
CFMotionLayoutTransaction >> boundsOf: anElement [
	^ (coordinateSpace globalBoundsToLocal:
		(anElement localBoundsToGlobal: anElement bounds inLocal copy)) asRectangle
]

{ #category : 'private - playing' }
CFMotionLayoutTransaction >> animateFromBeforeSnapshots [
	| deltas newAnimation currentGeneration |
	deltas := OrderedCollection new.
	beforeSnapshots do: [ :snapshot |
		| element newBounds delta |
		element := snapshot element.
		element parent ifNotNil: [
			newBounds := self boundsOf: element.
			delta := snapshot bounds origin - newBounds origin.
			delta isZero ifFalse: [ deltas add: element -> delta ] ] ].
	deltas ifEmpty: [ ^ self ].
	self apply: deltas progress: 0.0.
	currentGeneration := generation.
	newAnimation := BlNumberTransition new
		from: 0.0;
		to: 1.0;
		duration: duration;
		easing: easing;
		onStepDo: [ :progress | self apply: deltas progress: progress ];
		yourself.
	animation := newAnimation.
	newAnimation onFinishedDo: [
		(animation == newAnimation and: [ generation = currentGeneration ]) ifTrue: [
			animation := nil.
			self clear: deltas ] ].
	coordinateSpace addAnimation: newAnimation
]

{ #category : 'private - playing' }
CFMotionLayoutTransaction >> apply: deltas progress: progress [
	deltas do: [ :association |
		association key transformDo: [ :builder |
			builder translateBy: association value * (1.0 - progress) ] ]
]

{ #category : 'private - playing' }
CFMotionLayoutTransaction >> clear: deltas [
	deltas do: [ :association |
		association key transformation: BlElementLocalTransformation new ]
]

{ #category : 'controlling' }
CFMotionLayoutTransaction >> cancel [
	generation := generation + 1.
	animation ifNotNil: [ :current |
		animation := nil.
		current stopIfRunning ].
	elements do: [ :each |
		each transformation: BlElementLocalTransformation new ]
]
