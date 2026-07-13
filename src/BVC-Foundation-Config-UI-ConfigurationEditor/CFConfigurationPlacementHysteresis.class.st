Class {
	#name : 'CFConfigurationPlacementHysteresis',
	#superclass : 'Object',
	#instVars : [ 'retentionMargin', 'minimumAdvantage', 'relativeAdvantage' ],
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor-Placement',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'initialization' }
CFConfigurationPlacementHysteresis >> initialize [
	super initialize.
	retentionMargin := 10.
	minimumAdvantage := 8.
	relativeAdvantage := 0.85
]

{ #category : 'choosing' }
CFConfigurationPlacementHysteresis >> chooseFrom: candidates at: aPoint keeping: activeCandidate [
	| closest retained closestDistance retainedDistance |
	candidates ifEmpty: [ ^ nil ].
	closest := candidates inject: candidates first into: [ :best :each |
		(each distanceTo: aPoint) < (best distanceTo: aPoint) ifTrue: [ each ] ifFalse: [ best ] ].
	activeCandidate ifNil: [ ^ closest ].
	retained := candidates detect: [ :each | each samePlacementAs: activeCandidate ] ifNone: [ nil ].
	retained ifNil: [ ^ closest ].
	((retained region expandedBy: retentionMargin) containsPoint: aPoint) ifTrue: [ ^ retained ].
	closest == retained ifTrue: [ ^ retained ].
	closestDistance := closest distanceTo: aPoint.
	retainedDistance := retained distanceTo: aPoint.
	((closestDistance + minimumAdvantage < retainedDistance)
		and: [ closestDistance < (retainedDistance * relativeAdvantage) ]) ifTrue: [ ^ closest ].
	^ retained
]
