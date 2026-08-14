"I am responsible for presenting a relation as a bordered Foundation surface whose content is kept inside the structural border."

Class {
	#name : 'CFMaRelationSurfaceElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'contentElement',
		'cornerRadius'
	],
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaRelationSurfaceElement >> initialize [
	super initialize.

	cornerRadius := 6.

	self
		matchParent;
		vFitContent;
		focusability: BlFocusability after;
		cellSpacing: 0;
		padding: BlInsets empty;
		background: (Color black alpha: 0.025);
		border: (BlBorder paint: (Color black alpha: 0.10) width: 2);
		outskirts: BlOutskirts inside;
		geometry: (BlRoundedRectangleGeometry cornerRadius: cornerRadius);
		clipChildren: true;
		addAptitude: (CFLightBorderAptitude new
			beFlat;
			lowerBodyInside;
			yourself).

	contentElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		background: Color transparent;
		yourself.

	super addChild: contentElement.
	self updateContentGeometry
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> contentElement [
	^ contentElement
]

{ #category : 'children' }
CFMaRelationSurfaceElement >> addContentChild: anElement [
	contentElement addChild: anElement.
	^ anElement
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> cornerRadius [
	^ cornerRadius
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> cornerRadius: aNumber [
	cornerRadius := aNumber.
	self
		geometry: (BlRoundedRectangleGeometry cornerRadius: cornerRadius);
		updateContentGeometry
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> border: aBorder [
	super border: aBorder.
	contentElement ifNotNil: [ self updateContentGeometry ]
]

{ #category : 'private - layout' }
CFMaRelationSurfaceElement >> updateContentGeometry [
	| aBorderWidth anInnerRadius |
	contentElement ifNil: [ ^ self ].

	aBorderWidth := self border width.
	anInnerRadius := (cornerRadius - aBorderWidth) max: 0.

	self padding: (BlInsets all: aBorderWidth).

	contentElement
		margin: BlInsets empty;
		geometry: BlRectangleGeometry new;
		clipChildren: false.
	^ self
]


{ #category : 'drawing' }
CFMaRelationSurfaceElement >> drawChildrenOnSpartaCanvas: aCanvas [
	| aBorderWidth anInnerRadius anInset anInnerBounds |
	self hasChildren ifFalse: [ ^ self ].

	aBorderWidth := self border width.
	anInnerRadius := (cornerRadius - aBorderWidth) max: 0.
	anInset := aBorderWidth @ aBorderWidth.
	anInnerBounds := anInset corner: self extent - anInset.

	aCanvas clip
		by: [
			aCanvas shape
				roundedRectangle: anInnerBounds
				radii: {
					anInnerRadius.
					anInnerRadius.
					anInnerRadius.
					anInnerRadius } ]
		during: [
			self children sortedByElevation
				do: [ :anElement | anElement fullDrawOnSpartaCanvas: aCanvas ] ]
]
