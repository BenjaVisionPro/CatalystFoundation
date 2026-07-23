Class {
	#name : 'CFPhysicsMondrianShowcaseExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> livingBehaviourGraph [
	<gtExample>
	<return: #GtMondrian>
	| mondrian models edges started |
	models := self showcaseModels.
	edges := self showcaseEdges.
	mondrian := GtMondrian new.
	mondrian root
		size: 920 @ 620;
		background: (Color veryVeryDarkGray alpha: 0.96).
	mondrian nodes
		stencil: [ :model | self nodeElementFor: model ];
		with: models.
	mondrian edges
		fromNearestCircle;
		toNearestCircle;
		stencil: [ :edge |
			BlLineElement new
				zIndex: -1;
				border: (BlBorder paint: (Color lightGray alpha: 0.38) width: 2);
				yourself ];
		connect: edges
			from: #key
			to: #value.
	mondrian layout circle radius: 225.
	started := false.
	mondrian root when: BlElementAddedToSceneGraphEvent do: [ :event |
		started ifFalse: [
			started := true.
			self
				startLivingPhysicsIn: mondrian
				models: models
				edges: edges ] ].
	^ mondrian
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> showcaseModels [
	^ #(Catalyst Motion Physics Behaviours Breathing Wind JumpingBean Sparks Mondrian)
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> showcaseEdges [
	^ {
		#Catalyst -> #Motion.
		#Catalyst -> #Physics.
		#Catalyst -> #Mondrian.
		#Physics -> #Behaviours.
		#Motion -> #Breathing.
		#Motion -> #Wind.
		#Behaviours -> #Breathing.
		#Behaviours -> #Wind.
		#Behaviours -> #JumpingBean.
		#Behaviours -> #Sparks }
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> nodeElementFor: aModel [
	| element aptitude |
	aptitude := BrGlamorousLabelAptitude new.
	aptitude foreground: Color white.
	element := BrLabel new
		aptitude: aptitude;
		text: aModel asString;
		size: (aModel = #Catalyst ifTrue: [ 132 @ 56 ] ifFalse: [ 116 @ 46 ]);
		geometry: (BlRoundedRectangleGeometry cornerRadii: (BlCornerRadii radius: 12));
		background: (self colourFor: aModel);
		border: (BlBorder paint: (Color white alpha: 0.28) width: 1);
		addEventHandler: BlPullHandler new;
		yourself.
	element physics excludeDescendantsFromWorld.
	^ element
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> colourFor: aModel [
	aModel = #Catalyst ifTrue: [ ^ Color purple muchLighter ].
	aModel = #Motion ifTrue: [ ^ Color blue muchLighter ].
	aModel = #Physics ifTrue: [ ^ Color green muchLighter ].
	aModel = #Behaviours ifTrue: [ ^ Color orange muchLighter ].
	aModel = #Breathing ifTrue: [ ^ Color cyan muchDarker ].
	aModel = #Wind ifTrue: [ ^ Color lightBlue muchDarker ].
	aModel = #JumpingBean ifTrue: [ ^ Color yellow muchDarker ].
	aModel = #Sparks ifTrue: [ ^ Color red muchLighter ].
	^ Color gray muchLighter
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> startLivingPhysicsIn: aMondrian models: models edges: edges [
	| root nodesByModel nodeElements graphSource world forceDirected breathing wind beans sparks catalyst leaves |
	root := aMondrian root.
	nodesByModel := IdentityDictionary new.
	models do: [ :model |
		nodesByModel
			at: model
			put: (root graph
				nodeAt: model
				ifAbsent: [ self error: 'Mondrian did not create an expected node' ]) ].
	nodeElements := models collect: [ :model | nodesByModel at: model ].
	root graph edgeChildren do: [ :edgeElement |
		edgeElement physics excludeFromWorld ].
	world := root physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 16 milliSeconds;
		synchroniseMembership.
	nodeElements do: [ :node |
		node physics
			linearDamping: 5.5;
			angularDamping: 9.0;
			friction: 0.25;
			restitution: 0.55;
			enablePullInteraction.
		(node physics containWithinWorld)
			restitution: 0.72 ].
	graphSource := CFPhysicsGraphSource
		nodes: [ nodeElements ]
		edges: [ edges ]
		source: [ :edge | nodesByModel at: edge key ]
		target: [ :edge | nodesByModel at: edge value ].
	forceDirected := root physics forceDirectedUsing: graphSource.
	forceDirected
		restLength: 132.0;
		stiffness: 34.0;
		damping: 9.5;
		repulsion: 1500.0;
		maximumRepulsionDistance: 300.0.
	catalyst := nodesByModel at: #Catalyst.
	breathing := root physics breathingUsing: forceDirected.
	breathing
		origin: catalyst;
		intensity: 0.34.
	wind := root physics windAffecting: nodeElements.
	wind
		direction: 1 @ -0.18;
		intensity: 0.11.
	leaves := #(Breathing Wind JumpingBean Sparks) collect: [ :model |
		nodesByModel at: model ].
	beans := root physics jumpingBeanAffecting: leaves.
	beans
		randomSource: (CFPhysicsRandomSource seed: 6723);
		intensity: 0.12.
	sparks := catalyst physics sparks.
	sparks
		randomSource: (CFPhysicsRandomSource seed: 9411);
		direction: 0 @ -1;
		intensity: 0.28;
		sparkFactory: [ self newShowcaseSpark ].
	world startStepping
]

{ #category : 'showcase - mondrian' }
CFPhysicsMondrianShowcaseExamples >> newShowcaseSpark [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: 6 @ 6;
		background: Color yellow;
		border: (BlBorder paint: (Color white alpha: 0.65));
		yourself
]
