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
	| root controls grid borderColor borderWidth effectWidth intensity rebuildGallery |
	borderColor := Color blue alpha: 0.75.
	borderWidth := 8.
	effectWidth := 2.5.
	intensity := 0.9.

	root := BrVerticalPane new
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		background: Color gray;
		padding: (BlInsets all: 18);
		cellSpacing: 12;
		yourself.

	controls := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 4;
		yourself.

	grid := BlElement new
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: 1 ];
		layout: (BlGridLayout new
			columnCount: 2;
			rowCount: 4;
			cellSpacing: 18);
		yourself.

	rebuildGallery := [
		grid removeChildren.

		"Column 1: body treatments. Opposites are stacked vertically."
		grid addChild: (self
			treatmentCellNamed: 'Raise body inside'
			configure: [ :a | a raiseBodyInside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).
		grid addChild: (self
			treatmentCellNamed: 'Raise body outside'
			configure: [ :a | a raiseBodyOutside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).

		grid addChild: (self
			treatmentCellNamed: 'Lower body inside'
			configure: [ :a | a lowerBodyInside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).
		grid addChild: (self
			treatmentCellNamed: 'Lower body outside'
			configure: [ :a | a lowerBodyOutside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).

		"Column 2: border treatments. Opposites are stacked vertically."
		grid addChild: (self
			treatmentCellNamed: 'Raise border inside'
			configure: [ :a | a raiseBorderInside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).
		grid addChild: (self
			treatmentCellNamed: 'Raise border outside'
			configure: [ :a | a raiseBorderOutside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).

		grid addChild: (self
			treatmentCellNamed: 'Lower border inside'
			configure: [ :a | a lowerBorderInside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity).
		grid addChild: (self
			treatmentCellNamed: 'Lower border outside'
			configure: [ :a | a lowerBorderOutside ]
			borderColor: borderColor
			borderWidth: borderWidth
			effectWidth: effectWidth
			intensity: intensity) ].

	controls addChild: (self
		colorControlNamed: 'Border colour'
		color: borderColor
		changed: [ :aColor |
			borderColor := aColor.
			rebuildGallery value ]).
	controls addChild: (self
		sliderNamed: 'Border width'
		min: 0
		max: 12
		value: borderWidth
		quantum: 1
		changed: [ :aNumber |
			borderWidth := aNumber.
			rebuildGallery value ]).
	controls addChild: (self
		sliderNamed: 'Effect width'
		min: 0
		max: 12
		value: effectWidth
		quantum: 0.25
		changed: [ :aNumber |
			effectWidth := aNumber.
			rebuildGallery value ]).
	controls addChild: (self
		sliderNamed: 'Effect intensity'
		min: 0
		max: 1
		value: intensity
		quantum: 0.05
		changed: [ :aNumber |
			intensity := aNumber.
			rebuildGallery value ]).

	root
		addChild: controls;
		addChild: grid.
	rebuildGallery value.
	^ root
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> aptitudeConfiguredBy: aBlock [
	| aptitude |
	aptitude := CFLightBorderAptitude new
		beFlat;
		effectWidth: 5;
		opacity: 0.9;
		lightDirection: -1 @ -1;
		yourself.
	aBlock value: aptitude.
	^ aptitude
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude [
	^ BlElement new
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: 1 ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: 24);
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.75) width: 8);
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
		margin: (BlInsets bottom: 8);
		yourself.
	pane := BrVerticalPane new
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: label;
		addChild: (self cardWith: aptitude);
		yourself.
	^ pane
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude borderWidth: aNumber [
	^ self cardWith: anAptitude geometry: (BlRoundedRectangleGeometry cornerRadius: 16) borderWidth: aNumber
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude geometry: aGeometry borderWidth: aNumber [
	| anElement |
	anElement := BlElement new
		size: 280 @ 160;
		geometry: aGeometry;
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.5) width: aNumber);
		addAptitude: anAptitude.
	^ anElement
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude [
	^ self elementWith: anAptitude borderWidth: 6
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude borderWidth: aNumber [
	^ self stageWith: (self cardWith: anAptitude borderWidth: aNumber)
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude geometry: aGeometry [
	^ self stageWith: (self cardWith: anAptitude geometry: aGeometry borderWidth: 6)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyFlatBorderFlat [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beFlat
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyFlatBorderLowered [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyFlatBorderRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyLoweredBorderFlat [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyLoweredBorderLowered [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beLowered
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyLoweredBorderRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyInside; raiseBorderInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyRaisedBorderFlat [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBodyInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyRaisedBorderLowered [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBodyInside; lowerBorderInside; yourself)
]

{ #category : 'examples - relief matrix' }
CFLightBorderAptitudeExamples >> bodyRaisedBorderRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beRaised
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> ellipse [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beRaised geometry: BlEllipseGeometry new
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBodyInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBodyInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new
		beFlat;
		raiseBorderInside;
		effectWidth: 2.5;
		yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBodyOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBodyOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> raiseBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; raiseBorderOutside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderInside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderInside; yourself)
]
{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'examples - placement' }
CFLightBorderAptitudeExamples >> lowerBorderOutside [
	<gtExample>
	^ self elementWith: (CFLightBorderAptitude new beFlat; lowerBorderOutside; yourself)
]

{ #category : 'diagnostics' }
CFLightBorderAptitudeExamples >> borderGeometryProbe [
	<gtExample>
	<return: #BlElement>
	| radius borderWidth card stage |
	radius := 40.
	borderWidth := 16.

	card := BlSpartaElement new
		size: 320 @ 180;
		geometry: (BlRoundedRectangleGeometry cornerRadius: radius);
		background: (Color black alpha: 0.08);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.75) width: borderWidth);
		rendering: [ :aCanvas :anElement |
			| bounds currentOuter currentInner idealOuter idealInner currentOuterRadius currentInnerRadius idealInnerRadius |
			bounds := anElement geometryBounds.

			"SpartaFigurePainter>>drawGeometry: implements an inside border by
			insetting the stroke geometry by half the border width while
			SpartaRoundedRectangle>>insetBy: preserves its radius. These two
			outlines are the resulting visible stroke edges."
			currentOuterRadius := radius + (borderWidth / 2.0).
			currentInnerRadius := radius - (borderWidth / 2.0).
			currentOuter := aCanvas shape
				roundedRectangle: bounds
				radii: { currentOuterRadius . currentOuterRadius . currentOuterRadius . currentOuterRadius }.
			currentInner := aCanvas shape
				roundedRectangle: (bounds insetBy: borderWidth)
				radii: { currentInnerRadius . currentInnerRadius . currentInnerRadius . currentInnerRadius }.

			"A concentric inside border keeps the original corner centre fixed:
			the outer edge is the element geometry and the inner radius reduces
			by the full border width."
			idealInnerRadius := (radius - borderWidth) max: 0.
			idealOuter := aCanvas shape
				roundedRectangle: bounds
				radii: { radius . radius . radius . radius }.
			idealInner := aCanvas shape
				roundedRectangle: (bounds insetBy: borderWidth)
				radii: { idealInnerRadius . idealInnerRadius . idealInnerRadius . idealInnerRadius }.

			"Red = the edges implied by the current native Sparta implementation.
			 Green = geometrically concentric edges."
			aCanvas stroke
				path: currentOuter;
				paint: (Color red alpha: 0.9);
				width: 2;
				draw.
			aCanvas stroke
				path: currentInner;
				paint: (Color red alpha: 0.9);
				width: 2;
				draw.
			aCanvas stroke
				path: idealOuter;
				paint: (Color green alpha: 0.9);
				width: 2;
				draw.
			aCanvas stroke
				path: idealInner;
				paint: (Color green alpha: 0.9);
				width: 2;
				draw ];
		yourself.

	stage := BlElement new
		size: 440 @ 300;
		background: Color gray;
		layout: BlFrameLayout new;
		addChild: (card constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]);
		yourself.
	^ stage
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> treatmentCellNamed: aString configure: aBlock borderColor: aColor borderWidth: borderWidth effectWidth: effectWidth intensity: intensity [
	| pane label aptitude |
	aptitude := CFLightBorderAptitude new
		beFlat;
		effectWidth: effectWidth;
		intensity: intensity;
		lightDirection: -1 @ -1;
		yourself.
	aBlock value: aptitude.
	label := BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: Color white);
		text: aString;
		fitContent;
		margin: (BlInsets bottom: 6);
		yourself.
	pane := BrVerticalPane new
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		addChild: label;
		addChild: (self
			cardWith: aptitude
			borderColor: aColor
			borderWidth: borderWidth);
		yourself.
	^ pane
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude borderColor: aColor borderWidth: aNumber [
	^ BlElement new
		clipChildren: false;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c linear weight: 1 ];
		geometry: (BlRoundedRectangleGeometry cornerRadius: 24);
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: aColor width: aNumber);
		addAptitude: anAptitude;
		yourself
]

{ #category : 'private - controls' }
CFLightBorderAptitudeExamples >> colorControlNamed: aString color: initialColor changed: aBlock [
	| row label swatch currentColor |
	currentColor := initialColor.
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 22;
		cellSpacing: 8;
		yourself.
	label := BrLabel new
		hExact: 110;
		vMatchParent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color white; fontSize: 10);
		text: aString;
		yourself.
	swatch := BlElement new
		size: 48 @ 18;
		background: currentColor;
		border: (BlBorder paint: (Color white alpha: 0.45) width: 1);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		allowMeAndChildrenMouseEvents;
		yourself.
	swatch when: BlClickEvent do: [ :event |
		| selected |
		event consumed: true.
		selected := BlBlocUIManager new
			chooseColor: currentColor
			title: 'Border colour'.
		selected ifNotNil: [
			currentColor := selected.
			swatch background: currentColor.
			aBlock value: currentColor ] ].
	row
		addChild: label;
		addChild: swatch.
	^ row
]

{ #category : 'private - controls' }
CFLightBorderAptitudeExamples >> sliderNamed: aString min: minimum max: maximum value: initialValue quantum: quantum changed: aBlock [
	| row label track handle valueLabel pullHandler currentValue positionHandle writeFraction |
	currentValue := initialValue.
	row := BrHorizontalPane new
		hMatchParent;
		vExact: 22;
		cellSpacing: 8;
		yourself.
	label := BrLabel new
		hExact: 110;
		vMatchParent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color white; fontSize: 10);
		text: aString;
		yourself.
	track := BlElement new
		size: 160 @ 12;
		layout: BlFrameLayout new;
		background: (Color black alpha: 0.14);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		allowMeAndChildrenMouseEvents;
		yourself.
	handle := BlElement new
		size: 10 @ 10;
		background: (Color white alpha: 0.85);
		geometry: BlCircleGeometry new;
		allowMeAndChildrenMouseEvents;
		yourself.
	valueLabel := BrLabel new
		hExact: 50;
		vMatchParent;
		aptitude: (BrGlamorousLabelAptitude new foreground: Color white; fontSize: 9);
		yourself.

	positionHandle := [ :aValue |
		| fraction usable x alignment |
		fraction := ((aValue asFloat - minimum) / (maximum - minimum)) min: 1.0 max: 0.0.
		usable := (track extent x - handle extent x) max: 1.
		x := (fraction * usable) rounded.
		alignment := track extent x isZero
			ifTrue: [ 0.0 ]
			ifFalse: [ x / track extent x ].
		handle constraintsDo: [ :c |
			c frame horizontal alignLeftAt: alignment.
			c frame vertical alignCenter ].
		handle relocate: x @ ((track extent y - handle extent y) / 2.0) rounded.
		valueLabel text: aValue printString ].

	writeFraction := [ :aFraction |
		| fraction raw value |
		fraction := aFraction min: 1.0 max: 0.0.
		raw := minimum + (fraction * (maximum - minimum)).
		value := ((raw / quantum) rounded * quantum) min: maximum max: minimum.
		currentValue = value ifFalse: [
			currentValue := value.
			positionHandle value: currentValue.
			aBlock value: currentValue ] ].

	pullHandler := BlPullHandler new
		targetElement: handle;
		beHorizontal;
		disallowOutOfBounds;
		yourself.
	handle addEventHandler: pullHandler.
	handle when: BlPullEvent do: [ :event |
		| usable fraction |
		usable := (track extent x - handle extent x) max: 1.
		fraction := handle constraints position x / usable.
		writeFraction value: fraction ].
	track when: BlClickEvent do: [ :event |
		| local usable fraction |
		local := track globalPointToLocal: event position.
		usable := (track extent x - handle extent x) max: 1.
		fraction := (local x - (handle extent x / 2.0)) / usable.
		writeFraction value: fraction ].

	track addChild: handle.
	row
		addChild: label;
		addChild: track;
		addChild: valueLabel.
	positionHandle value: currentValue.
	^ row
]

