"I interpolate the Detail switch thumb's absolute horizontal offset.

The switch aptitude owns the thumb's presentation semantics. Motion owns time,
retargeting and property ownership; this Behaviour does not contribute a
composable Bloc transform."
Class {
	#name : 'CFMaDetailSwitchThumbMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'aptitude',
		'thumb',
		'originOffset',
		'startOffset',
		'targetOffset',
		'entryOffset'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailSwitchThumbMotionBehaviour class >> on: aThumb aptitude: anAptitude target: anOffset [
	^ self new
		thumb: aThumb;
		aptitude: anAptitude;
		targetOffset: anOffset;
		yourself
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> animationTarget [
	^ thumb
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> aptitude: anAptitude [
	aptitude := anAptitude
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> applyDestination [
	aptitude applyThumbOffset: targetOffset
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> applyProgress: aProgress [
	aptitude applyThumbOffset:
		startOffset + ((targetOffset - startOffset) * aProgress)
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> captureOrigin [
	originOffset ifNil: [ originOffset := aptitude thumbOffset ]
]

{ #category : 'testing' }
CFMaDetailSwitchThumbMotionBehaviour >> isAtDestination [
	^ startOffset = targetOffset
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> prepareFromCurrentPresentation [
	entryOffset := startOffset := aptitude thumbOffset
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> prepareForTimelineCycle: aCycleIndex [
	startOffset := aCycleIndex isZero
		ifTrue: [ entryOffset ]
		ifFalse: [ originOffset ].
	aCycleIndex isZero ifFalse: [ self restoreOrigin ]
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: thumb
		property: self class
]

{ #category : 'playing' }
CFMaDetailSwitchThumbMotionBehaviour >> restoreOrigin [
	originOffset ifNotNil: [ aptitude applyThumbOffset: originOffset ]
]

{ #category : 'controlling' }
CFMaDetailSwitchThumbMotionBehaviour >> reversed [
	^ self class
		on: thumb
		aptitude: aptitude
		target: originOffset
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> targetValue [
	^ targetOffset
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> targetValue: anOffset [
	targetOffset := anOffset
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> targetOffset: anOffset [
	targetOffset := anOffset
]

{ #category : 'accessing' }
CFMaDetailSwitchThumbMotionBehaviour >> thumb: aThumb [
	thumb := aThumb
]
