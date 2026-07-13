Class {
	#name : 'CFConfigurationPlacementCandidate',
	#superclass : 'Object',
	#instVars : [
		'targetChoice',
		'region',
		'insertionIndex',
		'axis',
		'anchor'
	],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor-Placement',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'instance creation' }
CFConfigurationPlacementCandidate class >> targetChoice: aTargetChoice region: aRectangle insertionIndex: anIndex axis: aSymbol anchor: aPoint [
	^ self new targetChoice: aTargetChoice; region: aRectangle; insertionIndex: anIndex; axis: aSymbol; anchor: aPoint; yourself
]

{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> anchor [ ^ anchor ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> anchor: aPoint [ anchor := aPoint ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> axis [ ^ axis ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> axis: aSymbol [ axis := aSymbol ]
{ #category : 'geometry' }
CFConfigurationPlacementCandidate >> distanceTo: aPoint [ ^ region distanceTo: aPoint ]

{ #category : 'testing' }
CFConfigurationPlacementCandidate >> includesPoint: aPoint [ ^ region containsPoint: aPoint ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> insertionIndex [ ^ insertionIndex ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> insertionIndex: anIndex [ insertionIndex := anIndex ]
{ #category : 'geometry' }
CFConfigurationPlacementCandidate >> previewOriginForExtent: anExtent [
	axis = #horizontal ifTrue: [ ^ anchor x @ (anchor y - (anExtent y / 2.0)) ].
	axis = #vertical ifTrue: [ ^ (anchor x - (anExtent x / 2.0)) @ anchor y ].
	^ anchor - (anExtent / 2.0)
]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> region [ ^ region ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> region: aRectangle [ region := aRectangle ]
{ #category : 'testing' }
CFConfigurationPlacementCandidate >> samePlacementAs: anotherCandidate [
	anotherCandidate ifNil: [ ^ false ].
	^ (targetChoice placement matches: anotherCandidate targetChoice placement)
		and: [ insertionIndex = anotherCandidate insertionIndex ]
]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> targetChoice [ ^ targetChoice ]
{ #category : 'accessing' }
CFConfigurationPlacementCandidate >> targetChoice: aTargetChoice [ targetChoice := aTargetChoice ]
