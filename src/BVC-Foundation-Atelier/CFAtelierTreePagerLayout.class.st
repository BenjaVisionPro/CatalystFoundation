"I am the horizontal tree-flow layout used by Atelier's inspector pager.

Atelier presents exactly one fixed-width page at a time. Free horizontal wheel movement is allowed while the gesture is active, but when input settles I always animate to the nearest page boundary using Foundation Motion. Programmatic page navigation uses the same settling path."
Class {
	#name : 'CFAtelierTreePagerLayout',
	#superclass : 'BlHorizontalTreeFlowLayout',
	#instVars : [
		'settleTask',
		'settleMotion'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'mouse handlers' }
CFAtelierTreePagerLayout >> mouseWheelEvent: anEvent [
	anEvent isPrimarilyHorizontal ifFalse: [ ^ super mouseWheelEvent: anEvent ].
	self cancelSettle.
	super mouseWheelEvent: anEvent.
	self scheduleSettleOf: anEvent currentTarget
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> cancelSettle [
	settleTask ifNotNil: [
		settleTask stop.
		settleTask := nil ].
	settleMotion ifNotNil: [
		settleMotion cancel.
		settleMotion := nil ]
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> nearestPageColumnIn: anElement [
	| visibleChildren nearestChild |
	visibleChildren := anElement children select: [ :each | each isVisibleInParent ].
	visibleChildren ifEmpty: [ ^ 1 ].
	nearestChild := visibleChildren detectMin: [ :each | each position x abs ].
	^ nearestChild constraints horizontalTreeFlow depth
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> scheduleSettleOf: anElement [
	settleTask := BlDelayedTaskAction new
		delay: 90 milliSeconds;
		action: [
			settleTask := nil.
			self settleToNearestPageIn: anElement ].
	anElement enqueueTask: settleTask
]

{ #category : 'api - scrolling' }
CFAtelierTreePagerLayout >> settleToColumn: aColumn in: anElement [
	| child targetOffset motion |
	self assert: [ anElement layout == self ].
	self cancelSettle.
	child := anElement children
		detect: [ :each | each constraints horizontalTreeFlow depth = aColumn ]
		ifNone: [ ^ self scrollToColumn: aColumn in: anElement ].
	anElement width isZero ifTrue: [ ^ self scrollToColumn: aColumn in: anElement ].
	anElement isAttachedToSceneGraph ifFalse: [ ^ self scrollToColumn: aColumn in: anElement ].
	targetOffset := self horizontalOffset + (child position x / anElement width).
	(targetOffset closeTo: self horizontalOffset) ifTrue: [
		^ self scrollToColumn: aColumn in: anElement ].
	motion := CFMotion
		coordinator: anElement space motionCoordinator
		tracks: { CFMotionPropertyTrack
			on: anElement
			property: CFAtelierTreePagerHorizontalOffsetProperty uniqueInstance
			target: targetOffset }.
	motion
		duration: 150 milliSeconds;
		easing: (BlDecelerateInterpolator factor: 1.4);
		onTerminalDo: [ :finishedMotion |
			settleMotion == finishedMotion ifTrue: [ settleMotion := nil ].
			finishedMotion state == CFMotionState completed ifTrue: [
				self scrollToColumn: aColumn in: anElement ] ].
	settleMotion := motion.
	motion start
]

{ #category : 'api - scrolling' }
CFAtelierTreePagerLayout >> settleToNearestPageIn: anElement [
	^ self
		settleToColumn: (self nearestPageColumnIn: anElement)
		in: anElement
]
