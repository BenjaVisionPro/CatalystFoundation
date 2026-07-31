"I preserve one real TelemetrySignal/TelemetryPing execution contributing to Physics span statistics."
Class {
	#name : 'CFPhysicsTelemetrySpanSample',
	#superclass : 'Object',
	#instVars : [ 'signal', 'ping', 'parentPing', 'sequence' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsTelemetrySpanSample class >> signal: aSignal ping: aPing parent: aParentPing sequence: anInteger [
	^ self new
		signal: aSignal;
		ping: aPing;
		parentPing: aParentPing;
		sequence: anInteger;
		yourself
]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> signal [ ^ signal ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> signal: anObject [ signal := anObject ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> ping [ ^ ping ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> ping: anObject [ ping := anObject ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> parentPing [ ^ parentPing ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> parentPing: anObject [ parentPing := anObject ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> sequence [ ^ sequence ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> sequence: anInteger [ sequence := anInteger ]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> start [
	^ ping startTime - parentPing startTime
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> end [
	^ ping endTime - parentPing startTime
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> elapsedDuration [
	^ ping endTime - ping startTime
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> duration [
	"Use Telemetry's measured duration so GC and nested telemetry overhead are treated consistently with TelemetrySignal/TelemetryPing."
	^ ping duration
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> durationMilliseconds [
	^ self duration / 1000.0
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> startMilliseconds [
	^ self start / 1000.0
]

{ #category : 'timing' }
CFPhysicsTelemetrySpanSample >> endMilliseconds [
	^ self end / 1000.0
]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> stepNumber [
	| data |
	data := signal physicsData.
	^ data ifNil: [ nil ] ifNotNil: [ data at: #stepNumber ifAbsent: [ nil ] ]
]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> bodyCount [
	| data |
	data := signal physicsData.
	^ data ifNil: [ nil ] ifNotNil: [ data at: #bodyCount ifAbsent: [ nil ] ]
]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> contactCount [
	| data |
	data := signal physicsData.
	^ data ifNil: [ nil ] ifNotNil: [ data at: #contactCount ifAbsent: [ nil ] ]
]

{ #category : 'private - accessing' }
CFPhysicsTelemetrySpanSample >> physicsDataAt: aKey [
	| data |
	data := signal physicsData.
	^ data ifNil: [ nil ] ifNotNil: [ data at: aKey ifAbsent: [ nil ] ]
]


{ #category : 'accessing - pair finder evidence' }
CFPhysicsTelemetrySpanSample >> pairFinderEntryCount [
	^ self physicsDataAt: #pairFinderEntryCount
]

{ #category : 'accessing - pair finder evidence' }
CFPhysicsTelemetrySpanSample >> pairFinderComparisonCount [
	^ self physicsDataAt: #pairFinderComparisonCount
]

{ #category : 'accessing - pair finder evidence' }
CFPhysicsTelemetrySpanSample >> pairFinderAcceptedPairCount [
	^ self physicsDataAt: #pairFinderAcceptedPairCount
]

{ #category : 'accessing - pair finder evidence' }
CFPhysicsTelemetrySpanSample >> pairFinderMaximumActiveCount [
	^ self physicsDataAt: #pairFinderMaximumActiveCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> islandCount [
	^ self physicsDataAt: #islandCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> solvedIslandCount [
	^ self physicsDataAt: #solvedIslandCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> largestSolvedIslandBodyCount [
	^ self physicsDataAt: #largestSolvedIslandBodyCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> largestSolvedIslandDynamicBodyCount [
	^ self physicsDataAt: #largestSolvedIslandDynamicBodyCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> largestSolvedIslandConstraintCount [
	^ self physicsDataAt: #largestSolvedIslandConstraintCount
]

{ #category : 'accessing - solver evidence' }
CFPhysicsTelemetrySpanSample >> solvedIslandConstraintCount [
	^ self physicsDataAt: #solvedIslandConstraintCount
]



{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverContactConstraintCount [ ^ self physicsDataAt: #solverContactConstraintCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverContactPointCount [ ^ self physicsDataAt: #solverContactPointCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverWarmStartedContactPointCount [ ^ self physicsDataAt: #solverWarmStartedContactPointCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverRestitutionCandidatePointCount [ ^ self physicsDataAt: #solverRestitutionCandidatePointCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverJointConstraintCount [ ^ self physicsDataAt: #solverJointConstraintCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverDistanceJointConstraintCount [ ^ self physicsDataAt: #solverDistanceJointConstraintCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverRailJointConstraintCount [ ^ self physicsDataAt: #solverRailJointConstraintCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverRevoluteJointConstraintCount [ ^ self physicsDataAt: #solverRevoluteJointConstraintCount ]
{ #category : 'accessing - solver work evidence' }
CFPhysicsTelemetrySpanSample >> solverFixedJointConstraintCount [ ^ self physicsDataAt: #solverFixedJointConstraintCount ]


{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> preparedContactConstraintCount [ ^ self physicsDataAt: #preparedContactConstraintCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> continuedPreparedContactConstraintCount [ ^ self physicsDataAt: #continuedPreparedContactConstraintCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> beganPreparedContactConstraintCount [ ^ self physicsDataAt: #beganPreparedContactConstraintCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> preparedContactPointCount [ ^ self physicsDataAt: #preparedContactPointCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> reusablePreparedContactPointCount [ ^ self physicsDataAt: #reusablePreparedContactPointCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> newPreparedContactPointCount [ ^ self physicsDataAt: #newPreparedContactPointCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> stablePreparedManifoldCount [ ^ self physicsDataAt: #stablePreparedManifoldCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> changedPreparedManifoldCount [ ^ self physicsDataAt: #changedPreparedManifoldCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> preparedJointConstraintCount [ ^ self physicsDataAt: #preparedJointConstraintCount ]
{ #category : 'accessing - constraint preparation evidence' }
CFPhysicsTelemetrySpanSample >> preparedConstraintObjectCount [ ^ self physicsDataAt: #preparedConstraintObjectCount ]

{ #category : 'accessing' }
CFPhysicsTelemetrySpanSample >> sender [
	^ ping sender
]

{ #category : 'printing' }
CFPhysicsTelemetrySpanSample >> printOn: aStream [
	aStream
		nextPutAll: ping name asString;
		nextPutAll: ' #';
		print: sequence;
		nextPutAll: ' (';
		nextPutAll: (self durationMilliseconds printShowingDecimalPlaces: 3);
		nextPutAll: ' ms)'
]

{ #category : 'gt - views' }
CFPhysicsTelemetrySpanSample >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			'Signal' -> self signal.
			'Ping' -> self ping.
			'Sender' -> self sender.
			'Step' -> self stepNumber.
			'Duration (ms)' -> self durationMilliseconds.
			'Elapsed (ms)' -> (self elapsedDuration / 1000.0).
			'Start (ms)' -> self startMilliseconds.
			'End (ms)' -> self endMilliseconds.
			'Bodies' -> self bodyCount.
			'Contacts' -> self contactCount.
			'Pair finder entries' -> self pairFinderEntryCount.
			'Pair finder comparisons' -> self pairFinderComparisonCount.
			'Pair finder accepted pairs' -> self pairFinderAcceptedPairCount.
			'Pair finder maximum active entries' -> self pairFinderMaximumActiveCount.
			'Islands' -> self islandCount.
			'Solved islands' -> self solvedIslandCount.
			'Largest solved island bodies' -> self largestSolvedIslandBodyCount.
			'Largest solved island dynamic bodies' -> self largestSolvedIslandDynamicBodyCount.
			'Largest solved island constraints' -> self largestSolvedIslandConstraintCount.
			'Solved island constraints' -> self solvedIslandConstraintCount.
			'Solver contact constraints' -> self solverContactConstraintCount.
			'Solver contact points' -> self solverContactPointCount.
			'Warm-started contact points' -> self solverWarmStartedContactPointCount.
			'Restitution candidate points' -> self solverRestitutionCandidatePointCount.
			'Solver joint constraints' -> self solverJointConstraintCount.
			'Distance joint constraints' -> self solverDistanceJointConstraintCount.
			'Rail joint constraints' -> self solverRailJointConstraintCount.
			'Revolute joint constraints' -> self solverRevoluteJointConstraintCount.
			'Fixed joint constraints' -> self solverFixedJointConstraintCount.
			'Prepared contact constraints' -> self preparedContactConstraintCount.
			'Continued prepared contacts' -> self continuedPreparedContactConstraintCount.
			'Began prepared contacts' -> self beganPreparedContactConstraintCount.
			'Prepared contact points' -> self preparedContactPointCount.
			'Reusable prepared contact points' -> self reusablePreparedContactPointCount.
			'New prepared contact points' -> self newPreparedContactPointCount.
			'Stable prepared manifolds' -> self stablePreparedManifoldCount.
			'Changed prepared manifolds' -> self changedPreparedManifoldCount.
			'Prepared joint constraints' -> self preparedJointConstraintCount.
			'Prepared constraint objects' -> self preparedConstraintObjectCount } ];
		column: 'Property' text: #key;
		column: 'Value' text: #value;
		send: #value
]
