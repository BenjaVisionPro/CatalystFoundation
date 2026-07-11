Class {
	#name : 'CFMaExpanderItemElement',
	#superclass : 'BrExpander',
	#instVars : [
		'expanderItemViewModel',
		'collapsedElement',
		'expandedElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'accessing' }
CFMaExpanderItemElement >> collapsedElement [
	^ collapsedElement
]

{ #category : 'accessing' }
CFMaExpanderItemElement >> editorHeight [
	^ 320
]

{ #category : 'accessing' }
CFMaExpanderItemElement >> expanderItemViewModel [
	^ expanderItemViewModel
]

{ #category : 'accessing' }
CFMaExpanderItemElement >> expanderItemViewModel: aViewModel [
	expanderItemViewModel := aViewModel.

	self
		header: [ collapsedElement := self newCollapsedElement ];
		content: [ expandedElement := self newExpandedElement ];
		expanded: aViewModel expanded
]

{ #category : 'initialization' }
CFMaExpanderItemElement >> initialize [
	super initialize.

	self
		vFitContent;
		hMatchParent;
		margin: (BlInsets all: 4);
		aptitude: ((GtCoderExpanderAptitude new padding: BlInsets empty)
			+ (BrStyleCommonAptitude new
				default: [ :aStyle | aStyle background: Color transparent ]));
		beInSingleCompositionLayer.

	self states withExpansion.
	self when: BrExpandedEvent do: [ :anEvent | anEvent target onExpanded ].
	self when: BrCollapsedEvent do: [ :anEvent | anEvent target onCollapsed ].

	self
		header: [ collapsedElement := self newCollapsedElement ];
		content: [ expandedElement := self newExpandedElement ].

	self
		when: BlClickEvent
		do: [ :anEvent |
			self isCollapsed ifTrue: [
				anEvent consumed: true.
				self expand ] ]
]

{ #category : 'private - instance creation' }
CFMaExpanderItemElement >> newCollapsedElement [
	^ expanderItemViewModel
		ifNil: [ BrFrame new hMatchParent; vFitContent ]
		ifNotNil: [
			CFCompactObjectStencil new
				memento: expanderItemViewModel itemMemento;
				create ]
]

{ #category : 'private - instance creation' }
CFMaExpanderItemElement >> newExpandedElement [
	^ BrFrame new
		hMatchParent;
		vExact: self editorHeight;
		padding: (BlInsets top: 0 left: 10 bottom: 10 right: 10);
		addChild: expanderItemViewModel asElement;
		yourself
]

{ #category : 'private - event handling' }
CFMaExpanderItemElement >> onCollapsed [
	self beInSingleCompositionLayer.
	expanderItemViewModel ifNotNil: [ :aViewModel |
		aViewModel expanded: false ]
]

{ #category : 'private - event handling' }
CFMaExpanderItemElement >> onExpanded [
	self beInSeparateCompositionLayer.
	expanderItemViewModel ifNotNil: [ :aViewModel |
		aViewModel expanded: true ]
]
