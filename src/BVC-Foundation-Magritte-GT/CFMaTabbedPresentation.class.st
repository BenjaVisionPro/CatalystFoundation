"I present the current Foundation field styling with Magritte groups as Brick tabs."

Class {
	#name : 'CFMaTabbedPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'tabGroup'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations'
}

{ #category : 'api - building' }
CFMaTabbedPresentation >> build [
	tabGroup := nil.
	^ super build
]

{ #category : 'private - groups' }
CFMaTabbedPresentation >> ensureTabGroup [
	tabGroup ifNotNil: [ ^ tabGroup ].

	tabGroup := BrTabGroup new
		hMatchParent;
		vFitContent;
		aptitude: BrGlamorousTabGroupAptitude new;
		yourself.
	self hostElement addChild: tabGroup.
	^ tabGroup
]

{ #category : 'private - groups' }
CFMaTabbedPresentation >> newGroupNamed: aGroup [
	| aContainer aTab |
	aContainer := self newFieldContainer.
	aTab := BrTab new
		aptitude: BrGlamorousTabAptitude new;
		label: aGroup asString;
		stencil: [ aContainer ];
		yourself.

	self ensureTabGroup addTab: aTab.
	^ aContainer
]
