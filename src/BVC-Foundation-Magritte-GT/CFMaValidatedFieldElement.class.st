Class {
	#name : 'CFMaValidatedFieldElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'changeElement',
		'issuesElement',
		'memento',
		'description',
		'fieldElement',
		'fieldRowElement'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaValidatedFieldElement >> defaultSpaceNumber [
	^ GtMagritteBuilderUtility defaultSpaceNumber
]

{ #category : 'initialization' }
CFMaValidatedFieldElement >> defaultThickness [
	^ GtMagritteBuilderUtility defaultThickness
]

{ #category : 'initialization' }
CFMaValidatedFieldElement >> initialize [
	super initialize.

	self
		hMatchParent;
		vFitContent;
		cellSpacing: 2.

	changeElement := self newChangeElement.
	fieldElement := self newPlaceHolderElement.
	issuesElement := self newIssuesElement.

	fieldRowElement := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: self defaultSpaceNumber;
		addChild: changeElement as: #changeIndicator;
		addChild: fieldElement as: #field;
		yourself.

	self
		addChild: fieldRowElement as: #fieldRow;
		addChild: issuesElement as: #issues
]

{ #category : 'accessing' }
CFMaValidatedFieldElement >> memento: aMemento description: aDescription element: aFieldElement [
	memento := aMemento.
	description := aDescription.

	changeElement withAsyncSinkDo: [ :anElementSink |
		(aMemento readObservableValueUsing: aDescription) observe: anElementSink ].
	issuesElement withAsyncSinkDo: [ :anElementSink |
		(aMemento validatorUsing: aDescription) observe: anElementSink ].

	fieldRowElement replaceChild: fieldElement with: aFieldElement as: #field.
	fieldElement := aFieldElement
]

{ #category : 'initialization' }
CFMaValidatedFieldElement >> newChangeElement [
	^ BrFrame new
		hExact: self defaultThickness;
		vMatchParent;
		background: BrGlamorousColors textHighlightColor;
		visibility: BlVisibility hidden;
		margin: (BlInsets bottom: self defaultSpaceNumber);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :aLabel :aSink |
					| aValue |
					aValue := aSink value.
					aValue isChanged
						ifTrue: [ aLabel visibility: BlVisibility visible ]
						ifFalse: [ aLabel visibility: BlVisibility hidden ] ] ];
		yourself
]

{ #category : 'initialization' }
CFMaValidatedFieldElement >> newIssuesElement [
	^ BrEditor new
		aptitude: (BrGlamorousRegularEditorAptitude new
			glamorousRegularFont;
			glamorousCodeSmallSize;
			foreground: BrGlamorousColors errorBackgroundColor);
		beReadOnlyWithSelection;
		hMatchParent;
		vFitContent;
		text: '';
		visibility: BlVisibility gone;
		margin: (BlInsets left: self defaultThickness + self defaultSpaceNumber);
		withAsyncSinkDo: [ :anElementSink |
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :aLabel :aSink |
					| aValue |
					aValue := aSink value.
					aValue isSuccess
						ifTrue: [
							aLabel
								text: '';
								visibility: BlVisibility gone ]
						ifFalse: [
							aLabel
								text: aValue issuesDescription;
								visibility: BlVisibility visible ] ] ];
		yourself
]

{ #category : 'initialization' }
CFMaValidatedFieldElement >> newPlaceHolderElement [
	^ BlElement new size: 0 @ 0
]
