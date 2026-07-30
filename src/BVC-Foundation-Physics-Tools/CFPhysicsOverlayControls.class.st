Class {
	#name : 'CFPhysicsOverlayControls',
	#superclass : 'Object',
	#instVars : [ 'overlay', 'element', 'bodiesToggle', 'contactsToggle', 'springsToggle', 'jointsToggle' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
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
CFPhysicsOverlayControls >> contactsEnabled [ ^ contactsToggle isActivated ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> springsEnabled [ ^ springsToggle isActivated ]

{ #category : 'testing' }
CFPhysicsOverlayControls >> jointsEnabled [ ^ jointsToggle isActivated ]

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
	element addChild: bodiesToggle.
	contactsToggle := self contactsToggle.
	element addChild: contactsToggle.
	springsToggle := self springsToggle.
	element addChild: springsToggle.
	element addChild: (self unavailableToggleLabel: 'Forces').
	element addChild: (self unavailableToggleLabel: 'Anchors').
	jointsToggle := self jointsToggle.
	element addChild: jointsToggle
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


{ #category : 'private - building' }
CFPhysicsOverlayControls >> springsToggle [
	| toggle |
	toggle := BrToggle new
		id: #cfPhysicsSpringsOverlayToggle;
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: 'Springs';
		activate;
		yourself.
	toggle
		when: BrToggleActivatedEvent do: [ overlay springsEnabled: true ];
		when: BrToggleDeactivatedEvent do: [ overlay springsEnabled: false ].
	^ toggle
]


{ #category : 'private - building' }
CFPhysicsOverlayControls >> jointsToggle [
	| toggle |
	toggle := BrToggle new
		id: #cfPhysicsJointsOverlayToggle;
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: 'Joints';
		activate;
		yourself.
	toggle
		when: BrToggleActivatedEvent do: [ overlay jointsEnabled: true ];
		when: BrToggleDeactivatedEvent do: [ overlay jointsEnabled: false ].
	^ toggle
]

{ #category : 'private - building' }
CFPhysicsOverlayControls >> unavailableToggleLabel: aString [
	^ BrToggle new
		aptitude: BrGlamorousToggleWithLabelAptitude new;
		label: aString;
		disable;
		yourself
]

{ #category : 'controlling' }
CFPhysicsOverlayControls >> release [
	element ifNotNil: [
		element hasParent ifTrue: [ element removeFromParent ] ]
]
