Class {
	#name : 'CFMaToOneRelationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaToOneRelationExamples >> embeddedFormRepresentation [
	<gtExample>
	| aDescription |
	aDescription := MAToOneRelationDescription new
		classes: { CFMagritteEditorExample };
		beEmbeddedForm;
		yourself.

	self assert: aDescription blocStencil class equals: CFMaToOneEmbeddedFormStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToOneRelationExamples >> phlowLinkRepresentation [
	<gtExample>
	| aDescription |
	aDescription := MAToOneRelationDescription new
		classes: { CFMagritteEditorExample };
		bePhlowLink;
		yourself.

	self assert: aDescription blocStencil class equals: CFMaToOnePhlowLinkStencilBuilder.
	^ aDescription
]

{ #category : 'examples' }
CFMaToOneRelationExamples >> requiredRelationCannotRemoveCurrentObject [
	<gtExample>
	| aDescription anObject |
	anObject := CFMagritteEditorExample exampleDefault.
	aDescription := MAToOneRelationDescription new
		classes: { CFMagritteEditorExample };
		beRequired;
		yourself.

	self deny: (CFMaBuilderUtility
		canRemoveToOneUsing: aDescription
		currentValue: anObject).
	^ aDescription
]

{ #category : 'examples' }
CFMaToOneRelationExamples >> optionalRelationCanRemoveCurrentObject [
	<gtExample>
	| aDescription anObject |
	anObject := CFMagritteEditorExample exampleDefault.
	aDescription := MAToOneRelationDescription new
		classes: { CFMagritteEditorExample };
		beOptional;
		yourself.

	self assert: (CFMaBuilderUtility
		canRemoveToOneUsing: aDescription
		currentValue: anObject).
	^ aDescription
]

{ #category : 'examples' }
CFMaToOneRelationExamples >> readOnlyRelationCannotRemoveCurrentObject [
	<gtExample>
	| aDescription anObject |
	anObject := CFMagritteEditorExample exampleDefault.
	aDescription := MAToOneRelationDescription new
		classes: { CFMagritteEditorExample };
		beReadOnly;
		yourself.

	self deny: (CFMaBuilderUtility
		canRemoveToOneUsing: aDescription
		currentValue: anObject).
	^ aDescription
]
