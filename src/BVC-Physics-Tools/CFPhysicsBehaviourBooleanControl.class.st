"I present one Boolean Behaviour configuration value as a compact live checkbox."
Class {
	#name : 'CFPhysicsBehaviourBooleanControl',
	#superclass : 'Object',
	#instVars : [ 'behaviour', 'description', 'element', 'updating' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBehaviourBooleanControl class >> on: aBehaviour description: aDescription [
	^ self new behaviour: aBehaviour; description: aDescription; initializeControl; yourself
]

{ #category : 'private - initialization' }
CFPhysicsBehaviourBooleanControl >> behaviour: anObject [ behaviour := anObject ]
{ #category : 'private - initialization' }
CFPhysicsBehaviourBooleanControl >> description: anObject [ description := anObject ]
{ #category : 'accessing' }
CFPhysicsBehaviourBooleanControl >> element [ ^ element ]

{ #category : 'initialization' }
CFPhysicsBehaviourBooleanControl >> initializeControl [
	updating := false.
	element := BrCheckbox new
		aptitude: BrGlamorousCheckboxAptitude;
		yourself.
	element whenCheckedDo: [ self write: true ].
	element whenUncheckedDo: [ self write: false ].
	self refresh
]

{ #category : 'private - editing' }
CFPhysicsBehaviourBooleanControl >> write: aBoolean [
	updating ifTrue: [ ^ self ].
	description write: aBoolean to: behaviour.
	^ self
]

{ #category : 'updating' }
CFPhysicsBehaviourBooleanControl >> refresh [
	| value |
	behaviour ifNil: [ ^ self ].
	value := description read: behaviour.
	element isChecked = value ifFalse: [
		updating := true.
		element checked: value.
		updating := false ].
	^ self
]

{ #category : 'controlling' }
CFPhysicsBehaviourBooleanControl >> release [ ^ self ]
