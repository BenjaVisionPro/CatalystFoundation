"I am responsible for presenting a relation as a bordered Foundation surface with content laid out naturally inside its structural border."

Class {
	#name : 'CFMaRelationSurfaceElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'cornerRadius',
		'footerElement'
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
		background: (Color black alpha: 0.025);
		border: (BlBorder paint: (Color black alpha: 0.10) width: 2);
		outskirts: BlOutskirts inside;
		geometry: (BlRoundedRectangleGeometry cornerRadius: cornerRadius);
		addAptitude: CFMaActiveSelectionAptitude new;
		addAptitude: CFMaRelationSurfaceAptitude new;
		addAptitude: (CFLightBorderAptitude new
			beFlat;
			lowerBodyInside;
			yourself).

	self updateSurfaceLayout
]

{ #category : 'children' }
CFMaRelationSurfaceElement >> addContentChild: anElement [
	super addChild: anElement.
	^ anElement
]

{ #category : 'children' }
CFMaRelationSurfaceElement >> addFooterChild: anElement [
	footerElement := anElement.
	self updateFooterGeometry.
	^ self addContentChild: anElement
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> border: aBorder [
	super border: aBorder.
	self updateSurfaceLayout
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> cornerRadius [
	^ cornerRadius
]

{ #category : 'accessing' }
CFMaRelationSurfaceElement >> cornerRadius: aNumber [
	cornerRadius := aNumber.
	self geometry: (BlRoundedRectangleGeometry cornerRadius: cornerRadius).
	self updateFooterGeometry
]

{ #category : 'private - geometry' }
CFMaRelationSurfaceElement >> innerCornerRadius [
	^ (cornerRadius - self border width) max: 0
]

{ #category : 'private - geometry' }
CFMaRelationSurfaceElement >> updateFooterGeometry [
	| anInnerRadius |
	footerElement ifNil: [ ^ self ].

	anInnerRadius := self innerCornerRadius.
	footerElement geometry: (BlRoundedRectangleGeometry
		cornerRadii: (BlCornerRadii new
			topLeft: 0;
			topRight: 0;
			bottomRight: anInnerRadius;
			bottomLeft: anInnerRadius;
			yourself))
]

{ #category : 'private - layout' }
CFMaRelationSurfaceElement >> updateSurfaceLayout [
	self padding: (BlInsets all: self border width).
	self updateFooterGeometry
]
