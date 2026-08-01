"
I represent a joint that restricts relative movement to one axis.

My responsibility is to retain its axis, limits, motor configuration and accumulated solver state.
"
Class {
	#name : 'CFPhysicsPrismaticJoint',
	#superclass : 'CFPhysicsJoint',
	#instVars : [ 'endpointPair', 'axis', 'normal', 'referenceTranslation', 'referenceAngle', 'limitsEnabled', 'lowerTranslation', 'upperTranslation', 'accumulatedPerpendicularImpulse', 'accumulatedAngularImpulse' ],
	#category : 'BVC-Physics-Model',
	#package : 'BVC-Physics-Model'
}

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> between: firstBodyState and: secondBodyState along: anAxis [
	^ self
		betweenAnchor: (CFPhysicsBodyCentreAnchor on: firstBodyState)
		andAnchor: (CFPhysicsBodyCentreAnchor on: secondBodyState)
		along: anAxis
]

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> betweenAnchor: firstAnchor andAnchor: secondAnchor along: anAxis [
	^ self betweenEndpoints: (CFPhysicsAnchoredEndpointPair
		anchorA: firstAnchor
		anchorB: secondAnchor)
		along: anAxis
]

{ #category : 'instance creation' }
CFPhysicsPrismaticJoint class >> betweenEndpoints: anEndpointPair along: anAxis [
	^ self new
		endpointPair: anEndpointPair;
		axis: anAxis;
		referenceTranslation: (self translationBetweenEndpoints: anEndpointPair along: anAxis);
		referenceAngle: ((self angleFor: anEndpointPair bodyB) - (self angleFor: anEndpointPair bodyA));
		yourself
]

{ #category : 'private' }
CFPhysicsPrismaticJoint class >> angleFor: aBody [
	^ aBody ifNil: [ 0.0 ] ifNotNil: [ aBody rotation ]
]

{ #category : 'private' }
CFPhysicsPrismaticJoint class >> translationBetweenEndpoints: anEndpointPair along: anAxis [
	| length axisVector points |
	length := anAxis r.
	length = 0.0 ifTrue: [ self error: 'A prismatic joint requires a non-zero axis' ].
	axisVector := anAxis / length.
	points := anEndpointPair worldPoints.
	^ ((points first - points second) x * axisVector x)
		+ ((points first - points second) y * axisVector y)
]

{ #category : 'initialization' }
CFPhysicsPrismaticJoint >> initialize [
	super initialize.
	axis := 1 @ 0.
	normal := 0 @ 1.
	referenceTranslation := 0.0.
	referenceAngle := 0.0.
	limitsEnabled := false.
	lowerTranslation := 0.0.
	upperTranslation := 0.0.
	accumulatedPerpendicularImpulse := 0.0.
	accumulatedAngularImpulse := 0.0.
]

{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> endpointPair [ ^ endpointPair ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> endpointPair: anEndpointPair [ endpointPair := anEndpointPair ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> anchorA [ ^ endpointPair anchorA ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> anchorB [ ^ endpointPair anchorB ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> bodyA [ ^ endpointPair bodyA ]
{ #category : 'accessing' }
CFPhysicsPrismaticJoint >> bodyB [ ^ endpointPair bodyB ]




{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> axis [ ^ axis ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> axis: aPoint [
	| length |
	length := aPoint r.
	length = 0.0 ifTrue: [ self error: 'A prismatic joint requires a non-zero axis' ].
	axis := aPoint / length.
	normal := axis y negated @ axis x.
	endpointPair ifNotNil: [
		referenceTranslation := self class translationBetweenEndpoints: endpointPair along: axis ].
	accumulatedPerpendicularImpulse := 0.0.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> normal [ ^ normal ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceTranslation [ ^ referenceTranslation ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceTranslation: aNumber [
	referenceTranslation := aNumber asFloat.
	self wakeBodies
]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceAngle [ ^ referenceAngle ]
{ #category : 'configuration' }
CFPhysicsPrismaticJoint >> referenceAngle: aNumber [
	referenceAngle := aNumber asFloat.
	accumulatedAngularImpulse := 0.0.
	self wakeBodies
]

{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitsEnabled [ ^ limitsEnabled ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitsEnabled: aBoolean [
	limitsEnabled = aBoolean ifTrue: [ ^ self ].
	limitsEnabled := aBoolean.
	self wakeBodies
]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> lowerTranslation [ ^ lowerTranslation ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> upperTranslation [ ^ upperTranslation ]
{ #category : 'limits' }
CFPhysicsPrismaticJoint >> limitTranslationFrom: aLowerTranslation to: anUpperTranslation [
	| lower upper |
	lower := aLowerTranslation asFloat.
	upper := anUpperTranslation asFloat.
	lower < upper ifFalse: [ self error: 'A prismatic joint limit requires a lower translation smaller than its upper translation' ].
	lowerTranslation := lower.
	upperTranslation := upper.
	self wakeBodies
]

{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> accumulatedPerpendicularImpulse [ ^ accumulatedPerpendicularImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> accumulatedPerpendicularImpulse: aNumber [ accumulatedPerpendicularImpulse := aNumber asFloat ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> accumulatedAngularImpulse [ ^ accumulatedAngularImpulse ]
{ #category : 'solver state' }
CFPhysicsPrismaticJoint >> accumulatedAngularImpulse: aNumber [ accumulatedAngularImpulse := aNumber asFloat ]


{ #category : 'testing' }
CFPhysicsPrismaticJoint >> includesBody: aBodyState [ ^ endpointPair includesBody: aBodyState ]
{ #category : 'testing' }
CFPhysicsPrismaticJoint >> includesAnchor: anAnchor [
	(endpointPair respondsTo: #anchorA) ifFalse: [ ^ false ].
	^ endpointPair anchorA == anAnchor or: [ endpointPair anchorB == anAnchor ]
]




{ #category : 'capturing' }
CFPhysicsPrismaticJoint >> capturedForStep [
	| captured |
	captured := self shallowCopy.
	captured
		endpointPair: (CFPhysicsCapturedEndpointPair from: endpointPair);
		sourceJoint: self.
	^ captured
]


