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
						targetChoice: choice
						region: (CFConfigurationRectangleRegion rectangle: bounds)
						insertionIndex: nil
						axis: nil) ] ] ].
	^ result
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> orderedCandidatesFor: aChoice items: itemsElement in: anEditor [
	| children itemBounds containerBounds axis result |
	children := itemsElement children asArray select: [ :each |
		(each userData at: #cfConfigurationEditorPlacementPreview ifAbsent: [ false ]) not ].
	itemBounds := children collect: [ :each | (each bounds inParent: anEditor) asRectangle ].
	containerBounds := (itemsElement bounds inParent: anEditor) asRectangle.
	axis := self axisOf: itemsElement.
	result := OrderedCollection new.
	1 to: children size + 1 do: [ :index |
		| anchor region |
		anchor := self
			anchorForIndex: index
			bounds: itemBounds
			container: containerBounds
			axis: axis.
		region := itemBounds
			ifEmpty: [ containerBounds ]
			ifNotEmpty: [ self regionAt: anchor in: containerBounds axis: axis ].
		result add: (CFConfigurationPlacementCandidate
			targetChoice: aChoice
			region: (CFConfigurationRectangleRegion rectangle: region)
			insertionIndex: index
			axis: axis) ].
	^ result
]

{ #category : 'private' }
CFLinearConfigurationPlacementProvider >> axisOf: itemsElement [
	^ itemsElement layout orientation isHorizontal
		ifTrue: [ #horizontal ]
		ifFalse: [ #vertical ]
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
CFLinearConfigurationPlacementProvider >> regionAt: anchor in: containerBounds axis: axis [
	^ axis = #horizontal
		ifTrue: [ anchor x @ containerBounds top corner: anchor x @ containerBounds bottom ]
		ifFalse: [ containerBounds left @ anchor y corner: containerBounds right @ anchor y ]
]
