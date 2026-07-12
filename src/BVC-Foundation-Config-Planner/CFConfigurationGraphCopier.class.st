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

{ #category : 'accessing' }
CFConfigurationGraphCopier >> copyOf: aConfiguration [
	^ copies
		at: aConfiguration
		ifAbsent: [ self error: 'The configuration is not part of this copied graph.' ]
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
CFConfigurationGraphCopier >> copyValue: aValue forDescription: aDescription [
	aValue ifNil: [ ^ nil ].
	(aValue isCollection and: [ aValue isString not ]) ifTrue: [
		^ aValue collect: [ :each |
			self copyValue: each forDescription: aDescription ] ].
	((aDescription isKindOf: MARelationDescription) and: [
		aDescription cfConfigurationEmbedded and: [ aValue isKindOf: CFConfiguration ] ])
		ifTrue: [ ^ self copyConfiguration: aValue ].
	^ aValue
]
