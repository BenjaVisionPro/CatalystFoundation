Class {
	#name : 'CFLightBorderAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude [
	^ BlElement new
		size: 280 @ 160;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		background: (Color black alpha: 0.1);
		addAptitude: anAptitude;
		yourself
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> flat [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beFlat
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> inset [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beInset
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new
]

{ #category : 'examples - comparison' }
CFLightBorderAptitudeExamples >> runtimePrototypeComparison [
	"Diagnostic only: the left element uses the Runtime prototype and the
	right element uses the Foundation implementation. Both use the same
	geometry, size, and surface so a visual difference is renderer-related."
	<gtExample>
	<return: #BlElement>
	| aPane prototypeClass |
	prototypeClass := Smalltalk
		at: #CFLitBorderAptitude
		ifAbsent: [ self error: 'CFLitBorderAptitude is not loaded' ].
	aPane := BrHorizontalPane new
		cellSpacing: 16;
		hFitContent;
		vFitContent.
	aPane
		addChild: (self elementWith: prototypeClass new);
		addChild: (self elementWith: CFLightBorderAptitude new).
	^ aPane
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> wideRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new width: 3)
]
