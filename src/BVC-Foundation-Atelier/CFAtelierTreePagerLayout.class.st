"I am the horizontal tree-flow layout used by Atelier's inspector pager.

Atelier presents exactly one fixed-width page at a time. Trackpad and wheel input continuously retargets a Foundation Motion toward the projected landing page, so fling deceleration and page settling are one continuous movement rather than a free scroll followed by a delayed snap. Programmatic page navigation uses the same settling path."
Class {
	#name : 'CFAtelierTreePagerLayout',
	#superclass : 'BlHorizontalTreeFlowLayout',
	#instVars : [
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
	self
		settleToColumn: (self projectedLandingColumnFor: anEvent in: anEvent currentTarget)
		in: anEvent currentTarget
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> cancelSettle [
	settleMotion ifNotNil: [
		settleMotion cancel.
		settleMotion := nil ]
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> projectedLandingColumnFor: anEvent in: anElement [
	| projectedOffset projectedRelativeColumn lastColumn |
	anElement width isZero ifTrue: [ ^ self firstVisibleColumn ].
	projectedOffset := self horizontalOffset
		+ ((anEvent vector x / anElement width) * 3.0).
	projectedRelativeColumn := projectedOffset rounded.
	lastColumn := anElement childrenNodesLastColumn max: 1.
	^ ((self firstVisibleColumn + projectedRelativeColumn) max: 1) min: lastColumn
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> settleDurationForDistance: aDistance [
	^ (90 + ((aDistance min: 1.0) * 120)) milliSeconds
]

{ #category : 'api - scrolling' }
CFAtelierTreePagerLayout >> settleToColumn: aColumn in: anElement [
	| targetOffset distance motion |
	self assert: [ anElement layout == self ].
	self cancelSettle.
	anElement width isZero ifTrue: [ ^ self scrollToColumn: aColumn in: anElement ].
	anElement isAttachedToSceneGraph ifFalse: [ ^ self scrollToColumn: aColumn in: anElement ].
	targetOffset := (aColumn - self firstVisibleColumn) asFloat.
	distance := (targetOffset - self horizontalOffset) abs.
	(distance closeTo: 0.0) ifTrue: [
		^ self scrollToColumn: aColumn in: anElement ].
	motion := CFMotion
		coordinator: anElement space motionCoordinator
		tracks: { CFMotionPropertyTrack
			on: anElement
			property: CFAtelierTreePagerHorizontalOffsetProperty uniqueInstance
			target: targetOffset }.
	motion
		duration: (self settleDurationForDistance: distance);
		easing: (BlDecelerateInterpolator factor: 1.7);
		onTerminalDo: [ :finishedMotion |
			settleMotion == finishedMotion ifTrue: [ settleMotion := nil ].
			finishedMotion state == CFMotionState completed ifTrue: [
				self scrollToColumn: aColumn in: anElement ] ].
	settleMotion := motion.
	motion start
]

{ #category : 'api - scrolling' }
CFAtelierTreePagerLayout >> settleToNearestPageIn: anElement [
	| lastColumn relativeColumn targetColumn |
	lastColumn := anElement childrenNodesLastColumn max: 1.
	relativeColumn := self horizontalOffset rounded.
	targetColumn := ((self firstVisibleColumn + relativeColumn) max: 1) min: lastColumn.
	^ self settleToColumn: targetColumn in: anElement
]
