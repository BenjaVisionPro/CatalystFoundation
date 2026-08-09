"I collect opt-in, low-overhead timing and work counters for one Physics overlay. I am disabled by default and retain only aggregate numbers, never per-frame samples."
Class {
	#name : 'CFPhysicsOverlayPerformance',
	#superclass : 'Object',
	#instVars : [
		'enabled',
		'frameRefreshCount', 'frameRefreshMilliseconds', 'frameRefreshMaximumMilliseconds',
		'constraintGeometryCount', 'constraintVisualUpdateCount', 'constraintGeometryMilliseconds', 'constraintGeometryMaximumMilliseconds',
		'contactReconcileCount', 'contactReconcileVisualCount', 'contactReconcileMilliseconds', 'contactReconcileMaximumMilliseconds',
		'contactGeometryCount', 'contactGeometryVisualUpdateCount', 'contactGeometryMilliseconds', 'contactGeometryMaximumMilliseconds',
		'selectionRefreshCount', 'selectionRefreshMilliseconds', 'selectionRefreshMaximumMilliseconds',
		'inspectorRefreshCount', 'inspectorRefreshMilliseconds', 'inspectorRefreshMaximumMilliseconds',
		'hostTransformationRefreshCount', 'hostTransformationRefreshMilliseconds', 'hostTransformationRefreshMaximumMilliseconds'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'initialization' }
CFPhysicsOverlayPerformance >> initialize [
	super initialize.
	enabled := false.
	self reset
]

