"I present the compact diagnostic visibility controls for a Physics overlay. Constraints covers both spring and non-spring joint diagnostics."
Class {
	#name : 'CFPhysicsOverlayControls',
	#superclass : 'Object',
	#instVars : [ 'overlay', 'element', 'bodiesToggle', 'constraintsToggle', 'contactsToggle' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayControls class >> on: anOverlay [
	^ self new overlay: anOverlay; initializeControls; yourself
]

{ #category : 'private - initialization' }
CFPhysicsOverlayControls >> overlay: anOverlay [ overlay := anOverlay ]

{ #category : 'accessing' }
CFPhysicsOverlayControls >> element [ ^ element ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> bodiesEnabled [ ^ bodiesToggle isActivated ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> constraintsEnabled [ ^ constraintsToggle isActivated ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> contactsEnabled [ ^ contactsToggle isActivated ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> springsEnabled [ ^ self constraintsEnabled ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> jointsEnabled [ ^ self constraintsEnabled ]

{ #category : 'initialization' }
CFPhysicsOverlayControls >> initializeControls [
	element := BrVerticalPane new
		id: #cfPhysicsOverlayFilterControls;
		fitContent;
		cellSpacing: 0;
		padding: (BlInsets all: 4);
		background: (Color black alpha: 0.08);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 14));
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		margin: (BlInsets right: 14);
		yourself.
	bodiesToggle := self bodiesToggle.
	constraintsToggle := self constraintsToggle.
	contactsToggle := self contactsToggle.
	element
		addChild: bodiesToggle;
		addChild: constraintsToggle;
		addChild: contactsToggle
]

{ #category : 'private - building' }
CFPhysicsOverlayControls >> bodiesToggle [
	| toggle |
	toggle := BrToggle new
		id: #cfPhysicsBodiesOverlayToggle;
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: 'Bodies';
		activate;
		yourself.
	toggle
		when: BrToggleActivatedEvent do: [ overlay bodiesEnabled: true ];
		when: BrToggleDeactivatedEvent do: [ overlay bodiesEnabled: false ].
	^ toggle
]

{ #category : 'private - building' }
CFPhysicsOverlayControls >> constraintsToggle [
	| toggle |
	toggle := BrToggle new
		id: #cfPhysicsConstraintsOverlayToggle;
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: 'Constraints';
		activate;
		yourself.
	toggle
		when: BrToggleActivatedEvent do: [ overlay constraintsEnabled: true ];
		when: BrToggleDeactivatedEvent do: [ overlay constraintsEnabled: false ].
	^ toggle
]

{ #category : 'private - building' }
CFPhysicsOverlayControls >> contactsToggle [
	| toggle |
	toggle := BrToggle new
		id: #cfPhysicsContactsOverlayToggle;
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: 'Contacts';
		activate;
		yourself.
	toggle
		when: BrToggleActivatedEvent do: [ overlay contactsEnabled: true ];
		when: BrToggleDeactivatedEvent do: [ overlay contactsEnabled: false ].
	^ toggle
]

{ #category : 'controlling' }
CFPhysicsOverlayControls >> release [
	element ifNotNil: [ element hasParent ifTrue: [ element removeFromParent ] ]
]
