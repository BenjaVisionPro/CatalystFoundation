Class {
	#name : 'CFConfigurationRectangleRegion',
	#superclass : 'Object',
	#instVars : [ 'rectangle' ],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor-Placement',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'instance creation' }
CFConfigurationRectangleRegion class >> rectangle: aRectangle [
	^ self new rectangle: aRectangle; yourself
]

{ #category : 'geometry' }
CFConfigurationRectangleRegion >> containsPoint: aPoint [
	^ rectangle containsPoint: aPoint
]

{ #category : 'geometry' }
CFConfigurationRectangleRegion >> distanceTo: aPoint [
	| dx dy |
	dx := aPoint x < rectangle left
		ifTrue: [ rectangle left - aPoint x ]
		ifFalse: [ aPoint x > rectangle right ifTrue: [ aPoint x - rectangle right ] ifFalse: [ 0 ] ].
	dy := aPoint y < rectangle top
		ifTrue: [ rectangle top - aPoint y ]
		ifFalse: [ aPoint y > rectangle bottom ifTrue: [ aPoint y - rectangle bottom ] ifFalse: [ 0 ] ].
	^ (dx squared + dy squared) sqrt
]

{ #category : 'geometry' }
CFConfigurationRectangleRegion >> expandedBy: aNumber [
	^ self class rectangle: (rectangle expandBy: aNumber)
]

{ #category : 'accessing' }
CFConfigurationRectangleRegion >> rectangle [ ^ rectangle ]

{ #category : 'accessing' }
CFConfigurationRectangleRegion >> rectangle: aRectangle [ rectangle := aRectangle ]
