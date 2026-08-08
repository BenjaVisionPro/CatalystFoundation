"I present the public live configuration of one Physics Behaviour in the floating Physics inspector. I build from the Behaviour Magritte descriptions, write edits directly through those descriptions, and keep controls synchronised with the running Behaviour."
Class {
	#name : 'CFPhysicsBehaviourInspector',
	#superclass : 'Object',
	#instVars : [ 'element', 'titleElement', 'copyButton', 'scrollPane', 'dataElement', 'behaviour', 'controlsByDescription', 'preferredDataHeight' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBehaviourInspector class >> newContent [
	^ self new initializeContent; yourself
]

{ #category : 'accessing' }
CFPhysicsBehaviourInspector >> element [ ^ element ]

{ #category : 'sizing' }
CFPhysicsBehaviourInspector >> panelWidth [ ^ 300 ]

{ #category : 'initialization' }
CFPhysicsBehaviourInspector >> initializeContent [
	controlsByDescription := IdentityDictionary new.
	preferredDataHeight := 0.
	titleElement := BrLabel new
		hMatchParent;
		vExact: 16;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.7); fontSize: 10);
		yourself.
	copyButton := BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons clipboard;
		label: 'Copy source';
		action: [ Clipboard clipboardText: behaviour configurationSource ];
		yourself.
	dataElement := BrVerticalPane new hMatchParent; vFitContent; cellSpacing: 2; yourself.
	scrollPane := BrScrollPane new
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vExact: 0;
		content: dataElement;
		yourself.
	element := BrVerticalPane new
		hMatchParent;
		vExact: 16;
		cellSpacing: 3;
		addChild: (BrHorizontalPane new
			hMatchParent;
			vExact: 16;
			addChild: titleElement;
			addChild: copyButton;
			yourself);
		addChild: scrollPane;
		yourself
]

{ #category : 'inspecting' }
CFPhysicsBehaviourInspector >> inspect: aBehaviour [
	behaviour := aBehaviour.
	titleElement text: aBehaviour class name asString.
	self rebuild.
	self refresh.
	^ self
]

{ #category : 'building' }
CFPhysicsBehaviourInspector >> rebuild [
	| grouped groupNames |
	dataElement removeChildren.
	controlsByDescription removeAll.
	preferredDataHeight := 0.
	grouped := Dictionary new.
	behaviour configurationDescriptions do: [ :description |
		(grouped at: description group ifAbsentPut: [ OrderedCollection new ]) add: description ].
	groupNames := grouped keys sorted: [ :first :second |
		((grouped at: first) first priority) < ((grouped at: second) first priority) ].
	groupNames do: [ :groupName |
		self addGroup: groupName descriptions: (grouped at: groupName) ].
	^ self
]

{ #category : 'building' }
CFPhysicsBehaviourInspector >> addGroup: aName descriptions: descriptions [
	| group |
	group := BrVerticalPane new hMatchParent; vFitContent; cellSpacing: 1; yourself.
	group addChild: (BrLabel new
		hMatchParent;
		vExact: 11;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.38); fontSize: 8);
		text: aName asUppercase;
		yourself).
	descriptions do: [ :description | group addChild: (self rowFor: description) ].
	dataElement addChild: group.
	preferredDataHeight := preferredDataHeight + 11 + (descriptions size * 20) + descriptions size + 3
]

{ #category : 'building' }
CFPhysicsBehaviourInspector >> rowFor: aDescription [
	| row label control |
	row := BrHorizontalPane new hMatchParent; vExact: 20; cellSpacing: 4; yourself.
	label := BrLabel new
		hExact: 108;
		vMatchParent;
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.58); fontSize: 8);
		text: aDescription label;
		yourself.
	control := (aDescription isKindOf: MANumberDescription)
		ifTrue: [ CFPhysicsBehaviourNumberControl on: behaviour description: aDescription ]
		ifFalse: [
			(aDescription isKindOf: MABooleanDescription)
				ifTrue: [ CFPhysicsBehaviourBooleanControl on: behaviour description: aDescription ]
				ifFalse: [ CFPhysicsBehaviourValueControl on: behaviour description: aDescription ] ].
	controlsByDescription at: aDescription put: control.
	row addChild: label; addChild: control element.
	^ row
]

{ #category : 'updating' }
CFPhysicsBehaviourInspector >> refresh [
	controlsByDescription valuesDo: #refresh.
	^ self
]

{ #category : 'clearing' }
CFPhysicsBehaviourInspector >> clear [
	behaviour := nil.
	controlsByDescription valuesDo: #release.
	controlsByDescription removeAll.
	dataElement removeChildren.
	^ self
]

{ #category : 'sizing' }
CFPhysicsBehaviourInspector >> preferredHeight [
	^ 16 + 9 + preferredDataHeight
]

{ #category : 'sizing' }
CFPhysicsBehaviourInspector >> fitWithinHeight: aHeight [
	| bodyHeight |
	bodyHeight := (aHeight - 25) max: 0.
	element vExact: aHeight.
	scrollPane vExact: bodyHeight.
	^ self
]
