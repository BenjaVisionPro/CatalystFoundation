Class {
	#name : 'CFMaDetailRelationContext',
	#superclass : 'Object',
	#instVars : [
		'selectedElements',
		'selectionAnchor',
		'selectableRows',
		'objectsByRows',
		'focusRows',
		'focusContainer',
		'active'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'initialization' }
CFMaDetailRelationContext >> initialize [
	super initialize.
	selectedElements := IdentitySet new.
	selectableRows := #().
	objectsByRows := IdentityDictionary new.
	focusRows := #().
	active := false
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectedElements [
	^ selectedElements
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectedElements: theElements [
	selectedElements := theElements
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectionAnchor [
	^ selectionAnchor
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectableRows [
	^ selectableRows
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> focusRows [
	^ focusRows
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> focusRows: theRows [
	focusRows := theRows copy
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> focusContainer [
	^ focusContainer
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> focusContainer: anElement [
	focusContainer := anElement
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> isActive [
	^ active
]

{ #category : 'state' }
CFMaDetailRelationContext >> setActive: aBoolean [
	active = aBoolean ifTrue: [ ^ false ].
	active := aBoolean.
	^ true
]

{ #category : 'selection' }
CFMaDetailRelationContext >> isSelected: anElement [
	^ selectedElements identityIncludes: anElement
]

{ #category : 'selection' }
CFMaDetailRelationContext >> selectionWithOnly: anElement [
	selectionAnchor := anElement.
	^ IdentitySet new
		add: anElement;
		yourself
]

{ #category : 'selection' }
CFMaDetailRelationContext >> selectionToggling: anElement [
	| newSelection |
	newSelection := selectedElements copy.
	(self isSelected: anElement)
		ifTrue: [ newSelection remove: anElement ]
		ifFalse: [ newSelection add: anElement ].
	^ newSelection
]

{ #category : 'selection' }
CFMaDetailRelationContext >> selectionRangeTo: anElement [
	| anchorIndex elementIndex firstIndex lastIndex |
	selectionAnchor ifNil: [ ^ self selectionWithOnly: anElement ].
	anchorIndex := selectableRows identityIndexOf: selectionAnchor ifAbsent: [ 0 ].
	elementIndex := selectableRows identityIndexOf: anElement ifAbsent: [ 0 ].
	(anchorIndex = 0 or: [ elementIndex = 0 ]) ifTrue: [
		^ self selectionWithOnly: anElement ].
	firstIndex := anchorIndex min: elementIndex.
	lastIndex := anchorIndex max: elementIndex.
	^ IdentitySet new
		addAll: (selectableRows copyFrom: firstIndex to: lastIndex);
		yourself
]

{ #category : 'selection' }
CFMaDetailRelationContext >> selectionRetainedForSelectableRows: theRows [
	selectableRows := theRows copy.
	(selectionAnchor notNil and: [ (selectableRows identityIncludes: selectionAnchor) not ]) ifTrue: [
		selectionAnchor := nil ].
	^ selectedElements select: [ :anElement |
		selectableRows identityIncludes: anElement ]
]

{ #category : 'selection' }
CFMaDetailRelationContext >> orderedSelectedRows [
	^ selectableRows select: [ :aRow | self isSelected: aRow ]
]

{ #category : 'selection' }
CFMaDetailRelationContext >> dragRowsFrom: aRow [
	(self isSelected: aRow) ifFalse: [ ^ { aRow } ].
	^ self orderedSelectedRows
]

{ #category : 'mapping' }
CFMaDetailRelationContext >> objectAtRow: aRow [
	^ objectsByRows at: aRow
]

{ #category : 'mapping' }
CFMaDetailRelationContext >> objectAtRow: aRow ifAbsent: aBlock [
	^ objectsByRows at: aRow ifAbsent: aBlock
]

{ #category : 'mapping' }
CFMaDetailRelationContext >> object: anObject atRow: aRow [
	objectsByRows at: aRow put: anObject
]

{ #category : 'mapping' }
CFMaDetailRelationContext >> removeObjectAtRow: aRow [
	objectsByRows removeKey: aRow ifAbsent: [ ]
]

{ #category : 'mapping' }
CFMaDetailRelationContext >> selectedObjects [
	^ self orderedSelectedRows collect: [ :aRow | self objectAtRow: aRow ]
]

{ #category : 'testing' }
CFMaDetailRelationContext >> includesSelectableRow: aRow [
	^ selectableRows identityIncludes: aRow
]