{ #category : 'controlling' }
CFPhysicsOverlayPerformance >> start [
	self reset.
	enabled := true.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlayPerformance >> stop [
	enabled := false.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlayPerformance >> reset [
	frameRefreshCount := 0.
	frameRefreshMilliseconds := 0.
	frameRefreshMaximumMilliseconds := 0.
	constraintGeometryCount := 0.
	constraintVisualUpdateCount := 0.
	constraintGeometryMilliseconds := 0.
	constraintGeometryMaximumMilliseconds := 0.
	contactReconcileCount := 0.
	contactReconcileVisualCount := 0.
	contactReconcileMilliseconds := 0.
	contactReconcileMaximumMilliseconds := 0.
	contactGeometryCount := 0.
	contactGeometryVisualUpdateCount := 0.
	contactGeometryMilliseconds := 0.
	contactGeometryMaximumMilliseconds := 0.
	selectionRefreshCount := 0.
	selectionRefreshMilliseconds := 0.
	selectionRefreshMaximumMilliseconds := 0.
	inspectorRefreshCount := 0.
	inspectorRefreshMilliseconds := 0.
	inspectorRefreshMaximumMilliseconds := 0.
	hostTransformationRefreshCount := 0.
	hostTransformationRefreshMilliseconds := 0.
	hostTransformationRefreshMaximumMilliseconds := 0.
	^ self
]

{ #category : 'testing' }
CFPhysicsOverlayPerformance >> isEnabled [
	^ enabled
]

{ #category : 'private - measuring' }
CFPhysicsOverlayPerformance >> startMeasurement [
	^ enabled
		ifTrue: [ Time millisecondClockValue ]
		ifFalse: [ nil ]
]

{ #category : 'private - measuring' }
CFPhysicsOverlayPerformance >> elapsedMillisecondsSince: startedAt [
	^ Time millisecondClockValue - startedAt
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordFrameRefreshStartedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	frameRefreshCount := frameRefreshCount + 1.
	frameRefreshMilliseconds := frameRefreshMilliseconds + elapsed.
	frameRefreshMaximumMilliseconds := frameRefreshMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordConstraintGeometryVisualCount: visualCount startedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	constraintGeometryCount := constraintGeometryCount + 1.
	constraintVisualUpdateCount := constraintVisualUpdateCount + visualCount.
	constraintGeometryMilliseconds := constraintGeometryMilliseconds + elapsed.
	constraintGeometryMaximumMilliseconds := constraintGeometryMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordContactReconcileVisualCount: visualCount startedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	contactReconcileCount := contactReconcileCount + 1.
	contactReconcileVisualCount := contactReconcileVisualCount + visualCount.
	contactReconcileMilliseconds := contactReconcileMilliseconds + elapsed.
	contactReconcileMaximumMilliseconds := contactReconcileMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordContactGeometryVisualCount: visualCount startedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	contactGeometryCount := contactGeometryCount + 1.
	contactGeometryVisualUpdateCount := contactGeometryVisualUpdateCount + visualCount.
	contactGeometryMilliseconds := contactGeometryMilliseconds + elapsed.
	contactGeometryMaximumMilliseconds := contactGeometryMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordSelectionRefreshStartedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	selectionRefreshCount := selectionRefreshCount + 1.
	selectionRefreshMilliseconds := selectionRefreshMilliseconds + elapsed.
	selectionRefreshMaximumMilliseconds := selectionRefreshMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordInspectorRefreshStartedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	inspectorRefreshCount := inspectorRefreshCount + 1.
	inspectorRefreshMilliseconds := inspectorRefreshMilliseconds + elapsed.
	inspectorRefreshMaximumMilliseconds := inspectorRefreshMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'recording' }
CFPhysicsOverlayPerformance >> recordHostTransformationRefreshStartedAt: startedAt [
	| elapsed |
	startedAt ifNil: [ ^ self ].
	elapsed := self elapsedMillisecondsSince: startedAt.
	hostTransformationRefreshCount := hostTransformationRefreshCount + 1.
	hostTransformationRefreshMilliseconds := hostTransformationRefreshMilliseconds + elapsed.
	hostTransformationRefreshMaximumMilliseconds := hostTransformationRefreshMaximumMilliseconds max: elapsed.
	^ self
]

{ #category : 'accessing - frame' }
CFPhysicsOverlayPerformance >> frameRefreshCount [ ^ frameRefreshCount ]
{ #category : 'accessing - frame' }
CFPhysicsOverlayPerformance >> frameRefreshMilliseconds [ ^ frameRefreshMilliseconds ]
{ #category : 'accessing - frame' }
CFPhysicsOverlayPerformance >> frameRefreshMaximumMilliseconds [ ^ frameRefreshMaximumMilliseconds ]

{ #category : 'accessing - constraints' }
CFPhysicsOverlayPerformance >> constraintGeometryCount [ ^ constraintGeometryCount ]
{ #category : 'accessing - constraints' }
CFPhysicsOverlayPerformance >> constraintVisualUpdateCount [ ^ constraintVisualUpdateCount ]
{ #category : 'accessing - constraints' }
CFPhysicsOverlayPerformance >> constraintGeometryMilliseconds [ ^ constraintGeometryMilliseconds ]
{ #category : 'accessing - constraints' }
CFPhysicsOverlayPerformance >> constraintGeometryMaximumMilliseconds [ ^ constraintGeometryMaximumMilliseconds ]

{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactReconcileCount [ ^ contactReconcileCount ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactReconcileVisualCount [ ^ contactReconcileVisualCount ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactReconcileMilliseconds [ ^ contactReconcileMilliseconds ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactReconcileMaximumMilliseconds [ ^ contactReconcileMaximumMilliseconds ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactGeometryCount [ ^ contactGeometryCount ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactGeometryVisualUpdateCount [ ^ contactGeometryVisualUpdateCount ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactGeometryMilliseconds [ ^ contactGeometryMilliseconds ]
{ #category : 'accessing - contacts' }
CFPhysicsOverlayPerformance >> contactGeometryMaximumMilliseconds [ ^ contactGeometryMaximumMilliseconds ]

{ #category : 'accessing - selection' }
CFPhysicsOverlayPerformance >> selectionRefreshCount [ ^ selectionRefreshCount ]
{ #category : 'accessing - selection' }
CFPhysicsOverlayPerformance >> selectionRefreshMilliseconds [ ^ selectionRefreshMilliseconds ]
{ #category : 'accessing - selection' }
CFPhysicsOverlayPerformance >> selectionRefreshMaximumMilliseconds [ ^ selectionRefreshMaximumMilliseconds ]

{ #category : 'accessing - inspector' }
CFPhysicsOverlayPerformance >> inspectorRefreshCount [ ^ inspectorRefreshCount ]
{ #category : 'accessing - inspector' }
CFPhysicsOverlayPerformance >> inspectorRefreshMilliseconds [ ^ inspectorRefreshMilliseconds ]
{ #category : 'accessing - inspector' }
CFPhysicsOverlayPerformance >> inspectorRefreshMaximumMilliseconds [ ^ inspectorRefreshMaximumMilliseconds ]

{ #category : 'accessing - host transformation' }
CFPhysicsOverlayPerformance >> hostTransformationRefreshCount [ ^ hostTransformationRefreshCount ]
{ #category : 'accessing - host transformation' }
CFPhysicsOverlayPerformance >> hostTransformationRefreshMilliseconds [ ^ hostTransformationRefreshMilliseconds ]
{ #category : 'accessing - host transformation' }
CFPhysicsOverlayPerformance >> hostTransformationRefreshMaximumMilliseconds [ ^ hostTransformationRefreshMaximumMilliseconds ]

{ #category : 'accessing' }
CFPhysicsOverlayPerformance >> summary [
	^ {
		#frameRefreshes -> frameRefreshCount.
		#frameMilliseconds -> frameRefreshMilliseconds.
		#frameMaximumMilliseconds -> frameRefreshMaximumMilliseconds.
		#constraintPasses -> constraintGeometryCount.
		#constraintVisualUpdates -> constraintVisualUpdateCount.
		#constraintMilliseconds -> constraintGeometryMilliseconds.
		#constraintMaximumMilliseconds -> constraintGeometryMaximumMilliseconds.
		#contactReconciliations -> contactReconcileCount.
		#contactReconciledVisuals -> contactReconcileVisualCount.
		#contactReconcileMilliseconds -> contactReconcileMilliseconds.
		#contactGeometryPasses -> contactGeometryCount.
		#contactVisualUpdates -> contactGeometryVisualUpdateCount.
		#contactGeometryMilliseconds -> contactGeometryMilliseconds.
		#selectionRefreshes -> selectionRefreshCount.
		#selectionMilliseconds -> selectionRefreshMilliseconds.
		#inspectorRefreshes -> inspectorRefreshCount.
		#inspectorMilliseconds -> inspectorRefreshMilliseconds.
		#hostTransformationRefreshes -> hostTransformationRefreshCount.
		#hostTransformationMilliseconds -> hostTransformationRefreshMilliseconds }
]
