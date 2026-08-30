"I host one nested Magritte presentation. I am a field-container context, not a form root and not a toolbar destination."

Class {
	#name : 'CFMaPresentationHostElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'presentedObject'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaPresentationHostElement >> initialize [
	super initialize.
	self
		background: Color transparent;
		border: BlBorder empty;
		margin: BlInsets empty;
		cellSpacing: 0;
		hMatchParent;
		vFitContent;
		padding: BlInsets empty.
	self magritte beFieldContainer.
	presentedObject := nil
]

{ #category : 'accessing' }
CFMaPresentationHostElement >> presentedObject [
	^ presentedObject
]

{ #category : 'accessing' }
CFMaPresentationHostElement >> presentedObject: anObject [
	presentedObject := anObject
]

{ #category : 'testing' }
CFMaPresentationHostElement >> presentsObject: anObject [
	^ presentedObject == anObject
]
