Class {
	#name : 'CFPhysicsRailJoint',
	#superclass : 'Object',
	#instVars : [ 'endpointPair', 'axis', 'normal', 'referenceTranslation', 'referenceAngle', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'active', 'sequence', 'accumulatedPerpendicularImpulse', 'accumulatedAngularImpulse', 'collideConnected' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsRailJoint class >> between: firstBodyState and: secondBodyState along: anAxis [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
		along: anAxis
]

{ #category : 'instance creation' }
CFPhysicsRailJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor along: anAxis [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
		along: anAxis
]

{ #category : 'instance creation' }
CFPhysicsRailJoint class >> betweenEndpoints: anEndpointPair along: anAxis [
	^ self new
		endpointPair: anEndpointPair;
		axis: anAxis;
		referenceTranslation: (self translationBetweenEndpoints: anEndpointPair along: anAxis);
		referenceAngle: ((self angleFor: anEndpointPair bodyB) - (self angleFor: anEndpointPair bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsRailJoint class >> angleFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ]
]

{ #category : 'private' }
CFPhysicsRailJoint class >> translationBetweenEndpoints: anEndpointPair along: anAxis [
	| length axisVector points |
	length := anAxis r.
	length = 0.0 ifTrue: [ self error: 'A rail joint requires a non-zero axis' ].
	axisVector := anAxis / length.
	points := anEndpointPair worldPoints.
	^ ((points first - points second) x * axisVector x)
		+ ((points first - points second) y * axisVector y)
]

{ #category : 'initialization' }
CFPhysicsRailJoint >> initialize [
	super initialize.
	axis := 1 @ 0.
	normal := 0 @ 1.
	referenceTranslation := 0.0.
	referenceAngle := 0.0.
	limitsEnabled := false.
	lowerTranslation := 0.0.
	upperTranslation := 0.0.
	active := true.
	sequence := 0.
	accumulatedPerpendicularImpulse := 0.0.
	accumulatedAngularImpulse := 0.0.
	collideConnected := true
]

{ #category : 'accessing' }
CFPhysicsRailJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> bodyB [ ^ endpointPair bodyB ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> firstBody [ ^ self bodyA ]
{ #category : 'accessing' }
CFPhysicsRailJoint >> secondBody [ ^ self bodyB ]


{ #category : 'configuration' }
CFPhysicsRailJoint >> collideConnected [ ^ collideConnected ]

{ #category : 'configuration' }
CFPhysicsRailJoint >> collideConnected: aBoolean [
	collideConnected = aBoolean ifTrue: [ ^ self ].
	collideConnected := aBoolean.
	self wakeBodies
]

{ #category : 'configuration' }
CFPhysicsRailJoint >> axis [ ^ axis ]
{ #category : 'configuration' }
CFPhysicsRailJoint >> axis: aPoint [
	| length |
	length := aPoint r.
	length = 0.0 ifTrue: [ self error: 'A rail joint requires a non-zero axis' ].
	axis := aPoint / length.
	normal := axis y negated @ axis x.
	endpointPair ifNotNil: [
		referenceTranslation := self class translationBetweenEndpoints: endpointPair along: axis ].
	accumulatedPerpendicularImpulse := 0.0.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsRailJoint >> normal [ ^ normal ]
{ #category : 'configuration' }
CFPhysicsRailJoint >> referenceTranslation [ ^ referenceTranslation ]
{ #category : 'configuration' }
CFPhysicsRailJoint >> referenceTranslation: aNumber [
	referenceTranslation := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsRailJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsRailJoint >> referenceAngle: aNumber [
	referenceAngle := aNumber asFloat.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]

{ #category : 'limits' }
CFPhysicsRailJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsRailJoint >> limitsEnabled: aBoolean [
	limitsEnabled = aBoolean ifTrue: [ ^ self ].
	limitsEnabled := aBoolean.
	self wakeBodies
]
{ #category : 'limits' }
CFPhysicsRailJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsRailJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsRailJoint >> limitTranslationFrom: aLowerTranslation to: anUpperTranslation [
	| lower upper |
	lower := aLowerTranslation asFloat.
	upper := anUpperTranslation asFloat.
	lower < upper ifFalse: [ self error: 'A rail joint limit requires a lower translation smaller than its upper translation' ].
	lowerTranslation := lower.
	upperTranslation := upper.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsRailJoint >> accumulatedPerpendicularImpulse [ ^ accumulatedPerpendicularImpulse ]
{ #category : 'solver state' }
CFPhysicsRailJoint >> accumulatedPerpendicularImpulse: aNumber [ accumulatedPerpendicularImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsRailJoint >> accumulatedAngularImpulse [ ^ accumulatedAngularImpulse ]
{ #category : 'solver state' }
CFPhysicsRailJoint >> accumulatedAngularImpulse: aNumber [ accumulatedAngularImpulse := aNumber asFloat ]

{ #category : 'ordering' }
CFPhysicsRailJoint >> sequence [ ^ sequence ]
{ #category : 'ordering' }
CFPhysicsRailJoint >> sequence: anInteger [ sequence := anInteger ]
{ #category : 'ordering' }
CFPhysicsRailJoint >> orderingKey [ ^ sequence ]

{ #category : 'testing' }
CFPhysicsRailJoint >> isActive [ ^ active ]
{ #category : 'testing' }
CFPhysicsRailJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]
{ #category : 'testing' }
CFPhysicsRailJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]

{ #category : 'waking' }
CFPhysicsRailJoint >> wakeBodies [
	self firstBody ifNotNil: [ :body | body wake ].
	self secondBody ifNotNil: [ :body | body wake ]
]

{ #category : 'controlling' }
CFPhysicsRailJoint >> release [ active := false ]
