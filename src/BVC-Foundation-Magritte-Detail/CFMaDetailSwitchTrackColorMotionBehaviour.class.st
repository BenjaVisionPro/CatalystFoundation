"I interpolate the Detail switch track colour as one Motion presentation responsibility."

Class {
	#name : 'CFMaDetailSwitchTrackColorMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'aptitude',
		'widget',
		'originColor',
		'startColor',
		'targetColor',
		'entryColor'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailSwitchTrackColorMotionBehaviour class >> on: aWidget aptitude: anAptitude target: aColor [
	^ self new
		widget: aWidget;
		aptitude: anAptitude;
		targetColor: aColor;
		yourself
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> animationTarget [
	^ widget
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> aptitude: anAptitude [
	aptitude := anAptitude
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> applyDestination [
	aptitude applyTrackColor: targetColor
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> applyProgress: aProgress [
	aptitude applyTrackColor: (Color
		r: startColor red + ((targetColor red - startColor red) * aProgress)
		g: startColor green + ((targetColor green - startColor green) * aProgress)
		b: startColor blue + ((targetColor blue - startColor blue) * aProgress)
		alpha: startColor alpha + ((targetColor alpha - startColor alpha) * aProgress))
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> captureOrigin [
	originColor ifNil: [ originColor := aptitude trackColor ]
]

{ #category : 'testing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> isAtDestination [
	^ startColor = targetColor
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> prepareFromCurrentPresentation [
	entryColor := startColor := aptitude trackColor
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> prepareForTimelineCycle: aCycleIndex [
	startColor := aCycleIndex isZero
		ifTrue: [ entryColor ]
		ifFalse: [ originColor ].
	aCycleIndex isZero ifFalse: [ self restoreOrigin ]
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: widget
		property: self class
]

{ #category : 'playing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> restoreOrigin [
	originColor ifNotNil: [ aptitude applyTrackColor: originColor ]
]

{ #category : 'controlling' }
CFMaDetailSwitchTrackColorMotionBehaviour >> reversed [
	^ self class
		on: widget
		aptitude: aptitude
		target: originColor
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> targetValue [
	^ targetColor
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> targetValue: aColor [
	targetColor := aColor
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> targetColor: aColor [
	targetColor := aColor
]

{ #category : 'accessing' }
CFMaDetailSwitchTrackColorMotionBehaviour >> widget: aWidget [
	widget := aWidget
]
