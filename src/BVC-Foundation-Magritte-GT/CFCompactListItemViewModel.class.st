Class {
	#name : 'CFCompactListItemViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'itemDescription'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'converting' }
CFCompactListItemViewModel >> asElement [
	^ CFCompactListItemElement
		model: self object
		description: self itemDescription
]

{ #category : 'accessing' }
CFCompactListItemViewModel >> itemDescription [
	^ itemDescription
]

{ #category : 'accessing' }
CFCompactListItemViewModel >> itemDescription: aDescription [
	itemDescription := aDescription
]
