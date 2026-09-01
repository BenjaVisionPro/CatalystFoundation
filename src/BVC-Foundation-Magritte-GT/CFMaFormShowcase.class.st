"
I am Foundation's singular Magritte rendering showcase. My descriptions expose every field and relation rendering Foundation currently supports so they can be evaluated together during UI development.
"
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
		'popupPriority',
		'sliderPriority',
		'status',
		'multipleStatuses',
		'duration',
		'date',
		'time',
		'dateAndTime',
		'classValue',
		'themeColour',
		'textSelectionColour',
		'tags',
		'file',
		'directory',
		'fieldIcon',
		'derivedValue',
		'listObject',
		'embeddedObject',
		'listItems',
		'embeddedItems'
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
		categories: #(metadata);
		priority: 140;
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
		categories: #(temporal);
		priority: 120;
		yourself
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> dateDescription [
	<magritteDescription>
	^ MADateDescription new
		accessor: #date;
		label: 'Date';
		group: 'Fields';
		categories: #(temporal);
		priority: 100;
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
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field | field icon beSmall ];
		group: 'Fields';
		categories: #(resources);
		priority: 190;
		beReadOnly;
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
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field | field icon beSmall ];
		kind: AbstractFileReference;
		display: #printString;
		group: 'Fields';
		categories: #(resources);
		priority: 170;
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
		categories: #(temporal);
		priority: 90;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> editableIconAndLabelDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Editable icon + label';
		icon: (FontAwesomeIcons defaultStyle icon: #addressCard);
		fieldConfigure: [ :field | field icon beSmall ];
		group: 'Fields';
		categories: #(presentation);
		priority: 5;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> editableIconLabelAndCommentDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Editable icon + label + comment';
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field |
			field icon
				beLarge;
				backgroundColor: (Color r: 10 g: 132 b: 255 range: 255) ];
		comment: 'Secondary information for the field.';
		group: 'Fields';
		categories: #(presentation);
		priority: 7;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> editableLabelAndCommentDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Editable label + comment';
		comment: 'Secondary information for the field.';
		group: 'Fields';
		categories: #(presentation);
		priority: 3;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> editableLabelOnlyDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Editable label only';
		group: 'Fields';
		categories: #(presentation);
		priority: 1;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> listObject [
	^ listObject
]

