Class {
	#name : 'CFLightBorderAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> allTreatments [
	<gtExample>
	<return: #BlElement>
	| grid |
	grid := BlElement new
		size: 760 @ 1040;
		background: Color gray;
		padding: (BlInsets all: 24);
		layout: (BlGridLayout new
			columnCount: 2;
			cellSpacing: 28);
		yourself.

	grid addChild: (self treatmentCellNamed: 'Raise body inside' configure: [ :a | a raiseBodyInside ]).
	grid addChild: (self treatmentCellNamed: 'Raise body outside' configure: [ :a | a raiseBodyOutside ]).
	grid addChild: (self treatmentCellNamed: 'Lower body inside' configure: [ :a | a lowerBodyInside ]).
	grid addChild: (self treatmentCellNamed: 'Lower body outside' configure: [ :a | a lowerBodyOutside ]).
	grid addChild: (self treatmentCellNamed: 'Raise border inside' configure: [ :a | a raiseBorderInside ]).
	grid addChild: (self treatmentCellNamed: 'Raise border outside' configure: [ :a | a raiseBorderOutside ]).
	grid addChild: (self treatmentCellNamed: 'Lower border inside' configure: [ :a | a lowerBorderInside ]).
	grid addChild: (self treatmentCellNamed: 'Lower border outside' configure: [ :a | a lowerBorderOutside ]).
	^ grid
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> aptitudeConfiguredBy: aBlock [
	| aptitude |
	aptitude := CFLightBorderAptitude new
		beFlat;
		effectWidth: 10;
		opacity: 0.9;
		lightDirection: -1 @ -1;
		yourself.
	aBlock value: aptitude.
	^ aptitude
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude [
	^ BlElement new
		size: 300 @ 180;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 18);
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.75) width: 12);
		addAptitude: anAptitude;
		yourself
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> lowered [
	<gtExample>
	<return: #BlElement>
	^ self stageWith: (self cardWith: CFLightBorderAptitude new beLowered)
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raised [
	<gtExample>
	<return: #BlElement>
	^ self stageWith: (self cardWith: CFLightBorderAptitude new beRaised)
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raisedFromTopRight [
	<gtExample>
	<return: #BlElement>
	^ self stageWith: (self cardWith: (CFLightBorderAptitude new
		beRaised;
		lightDirection: 1 @ -1;
		yourself))
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> stageWith: aCard [
	^ BlElement new
		size: 400 @ 280;
		background: Color gray;
		layout: BlFrameLayout new;
		addChild: (aCard constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]);
		yourself
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> treatmentCellNamed: aString configure: aBlock [
	| pane label aptitude |
	aptitude := self aptitudeConfiguredBy: aBlock.
	label := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: Color white);
		text: aString;
		fitContent;
		margin: (BlInsets bottom: 10);
		yourself.
	pane := BrVerticalPane new
		size: 330 @ 230;
		addChild: label;
		addChild: (self cardWith: aptitude);
		yourself.
	^ pane
]
