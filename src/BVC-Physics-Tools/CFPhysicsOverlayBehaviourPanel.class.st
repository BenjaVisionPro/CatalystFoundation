"
I present the running Behaviours for a Physics overlay and let one Behaviour become the overlay scope. I reconcile only when the world's Behaviour revision changes.
"
Class {
	#name : 'CFPhysicsOverlayBehaviourPanel',
	#superclass : 'Object',
	#instVars : [
		'overlay',
		'world',
		'element',
		'headerButton',
		'listElement',
		'expanded',
		'lastBehaviourRevision'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsOverlayBehaviourPanel class >> on: anOverlay [
	^ self new
		overlay: anOverlay;
		world: anOverlay world;
		initializePanel;
		yourself
]

{ #category : 'private - building' }
CFPhysicsOverlayBehaviourPanel >> buttonFor: aBehaviour selected: isSelected [
	^ BrButton new
		aptitude: BrGlamorousButtonWithLabelAptitude;
		label: (isSelected
			ifTrue: [ '● ', aBehaviour class name asString ]
			ifFalse: [ aBehaviour class name asString ]);
		action: [
			overlay selectBehaviour: aBehaviour.
			expanded := false.
			self rebuild ];
		yourself
]

{ #category : 'accessing' }
CFPhysicsOverlayBehaviourPanel >> element [ ^ element
]

{ #category : 'accessing' }
CFPhysicsOverlayBehaviourPanel >> headerButton [ ^ headerButton
]

{ #category : 'initialization' }
CFPhysicsOverlayBehaviourPanel >> initializePanel [
	expanded := false.
	lastBehaviourRevision := nil.
	element := BrVerticalPane new
		id: #cfPhysicsOverlayBehaviourPanel;
		fitContent;
		cellSpacing: 2;
		padding: (BlInsets all: 4);
		background: (Color black alpha: 0.08);
		border: (BlBorder paint: (Color black alpha: 0.12) width: 1);
		effect: (BlBlurBelowEffect radius: 14);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 12));
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		margin: (BlInsets top: 84 right: 14);
		yourself.
	headerButton := BrButton new
		id: #cfPhysicsOverlayBehavioursButton;
		aptitude: BrGlamorousButtonWithIconCircularAptitude;
		icon: BrGlamorousVectorIcons settings;
		label: 'Behaviours';
		size: 34 @ 34;
		action: [ self toggleExpanded ];
		yourself.
	listElement := BrVerticalPane new
		fitContent;
		cellSpacing: 1;
		yourself.
	element addChild: headerButton.
	self refresh
]

{ #category : 'testing' }
CFPhysicsOverlayBehaviourPanel >> isExpanded [ ^ expanded
]

{ #category : 'accessing' }
CFPhysicsOverlayBehaviourPanel >> listElement [ ^ listElement
]

{ #category : 'private - initialization' }
CFPhysicsOverlayBehaviourPanel >> overlay: anOverlay [ overlay := anOverlay
]

{ #category : 'updating' }
CFPhysicsOverlayBehaviourPanel >> rebuild [
	| behaviours selected |
	behaviours := world behaviours.
	selected := overlay selectedBehaviour.
	element visibility: (behaviours isEmpty
		ifTrue: [ BlVisibility gone ]
		ifFalse: [ BlVisibility visible ]).
	behaviours isEmpty ifTrue: [
		expanded := false.
		listElement removeChildren.
		listElement hasParent ifTrue: [ listElement removeFromParent ].
		^ self ].
	listElement removeChildren.
	expanded ifTrue: [
		behaviours do: [ :behaviour |
			listElement addChild: (self buttonFor: behaviour selected: behaviour == selected) ].
		listElement hasParent ifFalse: [ element addChild: listElement ] ]
	ifFalse: [ listElement hasParent ifTrue: [ listElement removeFromParent ] ].
	^ self
]

{ #category : 'updating' }
CFPhysicsOverlayBehaviourPanel >> refresh [
	lastBehaviourRevision = world behaviourRevision ifTrue: [ ^ self ].
	lastBehaviourRevision := world behaviourRevision.
	self rebuild.
	^ self
]

{ #category : 'controlling' }
CFPhysicsOverlayBehaviourPanel >> release [
	element ifNotNil: [ element hasParent ifTrue: [ element removeFromParent ] ]
]

{ #category : 'private - actions' }
CFPhysicsOverlayBehaviourPanel >> toggleExpanded [
	expanded := expanded not.
	self rebuild.
	^ self
]

{ #category : 'private - initialization' }
CFPhysicsOverlayBehaviourPanel >> world: aWorld [ world := aWorld
]
