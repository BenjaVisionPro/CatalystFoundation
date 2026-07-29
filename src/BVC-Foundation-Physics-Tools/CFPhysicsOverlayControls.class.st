Class {
	#name : 'CFPhysicsOverlayControls',
	#superclass : 'Object',
	#instVars : [ 'overlay', 'element', 'contactsToggle' ],
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
CFPhysicsOverlayControls >> contactsEnabled [ ^ contactsToggle isActivated ]

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
	element addChild: (self unavailableToggleLabel: 'Bodies').
	contactsToggle := self contactsToggle.
	element addChild: contactsToggle.
	element addChild: (self unavailableToggleLabel: 'Springs').
	element addChild: (self unavailableToggleLabel: 'Forces').
	element addChild: (self unavailableToggleLabel: 'Anchors').
	element addChild: (self unavailableToggleLabel: 'Joints')
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
