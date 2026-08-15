"I provide one object whose Magritte descriptions expose the Foundation form and relation representations used during UI development."

Class {
	#name : 'CFMaFormShowcase',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'summary',
		'enabled',
		'priority',
		'status',
		'embeddedObject',
		'phlowObject',
		'compactObject',
		'columnedObject',
		'compactItems',
		'expandableItems',
		'accordionItems',
		'gridItems',
		'embeddedItems',
		'gridEmbeddedItems',
		'phlowItems',
		'gridPhlowItems'
	],
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaFormShowcase class >> example [
	<gtExample>
	^ self new
]

{ #category : 'examples' }
CFMaFormShowcase class >> exampleElement [
	<gtExample>
	^ self example asElement
]


{ #category : 'converting' }
CFMaFormShowcase >> asGtMagritteViewModel [
	^ (CFMaViewModel forObject: self)
		beAccordionGroups;
		yourself
]

{ #category : 'converting' }
CFMaFormShowcase >> asElement [
	^ self asGtMagritteViewModel asElement
]

{ #category : 'initialization' }
CFMaFormShowcase >> initialize [
	| alpha beta gamma |
	super initialize.
	self label: 'Foundation Magritte showcase'.
	summary := 'One deliberately busy object for evaluating Foundation form spacing, hierarchy, controls, validation and relation representations.'.
	enabled := true.
	priority := 60.
	status := #active.

	alpha := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 30 status: #active.
	beta := CFMaFormShowcaseAccentItem exampleNamed: 'Beta' score: 60 status: #draft.
	gamma := CFMaFormShowcaseItem exampleNamed: 'Gamma' score: 90 status: #archived.

	embeddedObject := alpha.
	phlowObject := beta.
	compactObject := gamma.
	columnedObject := alpha.
	compactItems := { alpha. beta. gamma }.
	expandableItems := { alpha. beta. gamma }.
	accordionItems := { alpha. beta. gamma }.
	gridItems := { alpha. beta. gamma }.
	embeddedItems := { alpha. beta }.
	gridEmbeddedItems := { alpha. beta }.
	phlowItems := { alpha. beta. gamma }.
	gridPhlowItems := { alpha. beta. gamma }
]

{ #category : 'accessing' }
CFMaFormShowcase >> summary [
	^ summary
]

{ #category : 'accessing' }
CFMaFormShowcase >> summary: aString [
	summary := aString
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> summaryDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #summary;
		label: 'Summary';
		comment: 'A memo editor with enough content to expose field sizing and label alignment.';
		group: 'Fields';
		priority: 20;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> enabled [
	^ enabled
]

{ #category : 'accessing' }
CFMaFormShowcase >> enabled: aBoolean [
	enabled := aBoolean
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> enabledDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #enabled;
		label: 'Enabled';
		group: 'Fields';
		priority: 30;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> priority [
	^ priority
]

{ #category : 'accessing' }
CFMaFormShowcase >> priority: aNumber [
	priority := aNumber
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> priorityDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #priority;
		label: 'Priority';
		comment: 'Required numeric validation: enter a value outside 0..100 to inspect validation presentation.';
		group: 'Fields';
		priority: 40;
		beRequired;
		addCondition: [ :aValue | aValue isNumber and: [ aValue between: 0 and: 100 ] ]
			labelled: 'Priority must be between 0 and 100';
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> status [
	^ status
]

{ #category : 'accessing' }
CFMaFormShowcase >> status: aSymbol [
	status := aSymbol
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> statusDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #status;
		label: 'Status';
		group: 'Fields';
		priority: 50;
		options: #(draft active archived);
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> derivedValue [
	^ self label asLowercase copyReplaceAll: ' ' with: '-'
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> derivedValueDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #derivedValue;
		label: 'Derived value';
		comment: 'A read-only field.';
		group: 'Fields';
		priority: 60;
		beReadOnly;
		yourself
]


{ #category : 'descriptions - relations' }
CFMaFormShowcase >> showcaseItemReferenceDescription [
	^ MAContainer new
		add: (MAStringDescription new
			accessor: #label;
			label: 'Label';
			priority: 10;
			yourself);
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> embeddedObject [
	^ embeddedObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> embeddedObject: anObject [
	embeddedObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> embeddedObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #embeddedObject;
		label: 'Embedded form';
		comment: 'The related object is edited in place.';
		group: 'To one';
		priority: 100;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beEmbeddedForm;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> phlowObject [
	^ phlowObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> phlowObject: anObject [
	phlowObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> phlowObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #phlowObject;
		label: 'Phlow link';
		comment: 'A compact affordance that opens the related object through Phlow.';
		group: 'To one';
		priority: 110;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		bePhlowLink;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> compactObject [
	^ compactObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> compactObject: anObject [
	compactObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> compactObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #compactObject;
		label: 'Compact list';
		group: 'To one';
		priority: 120;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beCompactList;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> columnedObject [
	^ columnedObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> columnedObject: anObject [
	columnedObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> columnedObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #columnedObject;
		label: 'Columned list';
		group: 'To one';
		priority: 130;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beColumnedList;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> compactItems [
	^ compactItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> compactItems: aCollection [
	compactItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> compactItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #compactItems;
		label: 'Compact list';
		group: 'To many';
		priority: 200;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beSimpleList;
		itemsAsCompactObjects;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> expandableItems [
	^ expandableItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> expandableItems: aCollection [
	expandableItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> expandableItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #expandableItems;
		label: 'Expandable list';
		group: 'To many';
		priority: 210;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beExpandableList;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> accordionItems [
	^ accordionItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> accordionItems: aCollection [
	accordionItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> accordionItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #accordionItems;
		label: 'Accordion list';
		group: 'To many';
		priority: 220;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beAccordionList;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridItems [
	^ gridItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridItems: aCollection [
	gridItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> gridItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #gridItems;
		label: 'Grid of compact objects';
		group: 'To many';
		priority: 230;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beGrid;
		itemsAsCompactObjects;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> embeddedItems [
	^ embeddedItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> embeddedItems: aCollection [
	embeddedItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> embeddedItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #embeddedItems;
		label: 'Embedded forms';
		group: 'To many';
		priority: 240;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beSimpleList;
		itemsAsEmbeddedForms;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridEmbeddedItems [
	^ gridEmbeddedItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridEmbeddedItems: aCollection [
	gridEmbeddedItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> gridEmbeddedItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #gridEmbeddedItems;
		label: 'Grid of embedded forms';
		group: 'To many';
		priority: 250;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beGrid;
		itemsAsEmbeddedForms;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> phlowItems [
	^ phlowItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> phlowItems: aCollection [
	phlowItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> phlowItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #phlowItems;
		label: 'Phlow links';
		group: 'To many';
		priority: 260;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beSimpleList;
		itemsAsPhlowLinks;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridPhlowItems [
	^ gridPhlowItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> gridPhlowItems: aCollection [
	gridPhlowItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> gridPhlowItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #gridPhlowItems;
		label: 'Grid of Phlow links';
		group: 'To many';
		priority: 270;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beGrid;
		itemsAsPhlowLinks;
		newItemStencil: CFMaNewItemStencilBuilder new;
		yourself
]
