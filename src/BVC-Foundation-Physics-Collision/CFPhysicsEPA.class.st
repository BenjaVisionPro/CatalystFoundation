Class {
	#name : 'CFPhysicsEPA',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsEPA class >> manifoldBetween: firstBody and: secondBody fromSimplex: simplexArray [
	| polytope edge support supportDistance contactPoint |
	polytope := simplexArray asOrderedCollection.
	(self signedAreaOf: polytope) < 0 ifTrue: [ polytope := polytope reversed asOrderedCollection ].
	Transcript show: '=== CFPhysics EPA diagnostic ==='; cr.
	Transcript show: 'initial polytope='; show: (polytope collect: [ :each | each point ]) printString; cr.
	1 to: 48 do: [ :iteration |
		edge := self closestEdgeOf: polytope.
		Transcript
			show: 'iteration='; show: iteration printString;
			show: ' edgeFirst='; show: edge first point printString;
			show: ' edgeSecond='; show: edge second point printString;
			show: ' normal='; show: edge third printString;
			show: ' edgeDistance='; show: edge fourth printString; cr.
		support := CFPhysicsGJK
			supportBetween: firstBody
			and: secondBody
			inDirection: edge third.
		supportDistance := self dot: support point with: edge third.
		Transcript
			show: ' support='; show: support point printString;
			show: ' supportDistance='; show: supportDistance printString;
			show: ' duplicate='; show: (polytope anySatisfy: [ :each | each point = support point ]) printString; cr.
		(supportDistance closeTo: edge fourth) ifTrue: [
			Transcript show: 'converged normal='; show: edge third printString; cr; show: '=== end EPA diagnostic ==='; cr.
			contactPoint := self contactPointOnEdgeFrom: edge first to: edge second.
			^ (CFPhysicsManifold
				normal: edge third
				penetration: supportDistance)
				points: { contactPoint };
				yourself ].
		polytope add: support beforeIndex: edge fifth ].
	Transcript show: 'iteration limit reached'; cr; show: '=== end EPA diagnostic ==='; cr.
	^ nil
]


{ #category : 'private' }
CFPhysicsEPA class >> closestEdgeOf: polytope [
	| bestFirst bestSecond bestNormal bestDistance bestInsert count |
	bestDistance := Float infinity.
	count := polytope size.
	1 to: count do: [ :index |
		| nextIndex first second edge normal distance |
		nextIndex := index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ].
		first := polytope at: index.
		second := polytope at: nextIndex.
		edge := second point - first point.
		normal := edge y @ edge x negated.
		normal r > 0 ifTrue: [ normal := normal / normal r ].
		distance := self dot: normal with: first point.
		distance < 0 ifTrue: [
			normal := normal negated.
			distance := distance negated ].
		normal := self collisionNormalFor: normal.
		distance := self dot: normal with: first point.
		distance < 0 ifTrue: [
			normal := normal negated.
			distance := distance negated ].
		distance < bestDistance ifTrue: [
			bestFirst := first.
			bestSecond := second.
			bestNormal := normal.
			bestDistance := distance.
			bestInsert := nextIndex ] ].
	^ { bestFirst. bestSecond. bestNormal. bestDistance. bestInsert }
]


{ #category : 'private' }
CFPhysicsEPA class >> collisionNormalFor: aNormal [
	| x y normal |
	x := (aNormal x closeTo: 0.0)
		ifTrue: [ 0.0 ]
		ifFalse: [ aNormal x ].
	y := (aNormal y closeTo: 0.0)
		ifTrue: [ 0.0 ]
		ifFalse: [ aNormal y ].
	normal := x @ y.
	^ normal r = 0
		ifTrue: [ aNormal ]
		ifFalse: [ normal / normal r ]
]

{ #category : 'private' }
CFPhysicsEPA class >> contactPointOnEdgeFrom: firstSupport to: secondSupport [
	| edge denominator parameter firstWitness secondWitness |
	edge := secondSupport point - firstSupport point.
	denominator := self dot: edge with: edge.
	parameter := denominator = 0
		ifTrue: [ 0.0 ]
		ifFalse: [ (((self dot: firstSupport point negated with: edge) / denominator) max: 0.0) min: 1.0 ].
	firstWitness := firstSupport firstPoint
		+ ((secondSupport firstPoint - firstSupport firstPoint) * parameter).
	secondWitness := firstSupport secondPoint
		+ ((secondSupport secondPoint - firstSupport secondPoint) * parameter).
	^ firstWitness
]

{ #category : 'private' }
CFPhysicsEPA class >> signedAreaOf: polytope [
	| area count |
	area := 0.0.
	count := polytope size.
	1 to: count do: [ :index |
		| first second |
		first := (polytope at: index) point.
		second := (polytope at: (index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ])) point.
		area := area + ((first x * second y) - (second x * first y)) ].
	^ area / 2.0
]

{ #category : 'private' }
CFPhysicsEPA class >> dot: first with: second [
	^ (first x * second x) + (first y * second y)
]
