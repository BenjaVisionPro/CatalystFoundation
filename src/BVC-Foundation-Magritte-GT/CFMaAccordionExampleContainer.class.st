Class {
	#name : 'CFMaAccordionExampleContainer',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'items'
	],
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'magritte' }
CFMaAccordionExampleContainer >> descriptionItems [
	<magritteDescription>
	| aReferenceModel |
	aReferenceModel := CFMagritteEditorExample new.
	^ CFToManyRelationDescription new
		accessor: #items;
		label: 'Items';
		classes: { CFMagritteEditorExample };
		reference: aReferenceModel iconDescription , aReferenceModel labelDescription;
		beOrdered;
		beModifiable;
		newItemStencil: [ :aClass | aClass new ];
		beAccordionList;
		yourself
]

{ #category : 'initialization' }
CFMaAccordionExampleContainer >> initialize [
	super initialize.
	self label: 'Accordion example'.
	items := OrderedCollection
		with: (CFMagritteEditorExample exampleDefault
			label: 'First item';
			yourself)
		with: (CFMagritteEditorExample exampleArchived
			label: 'Second item';
			yourself)
]

{ #category : 'accessing' }
CFMaAccordionExampleContainer >> items [
	^ items
]

{ #category : 'accessing' }
CFMaAccordionExampleContainer >> items: aCollection [
	items := aCollection asOrderedCollection
]
