Class {
	#name : 'CFConfigurationGraphCopier',
	#superclass : 'Object',
	#instVars : [
		'copies'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'copying' }
CFConfigurationGraphCopier >> copy: aConfiguration [
	copies := IdentityDictionary new.
	^ self copyConfiguration: aConfiguration
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyConfiguration: aConfiguration [
	| copy |
	(copies includesKey: aConfiguration) ifTrue: [ ^ copies at: aConfiguration ].
	copy := aConfiguration copy.
	copies at: aConfiguration put: copy.
	self copyDescriptionsFrom: aConfiguration to: copy.
	aConfiguration parent ifNotNil: [ :aParent |
		copy parent: (self copyConfiguration: aParent) ].
	^ copy
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyDescriptionsFrom: aConfiguration to: aCopy [
	aConfiguration magritteDescription do: [ :each |
		each isReadOnly ifFalse: [
			aCopy
				write: (self
					copyValue: (aConfiguration readUsing: each)
					forDescription: each)
				using: each ] ]
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyDetached: aConfiguration [
	^ self copyConfiguration: aConfiguration
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyEditingContext: anEditingMemento [
	"Project the existing Magritte editing values into an independent configuration
	graph. Do not commit, reset, create child contexts, or invoke ownership hooks.
	This is simulation input, not an applicable placement or a transaction."
	self copy: anEditingMemento model.
	self copyEditingValuesFrom: anEditingMemento.
	^ self copyOf: anEditingMemento model
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyEditingValuesFrom: anEditingMemento [
	| configurationCopy |
	configurationCopy := self copyConfiguration: anEditingMemento model.
	anEditingMemento magritteDescription do: [ :description |
		description isReadOnly ifFalse: [
			configurationCopy
				write: (self
					copyValue: (anEditingMemento readUsing: description)
					forDescription: description)
				using: description ] ].
	anEditingMemento allChildMementos do: [ :childMemento |
		self copyEditingValuesFrom: childMemento ].
	"Configuration placement owns its related configurations. Restore those
	links on the projection only, including staged insertions with no live parent.
	Do this after child values, without live ownership hooks or new contexts."
	anEditingMemento magritteDescription do: [ :description |
		(description isReadOnly not and: [ description isKindOf: MARelationDescription ])
			ifTrue: [
				| relatedValue relatedConfigurations |
				relatedValue := configurationCopy readUsing: description.
				relatedConfigurations := description isMultiple
					ifTrue: [ relatedValue ifNil: [ #() ] ]
					ifFalse: [ { relatedValue } ].
				relatedConfigurations do: [ :relatedConfiguration |
					(relatedConfiguration isKindOf: CFConfiguration) ifTrue: [
						relatedConfiguration parent: configurationCopy ] ] ] ]
]

{ #category : 'accessing' }
CFConfigurationGraphCopier >> copyOf: aConfiguration [
	^ copies
		at: aConfiguration
		ifAbsent: [ self error: 'The configuration is not part of this copied graph.' ]
]

{ #category : 'copying' }
CFConfigurationGraphCopier >> copyValue: aValue forDescription: aDescription [
	aValue ifNil: [ ^ nil ].
	(aValue isCollection and: [ aValue isString not ]) ifTrue: [
		^ aValue collect: [ :each |
			self copyValue: each forDescription: aDescription ] ].
	(aValue isKindOf: CFConfiguration)
		ifTrue: [ ^ self copyConfiguration: aValue ].
	^ aValue
]
