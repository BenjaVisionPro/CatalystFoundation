Class {
	#name : 'CFMaDetailAddIconElement',
	#superclass : 'BlElement',
	#instVars : [
		'icon'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'instance creation' }
CFMaDetailAddIconElement class >> size: anExtent [
	^ self new
		iconSize: anExtent;
		yourself
]

{ #category : 'initialization' }
CFMaDetailAddIconElement >> initialize [
	super initialize.
	icon := FontAwesomeIcons defaultStyle icon: #circlePlus.
	icon color: CFMaDetailColours secondaryForeground.
	self
		layout: BlFrameLayout new;
		background: Color transparent;
		border: BlBorder empty;
		addChild: icon.
	icon constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ]
]

{ #category : 'accessing' }
CFMaDetailAddIconElement >> iconSize: anExtent [
	icon size: anExtent.
	self size: anExtent
]

{ #category : 'appearance' }
CFMaDetailAddIconElement >> hovered: aBoolean [
	icon color: (aBoolean
		ifTrue: [ CFMaDetailColours highlight ]
		ifFalse: [ CFMaDetailColours secondaryForeground ])
]
