"I provide a compact direct-entry control for one live Behaviour description."
Class {
	#name : 'CFPhysicsBehaviourValueControl',
	#superclass : 'Object',
	#instVars : [ 'behaviour', 'description', 'element', 'editor', 'updating' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBehaviourValueControl class >> on: aBehaviour description: aDescription [
	^ self new behaviour: aBehaviour; description: aDescription; initializeControl; yourself
]

{ #category : 'private - initialization' }
CFPhysicsBehaviourValueControl >> behaviour: anObject [ behaviour := anObject ]
{ #category : 'private - initialization' }
CFPhysicsBehaviourValueControl >> description: anObject [ description := anObject ]
{ #category : 'accessing' }
CFPhysicsBehaviourValueControl >> element [ ^ element ]

{ #category : 'initialization' }
CFPhysicsBehaviourValueControl >> initializeControl [
	updating := false.
	editor := BrEditor new
		hExact: 158;
		vExact: 18;
		inputFilter: BrTextEditorNoLineBreakInputFilter new;
		aptitude: BrGlamorousRegularEditorAptitude new;
		padding: (BlInsets top: 1 left: 4 bottom: 1 right: 4);
		yourself.
	editor editor when: BrTextEditorModifiedEvent do: [ :event | self editorModified ].
	element := editor.
	self refresh
]

{ #category : 'private - editing' }
CFPhysicsBehaviourValueControl >> editorModified [
	updating ifTrue: [ ^ self ].
	[ description writeFromString: editor text asString to: behaviour ] on: Error do: [ :error | ].
	^ self
]

{ #category : 'updating' }
CFPhysicsBehaviourValueControl >> refresh [
	| string |
	behaviour ifNil: [ ^ self ].
	string := (description read: behaviour) printString.
	editor text asString = string ifFalse: [
		updating := true.
		editor text: string.
		updating := false ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsBehaviourValueControl >> release [ ^ self ]
