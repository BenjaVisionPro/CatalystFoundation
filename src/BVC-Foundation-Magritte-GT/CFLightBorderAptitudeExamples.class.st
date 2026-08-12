Class {
	#name : 'CFLightBorderAptitudeExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude [
	^ self elementWith: anAptitude borderWidth: 1
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> elementWith: anAptitude borderWidth: aNumber [
	^ self stageWith: (self cardWith: anAptitude borderWidth: aNumber)
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> cardWith: anAptitude borderWidth: aNumber [
	^ BlElement new
		size: 280 @ 160;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		background: (Color black alpha: 0.1);
		outskirts: BlOutskirts inside;
		border: (BlBorder paint: (Color blue alpha: 0.5) width: aNumber);
		addAptitude: anAptitude;
		yourself
]

{ #category : 'private - instance creation' }
CFLightBorderAptitudeExamples >> stageWith: aCard [
	^ BlElement new
		size: 360 @ 240;
		background: (Color gray alpha: 0.35);
		layout: BlFrameLayout new;
		addChild: (aCard constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]);
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
	^ self lowered
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> lowered [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new beLowered
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> raised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new
]

{ #category : 'examples' }
CFLightBorderAptitudeExamples >> wideRaised [
	<gtExample>
	<return: #BlElement>
	^ self elementWith: CFLightBorderAptitude new borderWidth: 3
]