{ #category : 'accessing' }
CFMaFormShowcase >> listObject: anObject [
	listObject := anObject
]

{ #category : 'descriptions - to one' }
CFMaFormShowcase >> listObjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #listObject;
		label: 'List';
		comment: 'The related object is presented as an ordinary Detail row.';
		group: 'To one';
		priority: 100;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> listItems [
	^ listItems
]

{ #category : 'accessing' }
CFMaFormShowcase >> listItems: aCollection [
	listItems := aCollection
]

{ #category : 'descriptions - to many' }
CFMaFormShowcase >> listItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #listItems;
		label: 'List';
		comment: 'Each related object is presented as an ordinary peer Detail row.';
		group: 'To many';
		priority: 200;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		beOrdered;
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
		priority: 210;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		beModifiable;
		fieldConfigure: [ :field | field beEmbeddedForms ];
		newItemStencil: CFMaNewItemStencilBuilder new;
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
		comment: 'The related object is edited in place using ordinary Detail rows.';
		group: 'To one';
		priority: 110;
		classes: { CFMaFormShowcaseItem. CFMaFormShowcaseAccentItem };
		reference: self showcaseItemReferenceDescription;
		fieldConfigure: [ :field | field beEmbeddedForm ];
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
		icon: (FontAwesomeIcons defaultStyle icon: #addressCard);
		information: 'Controls whether this example feature is enabled.';
		group: 'Fields';
		categories: #(values);
		priority: 50;
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
		icon: (FontAwesomeIcons brands fontAwesome);
		fieldConfigure: [ :field | field icon beSmall ];
		default: self defaultIcon;
		group: 'Fields';
		categories: #(resources);
		priority: 180;
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
		icon: (FontAwesomeIcons defaultStyle icon: #file);
		fieldConfigure: [ :field | field icon beSmall ];
		kind: AbstractFileReference;
		display: #printString;
		group: 'Fields';
		categories: #(resources);
		priority: 160;
		yourself
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
	sliderPriority := 65.
	popupPriority := 75.
	status := #active.
	multipleStatuses := #(draft active).
	duration := Duration days: 1 hours: 2 minutes: 3 seconds: 4.
	date := Date newDay: 16 month: (Date nameOfMonth: 8) year: 2026.
	time := Time hour: 14 minute: 30 second: 0.
	dateAndTime := DateAndTime year: 2026 month: 8 day: 16 hour: 14 minute: 30 second: 0.
	classValue := String.
	themeColour := CgtPalette themePurple.
	textSelectionColour := nil.
	tags := #('foundation' 'magritte' 'bloc').
	file := FileLocator imageDirectory.
	directory := FileLocator imageDirectory.
	fieldIcon := self defaultIcon.
	derivedValue := 'foundation-magritte-showcase'.

	alpha := CFMaFormShowcaseItem exampleNamed: 'Alpha' score: 30 status: #active.
	beta := CFMaFormShowcaseAccentItem exampleNamed: 'Beta' score: 60 status: #draft.
	gamma := CFMaFormShowcaseItem exampleNamed: 'Gamma' score: 90 status: #archived.

	listObject := beta.
	embeddedObject := alpha.
	listItems := { alpha. beta. gamma }.
	embeddedItems := { alpha. beta }
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
		categories: #(values);
		priority: 80;
		options: #(draft active archived);
		reference: MASymbolDescription new;
		beOrdered;
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
		categories: #(text);
		priority: 30;
		yourself
]







{ #category : 'accessing' }
CFMaFormShowcase >> popupPriority [
	^ popupPriority
]

{ #category : 'accessing' }
CFMaFormShowcase >> popupPriority: aNumber [
	popupPriority := aNumber
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> popupPriorityDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #popupPriority;
		label: 'Popup priority';
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field |
			field icon backgroundColor: (Color r: 10 g: 132 b: 255 range: 255).
			field bePopup values: #(0 25 50 75 100) ];
		comment: 'The same bounded numeric semantics represented as an explicit popup.';
		group: 'Fields';
		categories: #(values);
		priority: 65;
		min: 0;
		max: 100;
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
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field |
			field icon backgroundColor: (Color r: 10 g: 132 b: 255 range: 255) ];
		comment: 'Required numeric validation: enter a value outside 0..100 to inspect validation presentation.';
		group: 'Fields';
		categories: #(values);
		priority: 60;
		beRequired;
		addCondition: [ :aValue | aValue isNumber and: [ aValue between: 0 and: 100 ] ]
			labelled: 'Priority must be between 0 and 100';
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> readOnlyIconAndLabelDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Read only icon + label';
		icon: (FontAwesomeIcons defaultStyle icon: #addressCard);
		fieldConfigure: [ :field | field icon beUnadorned ];
		group: 'Fields';
		categories: #(presentation);
		priority: 6;
		beReadOnly;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> readOnlyIconLabelAndCommentDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Read only icon + label + comment';
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field |
			field icon backgroundColor: (Color r: 10 g: 132 b: 255 range: 255) ];
		comment: 'Secondary information for the field.';
		group: 'Fields';
		categories: #(presentation);
		priority: 8;
		beReadOnly;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> readOnlyLabelAndCommentDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Read only label + comment';
		comment: 'Secondary information for the field.';
		group: 'Fields';
		categories: #(presentation);
		priority: 4;
		beReadOnly;
		yourself
]

{ #category : 'descriptions - fields - presentation variants' }
CFMaFormShowcase >> readOnlyLabelOnlyDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #text;
		label: 'Read only label only';
		group: 'Fields';
		categories: #(presentation);
		priority: 2;
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
CFMaFormShowcase >> sliderPriority [
	^ sliderPriority
]

{ #category : 'accessing' }
CFMaFormShowcase >> sliderPriority: aNumber [
	sliderPriority := aNumber
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> sliderPriorityDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #sliderPriority;
		label: 'Slider priority';
		icon: (FontAwesomeIcons defaultStyle icon: #addressBook);
		fieldConfigure: [ :field |
			field icon backgroundColor: (Color r: 10 g: 132 b: 255 range: 255).
			field beSlider ];
		comment: 'The same bounded numeric semantics represented as a continuous slider.';
		group: 'Fields';
		categories: #(values);
		priority: 67;
		min: 0;
		max: 100;
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
		icon: (FontAwesomeIcons defaultStyle icon: #addressCard);
		group: 'Fields';
		categories: #(values);
		priority: 70;
		options: #(draft active archived);
		beRequired;
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
		categories: #(text);
		priority: 20;
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
		categories: #(text);
		priority: 40;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> themeColour [
	^ themeColour
]

{ #category : 'accessing' }
CFMaFormShowcase >> themeColour: aColour [
	themeColour := aColour
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> themeColourDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #themeColour;
		label: 'Theme colour';
		group: 'Theme';
		priority: 10;
		options: CgtPalette themeColours;
		fieldConfigure: [ :field |
			field beColourPicker
				colourBlock: [ :aColour | aColour ];
				labelBlock: [ :aColour |
					CgtPalette themeNameFor: aColour ] ];
		beRequired;
		yourself
]

{ #category : 'accessing' }
CFMaFormShowcase >> textSelectionColour [
	^ textSelectionColour
]

{ #category : 'accessing' }
CFMaFormShowcase >> textSelectionColour: aColour [
	textSelectionColour := aColour
]

{ #category : 'descriptions - fields' }
CFMaFormShowcase >> textSelectionColourDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #textSelectionColour;
		label: 'Text selection colour';
		group: 'Theme';
		priority: 20;
		options: ({ nil } , CgtPalette textSelectionColours);
		fieldConfigure: [ :field |
			field bePopup
				displayBlock: [ :aColour |
					CgtPalette textSelectionNameFor: aColour ] ];
		blocOptionIconStencil: [ :aColour |
			aColour
				ifNil: [
					CFMaDetailColourSwatchElement automaticSize: 14 @ 14 ]
				ifNotNil: [
					CFMaDetailColourSwatchElement
						colour: aColour
						size: 14 @ 14 ] ];
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
		categories: #(metadata);
		priority: 150;
		classes: { String };
		reference: (MAStringDescription new
			accessor: MANullAccessor new;
			yourself);
		yourself
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
		categories: #(text);
		priority: 10;
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
		categories: #(temporal);
		priority: 110;
		yourself
]

{ #category : 'descriptions - actions' }
CFMaFormShowcase >> exampleActionDescription [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Store in iCloud';
		comment: 'Only store the most recent messages on this Mac.';
		group: 'Fields';
		categories: #();
		priority: 195;
		action: [ :aModel | aModel ];
		yourself
]
