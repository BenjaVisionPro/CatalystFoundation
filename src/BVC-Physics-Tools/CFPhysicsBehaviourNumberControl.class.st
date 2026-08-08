"I combine a retained horizontal scrubber with precise direct entry for one numeric live Behaviour configuration value. My display range is an editing aid, not a validation range: direct entry may expand it."
Class {
	#name : 'CFPhysicsBehaviourNumberControl',
	#superclass : 'Object',
	#instVars : [ 'behaviour', 'description', 'element', 'track', 'handle', 'editor', 'minimum', 'maximum', 'updating', 'pullHandler' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBehaviourNumberControl class >> on: aBehaviour description: aDescription [
	^ self new behaviour: aBehaviour; description: aDescription; initializeControl; yourself
]

{ #category : 'private - initialization' }
CFPhysicsBehaviourNumberControl >> behaviour: anObject [ behaviour := anObject ]
{ #category : 'private - initialization' }
CFPhysicsBehaviourNumberControl >> description: anObject [ description := anObject ]
{ #category : 'accessing' }
CFPhysicsBehaviourNumberControl >> element [ ^ element ]
{ #category : 'accessing' }
CFPhysicsBehaviourNumberControl >> editor [ ^ editor ]
{ #category : 'accessing' }
CFPhysicsBehaviourNumberControl >> track [ ^ track ]
{ #category : 'accessing' }
CFPhysicsBehaviourNumberControl >> handle [ ^ handle ]

{ #category : 'initialization' }
CFPhysicsBehaviourNumberControl >> initializeControl [
	| value |
	updating := false.
	value := description read: behaviour.
	self establishRangeFor: value.
	track := BlElement new
		size: 98 @ 12;
		layout: BlFrameLayout new;
		background: (Color black alpha: 0.08);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		allowMeAndChildrenMouseEvents;
		yourself.
	handle := BlElement new
		size: 10 @ 10;
		background: (Color black alpha: 0.55);
		geometry: BlCircleGeometry new;
		allowMeAndChildrenMouseEvents;
		yourself.
	pullHandler := BlPullHandler new targetElement: handle; beHorizontal; disallowOutOfBounds; yourself.
	handle addEventHandler: pullHandler.
	handle when: BlPullEvent do: [ :event | self handlePulled ].
	track when: BlClickEvent do: [ :event | self trackClicked: event ].
	track addChild: handle.
	editor := BrEditor new
		hExact: 56;
		vExact: 18;
		inputFilter: BrTextEditorNoLineBreakInputFilter new;
		aptitude: BrGlamorousRegularEditorAptitude new;
		padding: (BlInsets top: 1 left: 3 bottom: 1 right: 3);
		yourself.
	editor editor when: BrTextEditorModifiedEvent do: [ :event | self editorModified ].
	element := BrHorizontalPane new
		hExact: 162;
		vExact: 18;
		cellSpacing: 4;
		addChild: track;
		addChild: editor;
		yourself.
	self refresh
]

{ #category : 'private - range' }
CFPhysicsBehaviourNumberControl >> establishRangeFor: aNumber [
	| value magnitude |
	value := aNumber asFloat.
	magnitude := value abs max: 1.0.
	value negative
		ifTrue: [ minimum := magnitude * -2.0. maximum := magnitude * 2.0 ]
		ifFalse: [ minimum := 0.0. maximum := magnitude * 2.0 ]
]

{ #category : 'private - range' }
CFPhysicsBehaviourNumberControl >> expandRangeToInclude: aNumber [
	| value span |
	value := aNumber asFloat.
	(value between: minimum and: maximum) ifTrue: [ ^ self ].
	span := (maximum - minimum) max: 1.0.
	[ value < minimum ] whileTrue: [ minimum := minimum - span. span := span * 2.0 ].
	span := (maximum - minimum) max: 1.0.
	[ value > maximum ] whileTrue: [ maximum := maximum + span. span := span * 2.0 ]
]

{ #category : 'private - editing' }
CFPhysicsBehaviourNumberControl >> editorModified [
	| value |
	updating ifTrue: [ ^ self ].
	[ value := description fromString: editor text asString ] on: Error do: [ :error | ^ self ].
	description write: value to: behaviour.
	self expandRangeToInclude: (description read: behaviour).
	self positionHandleFor: (description read: behaviour).
	^ self
]

{ #category : 'private - editing' }
CFPhysicsBehaviourNumberControl >> trackClicked: anEvent [
	| local usable fraction value |
	local := track globalPointToLocal: anEvent position.
	usable := (track extent x - handle extent x) max: 1.
	fraction := ((local x - (handle extent x / 2.0)) / usable) min: 1.0 max: 0.0.
	value := minimum + (fraction * (maximum - minimum)).
	self writeValue: value
]

{ #category : 'private - editing' }
CFPhysicsBehaviourNumberControl >> handlePulled [
	| usable fraction value |
	updating ifTrue: [ ^ self ].
	usable := (track extent x - handle extent x) max: 1.
	fraction := (handle constraints position x / usable) min: 1.0 max: 0.0.
	value := minimum + (fraction * (maximum - minimum)).
	self writeValue: value
]

{ #category : 'private - editing' }
CFPhysicsBehaviourNumberControl >> writeValue: aNumber [
	description write: aNumber to: behaviour.
	self refresh.
	^ self
]

{ #category : 'private - presentation' }
CFPhysicsBehaviourNumberControl >> positionHandleFor: aNumber [
	| usable fraction x alignment |
	usable := (track extent x - handle extent x) max: 1.
	fraction := ((aNumber asFloat - minimum) / (maximum - minimum)) min: 1.0 max: 0.0.
	x := (fraction * usable) rounded.
	alignment := track extent x isZero
		ifTrue: [ 0.0 ]
		ifFalse: [ x / track extent x ].
	handle constraintsDo: [ :c |
		c frame horizontal alignLeftAt: alignment.
		c frame vertical alignCenter ].
	handle relocate: x @ ((track extent y - handle extent y) / 2.0) rounded
]

{ #category : 'updating' }
CFPhysicsBehaviourNumberControl >> refresh [
	| value string |
	behaviour ifNil: [ ^ self ].
	value := description read: behaviour.
	self expandRangeToInclude: value.
	string := value printString.
	updating := true.
	editor text asString = string ifFalse: [ editor text: string ].
	self positionHandleFor: value.
	updating := false.
	^ self
]

{ #category : 'controlling' }
CFPhysicsBehaviourNumberControl >> release [
	pullHandler ifNotNil: [ handle removeEventHandler: pullHandler ].
	^ self
]
