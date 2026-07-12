Class {
	#name : 'CFConfigurationCodec',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-Serialization',
	#package : 'BVC-Foundation-Config-Serialization'
}

{ #category : 'decoding' }
CFConfigurationCodec class >> decodeObject: aDictionary [
	| configurationClass configuration descriptionsByKey allowedKeys |
	configurationClass := aDictionary
		at: #class
		ifAbsent: [ self error: 'Encoded configuration is missing #class.' ].
	configuration := (Smalltalk
		at: configurationClass
		ifAbsent: [ self error: 'Unknown configuration class ' , configurationClass printString , '.' ]) new.
	(configuration isKindOf: CFConfiguration)
		ifFalse: [ self error: 'Encoded object is not a CFConfiguration.' ].
	descriptionsByKey := Dictionary new.
	(self serializableDescriptionsFor: configuration) do: [ :each |
		descriptionsByKey at: each accessor readSelector put: each ].
	allowedKeys := descriptionsByKey keys asSet copyWith: #class.
	(aDictionary keys anySatisfy: [ :each | (allowedKeys includes: each) not ])
		ifTrue: [ self error: 'Encoded configuration contains unknown keys.' ].
	descriptionsByKey keysAndValuesDo: [ :key :description |
		(aDictionary includesKey: key) ifTrue: [
			configuration
				write: (self decodeValue: (aDictionary at: key))
				using: description ] ].
	^ configuration
]

{ #category : 'decoding' }
CFConfigurationCodec class >> decodeValue: aValue [
	(aValue isDictionary and: [ aValue includesKey: #class ])
		ifTrue: [ ^ self decodeObject: aValue ].
	(aValue isDictionary and: [ (aValue at: #kind ifAbsent: [ nil ]) = #classReference ])
		ifTrue: [
			^ Smalltalk
				at: (aValue at: #name)
				ifAbsent: [ self error: 'Unknown class reference.' ] ].
	(aValue isDictionary and: [ (aValue at: #kind ifAbsent: [ nil ]) = #stonLiteral ])
		ifTrue: [ ^ STON fromString: (aValue at: #value) ].
	(aValue isCollection and: [ aValue isString not ])
		ifTrue: [ ^ aValue collect: [ :each | self decodeValue: each ] ].
	^ aValue
]

{ #category : 'encoding' }
CFConfigurationCodec class >> encodeObject: aConfiguration [
	| representation |
	representation := self newOrderedMap.
	representation at: #class put: aConfiguration class name asSymbol.
	(self serializableDescriptionsFor: aConfiguration) do: [ :each |
		representation
			at: each accessor readSelector
			put: (self encodeValue: (aConfiguration readUsing: each)) ].
	^ representation
]

{ #category : 'encoding' }
CFConfigurationCodec class >> encodeValue: aValue [
	aValue ifNil: [ ^ nil ].
	aValue isClass ifTrue: [
		^ self newOrderedMap
			at: #kind put: #classReference;
			at: #name put: aValue name asSymbol;
			yourself ].
	(aValue isString or: [ aValue isSymbol or: [ aValue isNumber or: [ aValue isBoolean ] ] ])
		ifTrue: [ ^ aValue ].
	(aValue isCollection and: [ aValue isString not ])
		ifTrue: [ ^ aValue collect: [ :each | self encodeValue: each ] ].
	(aValue isKindOf: CFConfiguration)
		ifTrue: [ ^ self encodeObject: aValue ].
	^ self newOrderedMap
		at: #kind put: #stonLiteral;
		at: #value put: (STON toString: aValue);
		yourself
]

{ #category : 'decoding' }
CFConfigurationCodec class >> fromRepresentation: aRepresentation [
	| configuration |
	(aRepresentation isDictionary)
		ifFalse: [ self error: 'Configuration payload must be a Dictionary.' ].
	(aRepresentation at: #schemaTag ifAbsent: [ nil ]) = self schemaTag
		ifFalse: [ self error: 'Unsupported configuration schema tag.' ].
	(aRepresentation at: #schemaVersion ifAbsent: [ nil ]) = self schemaVersion
		ifFalse: [ self error: 'Unsupported configuration schema version.' ].
	configuration := self decodeValue: (aRepresentation
		at: #configuration
		ifAbsent: [ self error: 'Configuration payload is missing #configuration.' ]).
	(configuration isKindOf: CFConfiguration)
		ifFalse: [ self error: 'Configuration payload did not decode to a CFConfiguration.' ].
	^ configuration
]

{ #category : 'decoding' }
CFConfigurationCodec class >> fromString: aString [
	^ self fromRepresentation: (STON fromString: aString)
]

{ #category : 'private' }
CFConfigurationCodec class >> newOrderedMap [
	^ (Smalltalk at: #OrderedDictionary ifAbsent: [ Dictionary ]) new
]

{ #category : 'encoding' }
CFConfigurationCodec class >> representationFor: aConfiguration [
	(aConfiguration isKindOf: CFConfiguration)
		ifFalse: [ self error: 'A CFConfiguration is required.' ].
	^ self newOrderedMap
		at: #schemaTag put: self schemaTag;
		at: #schemaVersion put: self schemaVersion;
		at: #configuration put: (self encodeObject: aConfiguration);
		yourself
]

{ #category : 'schema' }
CFConfigurationCodec class >> schemaTag [
	^ #cfConfiguration
]

{ #category : 'schema' }
CFConfigurationCodec class >> schemaVersion [
	^ 1
]

{ #category : 'private' }
CFConfigurationCodec class >> serializableDescriptionsFor: aConfiguration [
	^ aConfiguration magritteDescription select: #cfSerializable
]

{ #category : 'encoding' }
CFConfigurationCodec class >> toStringPretty: aConfiguration [
	^ STON toStringPretty: (self representationFor: aConfiguration)
]
