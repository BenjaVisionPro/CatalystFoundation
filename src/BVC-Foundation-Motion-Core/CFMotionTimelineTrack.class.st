Class {
	#name : 'CFMotionTimelineTrack',
	#superclass : 'CFMotionTrack',
	#instVars : [ 'timeline', 'motionTrack', 'duration', 'easing', 'repeatInterval', 'startAnchor', 'startOffset', 'hasExplicitStartPlacement', 'endAnchor', 'endOffset', 'hasEndPlacement', 'resolvedStart', 'resolvedEnd', 'trackStartAnchor', 'trackEndAnchor' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTimelineTrack class >> in: aTimeline [
	^ self new
		timeline: aTimeline;
		yourself
]

{ #category : 'instance creation' }
CFMotionTimelineTrack class >> on: aMotionTrack in: aTimeline [
	^ (self in: aTimeline)
		motionTrack: aMotionTrack;
		yourself
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> animationTarget [
	^ motionTrack animationTarget
]

{ #category : 'playing' }
CFMotionTimelineTrack >> applyDestination [
	motionTrack applyDestination
]

{ #category : 'playing' }
CFMotionTimelineTrack >> applyProgress: aProgress [
	| elapsedTime |
	elapsedTime := timeline duration * aProgress.
	elapsedTime < resolvedStart ifTrue: [ ^ self ].
	elapsedTime >= resolvedEnd ifTrue: [ ^ motionTrack applyProgress: 1.0 ].
	motionTrack applyProgress: (easing interpolate: (elapsedTime - resolvedStart) / duration)
]

{ #category : 'playing' }
CFMotionTimelineTrack >> captureOrigin [
	motionTrack captureOrigin
]

{ #category : 'playing' }
CFMotionTimelineTrack >> captureOriginIn: aCoordinator [
	motionTrack captureOriginIn: aCoordinator
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> clearResolvedTimes [
	resolvedStart := nil.
	resolvedEnd := nil
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> duration: aDuration [
	aDuration <= (0 milliSeconds) ifTrue: [
		self error: 'A Motion track duration must be positive' ].
	duration := aDuration.
	^ self
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> duration [
	^ duration
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> ends: aDuration after: anAnchor [
	^ self endsAt: anAnchor offset: aDuration
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> ends: aDuration before: anAnchor [
	^ self endsAt: anAnchor offset: aDuration negated
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> endsAt: anAnchor [
	^ self endsAt: anAnchor offset: 0 milliSeconds
]

{ #category : 'private - configuration' }
CFMotionTimelineTrack >> endsAt: anAnchor offset: anOffset [
	self validateAnchor: anAnchor.
	endAnchor := anAnchor.
	endOffset := anOffset.
	hasEndPlacement := true.
	^ self
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> end [
	^ trackEndAnchor
]

{ #category : 'testing' }
CFMotionTimelineTrack >> establishesTimelineEnd [
	^ self isFinite and: [ (self referencesTimelineEndWith: IdentitySet new) not ]
]

{ #category : 'testing' }
CFMotionTimelineTrack >> hasEndPlacement [
	^ hasEndPlacement
]

{ #category : 'testing' }
CFMotionTimelineTrack >> hasExplicitStartPlacement [
	^ hasExplicitStartPlacement
]

{ #category : 'initialization' }
CFMotionTimelineTrack >> initialize [
	super initialize.
	startOffset := 0 milliSeconds.
	endOffset := 0 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	hasExplicitStartPlacement := false.
	hasEndPlacement := false
]

{ #category : 'testing' }
CFMotionTimelineTrack >> isFinite [
	duration ifNil: [ ^ false ].
	repeatInterval ifNil: [ ^ true ].
	^ hasEndPlacement
]

{ #category : 'testing' }
CFMotionTimelineTrack >> isAtDestination [
	^ resolvedStart = (0 milliSeconds) and: [ motionTrack isAtDestination ]
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> motionTrack [
	^ motionTrack
]

{ #category : 'private - initialization' }
CFMotionTimelineTrack >> motionTrack: aMotionTrack [
	motionTrack := aMotionTrack.
	^ self
]

{ #category : 'playing' }
CFMotionTimelineTrack >> preserveCurrentPresentation [
	motionTrack preserveCurrentPresentation
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> propertyKey [
	^ motionTrack propertyKey
]

{ #category : 'testing' }
CFMotionTimelineTrack >> referencesTimelineEndWith: aCollection [
	(aCollection includes: self) ifTrue: [ ^ false ].
	aCollection add: self.
	^ (startAnchor referencesTimelineEndWith: aCollection)
		or: [ hasEndPlacement and: [ endAnchor referencesTimelineEndWith: aCollection ] ]
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> resolveUsing: aTimeline [
	duration ifNil: [ self error: 'A Motion track needs a duration' ].
	repeatInterval
		ifNil: [ ^ self resolveSingleOccurrenceUsing: aTimeline ]
		ifNotNil: [ ^ self resolveRepeatedOccurrencesUsing: aTimeline ]
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> resolveRepeatedOccurrencesUsing: aTimeline [
	| placedStart placedEnd changed |
	placedStart := self resolvedStartPlacementUsing: aTimeline.
	placedEnd := self resolvedEndPlacementUsing: aTimeline.
	changed := false.
	placedStart ifNotNil: [ changed := self recordResolvedStart: placedStart ].
	placedEnd ifNotNil: [ changed := (self recordResolvedEnd: placedEnd) or: [ changed ] ].
	^ changed
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> resolveSingleOccurrenceUsing: aTimeline [
	| placedStart placedEnd changed |
	placedStart := self resolvedStartPlacementUsing: aTimeline.
	placedEnd := self resolvedEndPlacementUsing: aTimeline.
	hasEndPlacement ifFalse: [
		placedStart ifNil: [ ^ false ].
		changed := self recordResolvedStart: placedStart.
		^ (self recordResolvedEnd: placedStart + duration) or: [ changed ] ].
	placedEnd ifNil: [ ^ false ].
	changed := self recordResolvedEnd: placedEnd.
	hasExplicitStartPlacement
		ifTrue: [
			placedStart ifNil: [ ^ changed ].
			(placedStart + duration = placedEnd) ifFalse: [
				self error: 'A Motion track start, end, and duration disagree' ].
			^ (self recordResolvedStart: placedStart) or: [ changed ] ]
		ifFalse: [ ^ (self recordResolvedStart: placedEnd - duration) or: [ changed ] ]
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> resolvedEndPlacementUsing: aTimeline [
	hasEndPlacement ifFalse: [ ^ nil ].
	^ (aTimeline resolvedTimeOf: endAnchor)
		ifNotNil: [ :aDuration | aDuration + endOffset ]
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> resolvedStartPlacementUsing: aTimeline [
	^ (aTimeline resolvedTimeOf: startAnchor)
		ifNotNil: [ :aDuration | aDuration + startOffset ]
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> recordResolvedEnd: aDuration [
	resolvedEnd ifNil: [ resolvedEnd := aDuration. ^ true ].
	resolvedEnd = aDuration ifFalse: [ self error: 'A Motion track has incompatible end placements' ].
	^ false
]

{ #category : 'private - resolving' }
CFMotionTimelineTrack >> recordResolvedStart: aDuration [
	resolvedStart ifNil: [ resolvedStart := aDuration. ^ true ].
	resolvedStart = aDuration ifFalse: [ self error: 'A Motion track has incompatible start placements' ].
	^ false
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> repeatInterval [
	^ repeatInterval
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> repeatsEvery: anInterval [
	anInterval <= (0 milliSeconds) ifTrue: [
		self error: 'A Motion repeat interval must be positive' ].
	repeatInterval := anInterval.
	^ self
]

{ #category : 'playing' }
CFMotionTimelineTrack >> prepareFromCurrentPresentation [
	motionTrack prepareFromCurrentPresentation
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> resolvedEnd [
	^ resolvedEnd
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> resolvedStart [
	^ resolvedStart
]

{ #category : 'playing' }
CFMotionTimelineTrack >> restoreOrigin [
	motionTrack restoreOrigin
]

{ #category : 'controlling' }
CFMotionTimelineTrack >> reversed [
	^ self class on: motionTrack reversed in: timeline
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> start [
	^ trackStartAnchor
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> starts: aDuration after: anAnchor [
	^ self startsAt: anAnchor offset: aDuration
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> starts: aDuration before: anAnchor [
	^ self startsAt: anAnchor offset: aDuration negated
]

{ #category : 'configuration' }
CFMotionTimelineTrack >> startsAt: anAnchor [
	^ self startsAt: anAnchor offset: 0 milliSeconds
]

{ #category : 'private - configuration' }
CFMotionTimelineTrack >> startsAt: anAnchor offset: anOffset [
	self validateAnchor: anAnchor.
	startAnchor := anAnchor.
	startOffset := anOffset.
	hasExplicitStartPlacement := true.
	^ self
]

{ #category : 'accessing' }
CFMotionTimelineTrack >> timeline [
	^ timeline
]

{ #category : 'private - initialization' }
CFMotionTimelineTrack >> timeline: aTimeline [
	timeline := aTimeline.
	startAnchor := aTimeline start.
	trackStartAnchor := CFMotionTemporalAnchor trackStart: self.
	trackEndAnchor := CFMotionTemporalAnchor trackEnd: self.
	aTimeline addTrack: self
]

{ #category : 'private - validation' }
CFMotionTimelineTrack >> validateAnchor: anAnchor [
	(anAnchor isIn: timeline) ifFalse: [
		self error: 'A Motion track anchor must belong to its timeline' ]
]

{ #category : 'private - validation' }
CFMotionTimelineTrack >> validateForExecution [
	repeatInterval ifNotNil: [
		self error: 'Repeated Motion tracks are not executable yet' ].
	motionTrack ifNil: [
		self error: 'A Motion timeline track needs a visual track before it can execute' ]
]
