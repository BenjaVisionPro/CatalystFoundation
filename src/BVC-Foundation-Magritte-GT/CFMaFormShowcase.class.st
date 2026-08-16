"I am Foundation's singular Magritte rendering showcase. My descriptions expose every field and relation rendering Foundation currently supports so they can be evaluated together during UI development."

Class {
	#name : 'CFMaFormShowcase',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'text',
		'summary',
		'password',
		'symbolValue',
		'enabled',
		'priority',
		'status',
		'multipleStatuses',
		'duration',
		'date',
		'time',
		'dateAndTime',
		'classValue',
		'tags',
		'file',
		'directory',
		'fieldIcon',
		'derivedValue',
		'embeddedObject',
		'identityObject',
		'phlowObject',
		'compactObject',
		'columnedObject',
		'compactItems',
		'identityItems',
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

{ #category : 'examples' }
CFMaFormShowcase class >> exampleCurrentPresentationElement [
	<gtExample>
	^ ((CFMaViewModel forObject: self example)
		presentationClass: CFMaTabbedPresentation;
		yourself) asElement
]

{ #category : 'examples' }
CFMaFormShowcase class >> exampleSettingsElement [
	<gtExample>
	^ ((CFMaViewModel forObject: self example)
		presentationClass: CFMaSettingsPresentation;
		yourself) asElement
]


{ #category : 'converting' }
CFMaFormShowcase >> asGtMagritteViewModel [
	^ (CFMaViewModel forObject: self)
		presentationClass: CFMaSettingsPresentation;
		yourself
]

{ #category : 'converting' }
CFMaFormShowcase >> asElement [
	^ self asGtMagritteViewModel asElement
]


{ #category : 'descriptions - identity' }
CFMaFormShowcase >> iconDescription [
	<magritteDescription>
	^ super iconDescription
		beWriteable;
		yourself
]

{ #category : 'initialization' }
CFMaFormShowcase >> initialize [
	| alpha beta gamma |
	super initialize.
	self label: 'Foundation Magritte showcase'.
	text := 'Editable text'.
	summary := 'A semantic memo field kept separate so Foundation can verify its rendering alongside ordinary text.'.
	password := 'secret password'.
	symbolValue := #foundation.
	enabled := true.
	priority := 60.
	status := #active.
	multipleStatuses := #(draft active).
	duration := Duration days: 1 hours: 2 minutes: 3 seconds: 4.
	date := Date newDay: 16 month: (Date nameOfMonth: 8) year: 2026.
	time := Time hour: 14 minute: 30 second: 0.
	dateAndTime := DateAndTime year: 2026 month: 8 day: 16 hour: 14 minute: 30 second: 0.
	classValue := String.
	tags := #(foundation magritte bloc).
	file := FileLocator imageDirectory.
	directory := FileLocator imageDirectory.
	fieldIcon := self defaultIcon.
	derivedValue := 'foundation-magritte-showcase'.

	alpha := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 30 status: #active.
	beta := CFMaFormShowcaseAccentItem exampleNamed: 'Beta' score: 60 status: #draft.
	gamma := CFMaFormShowcaseItem exampleNamed: 'Gamma' score: 90 status: #archived.

	embeddedObject := alpha.
	identityObject := beta.
	phlowObject := beta.
	compactObject := gamma.
	columnedObject := alpha.
	compactItems := { alpha. beta. gamma }.
	identityItems := { alpha. beta. gamma }.
	expandableItems := { alpha. beta. gamma }.
	accordionItems := { alpha. beta. gamma }.
	gridItems := { alpha. beta. gamma }.
	embeddedItems := { alpha. beta }.
	gridEmbeddedItems := { alpha. beta }.
	phlowItems := { alpha. beta. gamma }.
	gridPhlowItems := { alpha. beta. gamma }
]

{ #category : 'accessing' }
CFMaFormShowcase >> text [
	^ text
]

{ #category : 'accessing' }
CFMaFormShowcase >> text: aString [
	text := aString
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> textDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Text';
		group: 'Fields';
		priority: 10;
		yourself
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
		comment: 'A semantic memo field. GT currently routes it through the string-field rendering path.';
		group: 'Fields';
		priority: 20;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> password [
	^ password
]

{ #category : 'accessing' }
CFMaFormShowcase >> password: aString [
	password := aString
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> passwordDescription [
	<magritteDescription>
	^ MAPasswordDescription new
		accessor: #password;
		label: 'Password';
		group: 'Fields';
		priority: 30;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> symbolValue [
	^ symbolValue
]

{ #category : 'accessing' }
CFMaFormShowcase >> symbolValue: aSymbol [
	symbolValue := aSymbol
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> symbolValueDescription [
	<magritteDescription>
	^ MASymbolDescription new
		accessor: #symbolValue;
		label: 'Symbol';
		group: 'Fields';
		priority: 40;
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
		priority: 50;
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
		priority: 60;
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
		priority: 70;
		options: #(draft active archived);
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> multipleStatuses [
	^ multipleStatuses
]

{ #category : 'accessing' }
CFMaFormShowcase >> multipleStatuses: aCollection [
	multipleStatuses := aCollection
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> multipleStatusesDescription [
	<magritteDescription>
	^ MAMultipleOptionDescription new
		accessor: #multipleStatuses;
		label: 'Multiple option';
		group: 'Fields';
		priority: 80;
		options: #(draft active archived);
		reference: MASymbolDescription new;
		beOrdered;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> duration [
	^ duration
]

{ #category : 'accessing' }
CFMaFormShowcase >> duration: aDuration [
	duration := aDuration
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> durationDescription [
	<magritteDescription>
	^ MADurationDescription new
		accessor: #duration;
		label: 'Duration';
		group: 'Fields';
		priority: 90;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> date [
	^ date
]

{ #category : 'accessing' }
CFMaFormShowcase >> date: aDate [
	date := aDate
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> dateDescription [
	<magritteDescription>
	^ MADateDescription new
		accessor: #date;
		label: 'Date';
		group: 'Fields';
		priority: 100;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> time [
	^ time
]

{ #category : 'accessing' }
CFMaFormShowcase >> time: aTime [
	time := aTime
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> timeDescription [
	<magritteDescription>
	^ MATimeDescription new
		accessor: #time;
		label: 'Time';
		group: 'Fields';
		priority: 110;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> dateAndTime [
	^ dateAndTime
]

{ #category : 'accessing' }
CFMaFormShowcase >> dateAndTime: aDateAndTime [
	dateAndTime := aDateAndTime
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> dateAndTimeDescription [
	<magritteDescription>
	^ MADateAndTimeDescription new
		accessor: #dateAndTime;
		label: 'Date and time';
		group: 'Fields';
		priority: 120;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> classValue [
	^ classValue
]

{ #category : 'accessing' }
CFMaFormShowcase >> classValue: aClass [
	classValue := aClass
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> classValueDescription [
	<magritteDescription>
	^ MAClassDescription new
		accessor: #classValue;
		label: 'Class';
		group: 'Fields';
		priority: 140;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> tags [
	^ tags
]

{ #category : 'accessing' }
CFMaFormShowcase >> tags: aCollection [
	tags := aCollection
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> tagsDescription [
	<magritteDescription>
	^ MAToManyScalarRelationDescription new
		accessor: #tags;
		label: 'Tags';
		comment: 'A to-many scalar relation reserved for Foundation''s tag-editor rendering.';
		group: 'Fields';
		priority: 150;
		classes: { String };
		reference: (MAStringDescription new
			accessor: MANullAccessor new;
			yourself);
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> file [
	^ file
]

{ #category : 'accessing' }
CFMaFormShowcase >> file: aFileReference [
	file := aFileReference
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> fileDescription [
	<magritteDescription>
	^ MAFileDescription new
		accessor: #file;
		label: 'File';
		kind: AbstractFileReference;
		display: #printString;
		group: 'Fields';
		priority: 160;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> directory [
	^ directory
]

{ #category : 'accessing' }
CFMaFormShowcase >> directory: aFileReference [
	directory := aFileReference
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> directoryDescription [
	<magritteDescription>
	^ MADirectoryDescription new
		accessor: #directory;
		label: 'Directory';
		kind: AbstractFileReference;
		display: #printString;
		group: 'Fields';
		priority: 170;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> fieldIcon [
	^ fieldIcon
]

{ #category : 'accessing' }
CFMaFormShowcase >> fieldIcon: anIcon [
	fieldIcon := anIcon
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> fieldIconDescription [
	<magritteDescription>
	^ FontAwesomeIconDescription new
		accessor: #fieldIcon;
		label: 'Font Awesome icon';
		default: self defaultIcon;
		group: 'Fields';
		priority: 180;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> derivedValue [
	^ derivedValue
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> derivedValueDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #derivedValue;
		label: 'Derived value';
		group: 'Fields';
		priority: 190;
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
CFMaFormShowcase >> identityObject [
	^ identityObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> identityObject: anObject [
	identityObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> identityObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #identityObject;
		label: 'Editable identity affordance';
		comment: 'Icon, label, and identifier are edited directly in the compact affordance.';
		group: 'To one';
		priority: 105;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beIdentityAffordance;
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
CFMaFormShowcase >> identityItems [
	^ identityItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> identityItems: aCollection [
	identityItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> identityItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #identityItems;
		label: 'Editable identity affordances';
		group: 'To many';
		priority: 205;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beSimpleList;
		itemsAsIdentityAffordances;
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
