Class {
	#name : 'CFConfigurationPlacementCandidate',
	#superclass : 'Object',
	#instVars : [
		'targetChoice',
		'region',
		'insertionIndex',
		'axis'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor-Placement',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'instance creation' }
CFConfigurationPlacementCandidate class >> targetChoice: aTargetChoice region: aRegion insertionIndex: anIndex axis: aSymbol [
	^ self new
		targetChoice: aTargetChoice;
		region: aRegion;
		insertionIndex: anIndex;
		axis: aSymbol;
		yourself
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> axis [
	^ axis
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> axis: aSymbol [
	axis := aSymbol
]

{ #category : 'geometry' }
CFConfigurationPlacementCandidate >> distanceTo: aPoint [
	^ region distanceTo: aPoint
]

{ #category : 'testing' }
CFConfigurationPlacementCandidate >> includesPoint: aPoint [
	^ region containsPoint: aPoint
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> insertionIndex [
	^ insertionIndex
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> insertionIndex: anIndex [
	insertionIndex := anIndex
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> region [
	^ region
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> region: aRegion [
	region := aRegion
]

{ #category : 'testing' }
CFConfigurationPlacementCandidate >> samePlacementAs: anotherCandidate [
	anotherCandidate ifNil: [ ^ false ].
	^ (targetChoice placement matches: anotherCandidate targetChoice placement)
		and: [ insertionIndex = anotherCandidate insertionIndex ]
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> targetChoice [
	^ targetChoice
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> targetChoice: aTargetChoice [
	targetChoice := aTargetChoice
]
