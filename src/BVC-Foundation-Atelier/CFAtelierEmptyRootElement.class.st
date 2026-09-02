"I am the empty root editing area of an Atelier that does not yet have an object.

I am not a Magritte presentation. I only provide a visible place where Atelier can accept a supplied root object. Once a root is accepted, my owner replaces me with the ordinary CFAtelierViewModel form for that object."
Class {
	#name : 'CFAtelierEmptyRootElement',
	#superclass : 'BrFrame',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierEmptyRootElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vExact: 120;
		padding: (BlInsets all: 16).
	self addChild: (BrLabel new
		fitContent;
		aptitude: BrGlamorousLabelAptitude new;
		text: 'Drop an object here';
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself)
]
