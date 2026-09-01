"I select Foundation's embedded-form representation for a relation. The relation cardinality remains owned by Magritte; I only select how related objects are presented."

Class {
	#name : 'CFMaEmbeddedFormsConfiguration',
	#superclass : 'CFMaFieldRepresentationConfiguration',
	#instVars : [
		'relationRowVisible',
		'presentationConfiguration'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaEmbeddedFormsConfiguration >> initialize [
	super initialize.
	relationRowVisible := true.
	presentationConfiguration := [ :aPresentation | aPresentation ]
]

{ #category : 'configuration - relation row' }
CFMaEmbeddedFormsConfiguration >> hideRelationRow [
	relationRowVisible := false
]

{ #category : 'accessing' }
CFMaEmbeddedFormsConfiguration >> relationRowVisible [
	^ relationRowVisible
]

{ #category : 'configuration - relation row' }
CFMaEmbeddedFormsConfiguration >> showRelationRow [
	relationRowVisible := true
]

{ #category : 'configuration - presentation' }
CFMaEmbeddedFormsConfiguration >> configurePresentation: aBlock [
	presentationConfiguration := aBlock
]

{ #category : 'accessing' }
CFMaEmbeddedFormsConfiguration >> presentationConfiguration [
	^ presentationConfiguration
]
