"I am the horizontal tree-flow layout used by Atelier's inspector pager.

Atelier presents exactly one fixed-width page at a time. While a trackpad interaction is active, the user owns my horizontal position completely and no Motion is allowed to act on it. At the native touch Ended phase I hand the measured release position and velocity to one Foundation Motion. Its Hermite easing begins with that same velocity and ends at the selected fixed page boundary with zero velocity. Native momentum events after release are ignored until the next Started phase, because Motion owns the continuation after physical release. Programmatic navigation settles with zero initial velocity through the same page-boundary path."
Class {
	#name : 'CFAtelierTreePagerLayout',
	#superclass : 'BlHorizontalTreeFlowLayout',
	#instVars : [
		'settleMotion',
		'interactionActive',
		'lastInteractionTimestamp',
		'releaseVelocity'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierTreePagerLayout >> initialize [
	super initialize.
	interactionActive := false.
	releaseVelocity := 0.0
]

{ #category : 'mouse handlers' }
CFAtelierTreePagerLayout >> mouseWheelEvent: anEvent [
	| phase |
	anEvent isPrimarilyHorizontal ifFalse: [ ^ super mouseWheelEvent: anEvent ].

	phase := anEvent phase.
	phase ifNil: [ ^ self handleDiscreteWheelEvent: anEvent ].
	phase = phase class Unknown ifTrue: [ ^ self handleDiscreteWheelEvent: anEvent ].

	phase = phase class Started ifTrue: [
		^ self beginUserInteractionWith: anEvent ].
	phase = phase class Ended ifTrue: [
		^ self endUserInteractionWith: anEvent ].
	phase = phase class Cancelled ifTrue: [
		^ self endUserInteractionWith: anEvent ].

	interactionActive ifFalse: [
		"After physical release the platform may continue to emit momentum
		wheel events. Motion owns continuation from Ended until Started."
		anEvent consumed: true.
		^ self ].

	self applyUserScrollEvent: anEvent
]

{ #category : 'private - interaction' }
CFAtelierTreePagerLayout >> beginUserInteractionWith: anEvent [
	self cancelSettle.
	interactionActive := true.
	releaseVelocity := 0.0.
	lastInteractionTimestamp := nil.
	self applyUserScrollEvent: anEvent
]

{ #category : 'private - interaction' }
CFAtelierTreePagerLayout >> applyUserScrollEvent: anEvent [
	| previousOffset previousTimestamp |
	previousOffset := self horizontalOffset.
	previousTimestamp := lastInteractionTimestamp.

	super mouseWheelEvent: anEvent.

	self
		updateReleaseVelocityFrom: previousOffset
		at: previousTimestamp
		to: self horizontalOffset
		at: anEvent timestamp.
	lastInteractionTimestamp := anEvent timestamp
]

{ #category : 'private - interaction' }
CFAtelierTreePagerLayout >> updateReleaseVelocityFrom: aPreviousOffset at: aPreviousTimestamp to: aCurrentOffset at: aCurrentTimestamp [
	| elapsedMilliseconds delta |
	aPreviousTimestamp ifNil: [ ^ self ].
	elapsedMilliseconds := (aCurrentTimestamp - aPreviousTimestamp) asMilliSeconds.
	elapsedMilliseconds <= 0 ifTrue: [ ^ self ].
	delta := aCurrentOffset - aPreviousOffset.
	delta isZero ifFalse: [
		releaseVelocity := delta / (elapsedMilliseconds / 1000.0) ]
]

{ #category : 'private - interaction' }
CFAtelierTreePagerLayout >> endUserInteractionWith: anEvent [
	interactionActive ifFalse: [
		anEvent consumed: true.
		^ self ].

	"The Ended event is the physical-release boundary. Apply any final delta
	belonging to that event before capturing the handoff state."
	self applyUserScrollEvent: anEvent.
	interactionActive := false.
	self
		settleFromReleaseVelocity: releaseVelocity
		in: anEvent currentTarget
]

{ #category : 'private - interaction' }
CFAtelierTreePagerLayout >> handleDiscreteWheelEvent: anEvent [
	"A conventional wheel has no touch Started/Ended lifecycle. Treat each
	discrete wheel event as an atomic interaction."
	self cancelSettle.
	interactionActive := true.
	lastInteractionTimestamp := nil.
	releaseVelocity := 0.0.
	self applyUserScrollEvent: anEvent.
	interactionActive := false.
	self settleFromReleaseVelocity: releaseVelocity in: anEvent currentTarget
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> cancelSettle [
	settleMotion ifNotNil: [
		settleMotion cancel.
		settleMotion := nil ]
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> landingColumnForReleaseVelocity: aVelocity in: anElement [
	| projectedOffset projectedRelativeColumn lastColumn |
	anElement width isZero ifTrue: [ ^ self firstVisibleColumn ].
	projectedOffset := self horizontalOffset + (aVelocity * 0.16).
	projectedRelativeColumn := projectedOffset rounded.
	lastColumn := anElement childrenNodesLastColumn max: 1.
	^ ((self firstVisibleColumn + projectedRelativeColumn) max: 1) min: lastColumn
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> settleDurationForDistance: aDistance initialVelocity: aVelocity [
	| seconds velocityLimitedSeconds |
	aDistance isZero ifTrue: [ ^ 0 milliSeconds ].
	seconds := 0.18 + ((aDistance abs min: 1.0) * 0.10).
	aVelocity abs > 0.001 ifTrue: [
		"Keep the Hermite initial slope in a useful range while preserving the
		actual velocity: changing duration changes normalised slope, not velocity."
		velocityLimitedSeconds := (2.5 * aDistance abs / aVelocity abs) max: 0.06.
		seconds := seconds min: velocityLimitedSeconds ].
	^ (seconds * 1000.0) milliSeconds
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> settleFromReleaseVelocity: aVelocity in: anElement [
	| targetColumn |
	targetColumn := self landingColumnForReleaseVelocity: aVelocity in: anElement.
	^ self
		settleToColumn: targetColumn
		in: anElement
		initialVelocity: aVelocity
]

{ #category : 'api - scrolling' }
CFAtelierTreePagerLayout >> settleToColumn: aColumn in: anElement [
	^ self settleToColumn: aColumn in: anElement initialVelocity: 0.0
]

{ #category : 'private - settling' }
CFAtelierTreePagerLayout >> settleToColumn: aColumn in: anElement initialVelocity: aVelocity [
	| targetOffset distance durationSeconds initialSlope motion duration |
	self assert: [ anElement layout == self ].
	self cancelSettle.
	anElement width isZero ifTrue: [ ^ self scrollToColumn: aColumn in: anElement ].
	anElement isAttachedToSceneGraph ifFalse: [ ^ self scrollToColumn: aColumn in: anElement ].

	targetOffset := (aColumn - self firstVisibleColumn) asFloat.
	distance := targetOffset - self horizontalOffset.
	(distance closeTo: 0.0) ifTrue: [
		^ self scrollToColumn: aColumn in: anElement ].

	duration := self settleDurationForDistance: distance initialVelocity: aVelocity.
	durationSeconds := duration asMilliSeconds / 1000.0.
	initialSlope := aVelocity * durationSeconds / distance.

	motion := CFMotion
		coordinator: anElement space motionCoordinator
		tracks: { CFMotionPropertyTrack
			on: anElement
			property: CFAtelierTreePagerHorizontalOffsetProperty uniqueInstance
			target: targetOffset }.
	motion
		duration: duration;
		easing: (CFAtelierPageSettleInterpolator initialSlope: initialSlope);
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
