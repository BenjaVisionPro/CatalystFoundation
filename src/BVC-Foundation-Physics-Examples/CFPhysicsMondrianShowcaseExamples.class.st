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
	| root nodesByModel nodeElements world forceDirected breathing wind beans sparks catalyst leaves |
	root := aMondrian root.
	nodesByModel := IdentityDictionary new.
	models do: [ :model |
		nodesByModel
			at: model
			put: (root graph
				nodeAt: model
				ifAbsent: [ self error: 'Mondrian did not create an expected node' ]) ].
	nodeElements := models collect: [ :model | nodesByModel at: model ].
	world := aMondrian physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 16 milliSeconds.
	nodeElements withIndexDo: [ :node :index |
		| angle |
		angle := (index - 1) * Float twoPi / nodeElements size.
		node physics
			density: 0.012;
			linearDamping: 1.35;
			angularDamping: 5.0;
			friction: 0.18;
			restitution: 0.68;
			preventSleeping;
			velocity: (((angle cos) @ (angle sin)) * 34.0);
			enablePullInteraction.
		(node physics containWithinWorld)
			restitution: 0.78 ].
	forceDirected := aMondrian physics forceDirected.
	forceDirected
		restLength: 118.0;
		stiffness: 52.0;
		damping: 7.0;
		repulsion: 5200.0;
		maximumRepulsionDistance: 340.0.
	catalyst := nodesByModel at: #Catalyst.
	breathing := root physics breathingUsing: forceDirected.
	breathing
		origin: catalyst;
		intensity: 0.34.
	wind := root physics windAffecting: nodeElements.
	wind
		direction: 1 @ -0.18;
		intensity: 0.28.
	leaves := #(Breathing Wind JumpingBean Sparks) collect: [ :model |
		nodesByModel at: model ].
	beans := root physics jumpingBeanAffecting: leaves.
	beans
		randomSource: (CFPhysicsRandomSource seed: 6723);
		intensity: 0.38.
	sparks := catalyst physics sparks.
	sparks
		randomSource: (CFPhysicsRandomSource seed: 9411);
		direction: 0 @ -1;
		intensity: 0.42;
		minimumLaunchImpulse: 760.0;
		maximumLaunchImpulse: 1380.0;
		lifetime: 0.9;
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
