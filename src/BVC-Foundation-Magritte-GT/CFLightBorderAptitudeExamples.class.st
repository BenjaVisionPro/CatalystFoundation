Class {
	#name : 'CFLightBorderAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

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

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> lowered [
	<gtExample>
	<return: #BlElement>
	^ self bodyLoweredBorderLowered
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raised [
	<gtExample>
	<return: #BlElement>
	^ self bodyRaisedBorderRaised
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raisedFromTopRight [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: (CFLightBorderAptitude new beRaised; lightDirection: 1 @ -1; yourself)
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
