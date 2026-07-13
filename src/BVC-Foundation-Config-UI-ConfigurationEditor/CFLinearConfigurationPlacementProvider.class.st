Class {
	#name : 'CFLinearConfigurationPlacementProvider',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor-Placement',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'building' }
CFLinearConfigurationPlacementProvider >> candidatesFor: anAssessment in: anEditor [
	| result |
	result := OrderedCollection new.
	anAssessment targetChoices do: [ :choice |
		| field items |
		field := anEditor fieldElementForPlacement: choice placement.
		field ifNotNil: [
			items := anEditor relationItemsElementIn: field.
			(choice placement isAddition and: [ choice placement description isOrdered and: [ items notNil ] ])
				ifTrue: [ result addAll: (self orderedCandidatesFor: choice items: items in: anEditor) ]
				ifFalse: [
					| bounds |
					bounds := (field bounds inParent: anEditor) asRectangle.
					result add: (CFConfigurationPlacementCandidate
						targetChoice: choice region: (CFConfigurationRectangleRegion rectangle: bounds) insertionIndex: nil axis: nil anchor: bounds center) ] ] ].
	^ result
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> orderedCandidatesFor: aChoice items: itemsElement in: anEditor [
	| children itemBounds containerBounds axis result count |
	children := itemsElement children asArray.
	itemBounds := children collect: [ :each | (each bounds inParent: anEditor) asRectangle ].
	containerBounds := (itemsElement bounds inParent: anEditor) asRectangle.
	axis := self axisFor: itemBounds container: containerBounds.
	result := OrderedCollection new.
	count := children size + 1.
	1 to: count do: [ :index |
		| anchor region |
		anchor := self anchorForIndex: index bounds: itemBounds container: containerBounds axis: axis.
		region := self regionForIndex: index bounds: itemBounds container: containerBounds axis: axis anchor: anchor.
		result add: (CFConfigurationPlacementCandidate
			targetChoice: aChoice region: (CFConfigurationRectangleRegion rectangle: region) insertionIndex: index axis: axis anchor: anchor) ].
	^ result
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> axisFor: boundsCollection container: containerBounds [
	boundsCollection size > 1 ifTrue: [
		| first last |
		first := boundsCollection first center.
		last := boundsCollection last center.
		^ ((last x - first x) abs > (last y - first y) abs) ifTrue: [ #horizontal ] ifFalse: [ #vertical ] ].
	^ containerBounds width > containerBounds height ifTrue: [ #horizontal ] ifFalse: [ #vertical ]
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> anchorForIndex: index bounds: boundsCollection container: containerBounds axis: axis [
	boundsCollection ifEmpty: [ ^ containerBounds center ].
	axis = #horizontal ifTrue: [
		index = 1 ifTrue: [ ^ boundsCollection first left @ boundsCollection first center y ].
		index > boundsCollection size ifTrue: [ ^ boundsCollection last right @ boundsCollection last center y ].
		^ (((boundsCollection at: index - 1) right + (boundsCollection at: index) left) / 2.0)
			@ (((boundsCollection at: index - 1) center y + (boundsCollection at: index) center y) / 2.0) ].
	index = 1 ifTrue: [ ^ boundsCollection first center x @ boundsCollection first top ].
	index > boundsCollection size ifTrue: [ ^ boundsCollection last center x @ boundsCollection last bottom ].
	^ (((boundsCollection at: index - 1) center x + (boundsCollection at: index) center x) / 2.0)
		@ (((boundsCollection at: index - 1) bottom + (boundsCollection at: index) top) / 2.0)
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> regionForIndex: index bounds: boundsCollection container: containerBounds axis: axis anchor: anchor [
	| half |
	half := 14.
	axis = #horizontal
		ifTrue: [ ^ ((anchor x - half) @ containerBounds top corner: (anchor x + half) @ containerBounds bottom) ]
		ifFalse: [ ^ (containerBounds left @ (anchor y - half) corner: containerBounds right @ (anchor y + half)) ]
]
