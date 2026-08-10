Class {
	#name : 'CFPhysicsProfileHealthElementTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Tools',
	#package : 'BVC-Physics-Tests-Tools'
}

{ #category : 'private - fixtures' }
CFPhysicsProfileHealthElementTests >> worldWithOneJoint [
	| host first second world |
	host := BlElement new.
	first := BlElement new size: 20 @ 20.
	second := BlElement new size: 20 @ 20.
	host
		addChild: first;
		addChild: second.
	world := host physics beWorld.
	host physics makeChildrenDynamic.
	world addJoint: (CFPhysicsDistanceJoint
		between: (world bodyStateFor: first)
		and: (world bodyStateFor: second)).
	^ world
]

{ #category : 'tests - retention' }
CFPhysicsProfileHealthElementTests >> testJointRetentionRowClassifiesKnownSnapshotLifetimesByIdentity [
	| world live committedOnly backgroundOnly backgroundState health row |
	world := self worldWithOneJoint.
	live := world joints first.
	committedOnly := live capturedForStep.
	backgroundOnly := live capturedForStep.
	backgroundState := CFPhysicsWorldState new
		joints: { committedOnly. backgroundOnly };
		yourself.
	health := CFPhysicsProfileHealthElement new world: world.
	row := health
		jointRetentionRowFrom: { live. committedOnly. backgroundOnly }
		committedJoints: { committedOnly }
		backgroundStates: { backgroundState }.
	self assert: (row at: #owned) equals: 3.
	self assert: (row at: #live) equals: 1.
	self assert: (row at: #committed) equals: 1.
	self assert: (row at: #background) equals: 1.
	self assert: (row at: #backgroundStateCount) equals: 1.
	self assert: (row at: #other) equals: 0
]

{ #category : 'tests - retention' }
CFPhysicsProfileHealthElementTests >> testJointRetentionRowReportsOnlyUnclassifiedJointsAsDifference [
	| world live unexplained health row |
	world := self worldWithOneJoint.
	live := world joints first.
	unexplained := live capturedForStep.
	health := CFPhysicsProfileHealthElement new world: world.
	row := health
		jointRetentionRowFrom: { live. unexplained }
		committedJoints: #()
		backgroundStates: #().
	self assert: (row at: #other) equals: 1.
	self assert: (row at: #difference) equals: 1.
	self assert: (health jointRowSummary: row)
		equals: '2/2  live 1 · committed 0 · background 0 (0 states) · other 1'
]
