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
CFMaDetailRelationContext >> selectionAnchor: anElement [
	selectionAnchor := anElement
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> clearSelectionAnchor [
	selectionAnchor := nil
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectableRows [
	^ selectableRows
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> selectableRows: theRows [
	selectableRows := theRows copy
]

{ #category : 'accessing' }
CFMaDetailRelationContext >> objectsByRows [
	^ objectsByRows
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

{ #category : 'accessing' }
CFMaDetailRelationContext >> active: aBoolean [
	active := aBoolean
]
