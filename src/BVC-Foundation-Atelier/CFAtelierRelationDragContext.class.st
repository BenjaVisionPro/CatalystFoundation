"I identify the Magritte editing context from which an existing relation object is being dragged.

I carry only the source memento and relation description. The dragged object itself remains the BlDragItem domain object. Atelier installs me on relation item rows; this lets a destination relation distinguish an existing-object move from a palette insertion without changing Foundation's drag item protocol."
Class {
	#name : 'CFAtelierRelationDragContext',
	#superclass : 'Object',
	#instVars : [ 'memento', 'description' ],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'instance creation' }
CFAtelierRelationDragContext class >> memento: aMemento description: aDescription [
	^ self new memento: aMemento; description: aDescription; yourself
]

{ #category : 'accessing' }
CFAtelierRelationDragContext >> memento [ ^ memento ]
{ #category : 'accessing' }
CFAtelierRelationDragContext >> memento: aMemento [ memento := aMemento ]
{ #category : 'accessing' }
CFAtelierRelationDragContext >> description [ ^ description ]
{ #category : 'accessing' }
CFAtelierRelationDragContext >> description: aDescription [ description := aDescription ]
