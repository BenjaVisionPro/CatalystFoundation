Class {
	#name : 'CFMotionTraceEntry',
	#superclass : 'Object',
	#instVars : [ 'kind', 'operation', 'track', 'timestamp' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionTraceEntry class >> kind: aSymbol operation: anOperation track: aTrack [
	^ self new
		kind: aSymbol;
		operation: anOperation;
		track: aTrack;
		timestamp: DateAndTime now;
		yourself
]

{ #category : 'accessing' }
CFMotionTraceEntry >> kind [ ^ kind ]

{ #category : 'accessing' }
CFMotionTraceEntry >> kind: aSymbol [ kind := aSymbol ]

{ #category : 'accessing' }
CFMotionTraceEntry >> operation [ ^ operation ]

{ #category : 'accessing' }
CFMotionTraceEntry >> operation: anOperation [ operation := anOperation ]

{ #category : 'accessing' }
CFMotionTraceEntry >> timestamp [ ^ timestamp ]

{ #category : 'accessing' }
CFMotionTraceEntry >> timestamp: aTimestamp [ timestamp := aTimestamp ]

{ #category : 'accessing' }
CFMotionTraceEntry >> track [ ^ track ]

{ #category : 'accessing' }
CFMotionTraceEntry >> track: aTrack [ track := aTrack ]
