Class {
	#name : 'CFPhysicsBodyState',
	#superclass : 'Object',
	#instVars : [ 'element', 'world', 'position', 'rotation', 'presentation', 'velocity', 'dynamic', 'sequence', 'shapeState', 'contacts', 'awake', 'sleepTime', 'angularVelocity', 'torque', 'angularDamping' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsBodyState class >> element: anElement world: aWorld [
	^ self new
		element: anElement;
		world: aWorld;
		yourself
]

{ #category : 'stepping' }
CFPhysicsBodyState >> advanceBy: seconds gravity: gravityVector [
	(dynamic and: [ awake ]) ifFalse: [ ^ self ].
	velocity := velocity + (gravityVector * seconds).
	angularVelocity := angularVelocity + (torque * self inverseInertia * seconds).
	angularDamping > 0 ifTrue: [ angularVelocity := angularVelocity * ((1.0 - (angularDamping * seconds)) max: 0.0) ].
	position := position + (velocity * seconds).
	rotation := rotation + (angularVelocity * seconds).
	torque := 0.0
]


{ #category : 'velocity' }
CFPhysicsBodyState >> addVelocity: aPoint [
	dynamic ifTrue: [ velocity := velocity + aPoint ]
]


{ #category : 'contacts' }
CFPhysicsBodyState >> addContact: aContact [
	contacts ifNil: [ contacts := IdentitySet new ].
	contacts add: aContact
]

{ #category : 'contacts' }
CFPhysicsBodyState >> contacts [
	contacts ifNil: [ contacts := IdentitySet new ].
	^ contacts asArray
]

{ #category : 'contacts' }
CFPhysicsBodyState >> removeContact: aContact [
	contacts ifNil: [ ^ self ].
	contacts remove: aContact ifAbsent: [ ]
]

{ #category : 'collision' }
CFPhysicsBodyState >> aabb [
	^ self shapeState aabbAt: position rotation: rotation
]

{ #category : 'body type' }
CFPhysicsBodyState >> beDynamic [
	dynamic := true.
	self wake
]

{ #category : 'body type' }
CFPhysicsBodyState >> beStatic [
	dynamic := false.
	awake := false.
	sleepTime := 0.0.
	velocity := 0 @ 0.
	angularVelocity := 0.0.
	torque := 0.0
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element [
	^ element
]

{ #category : 'accessing' }
CFPhysicsBodyState >> element: anElement [
	element := anElement.
	presentation := CFPhysicsPresentation on: anElement.
	shapeState := CFPhysicsShapeState on: anElement
]


{ #category : 'geometry' }
CFPhysicsBodyState >> extent [
	^ element extent
]

{ #category : 'mass' }
CFPhysicsBodyState >> inverseMass [
	| area mass |
	dynamic ifFalse: [ ^ 0.0 ].
	area := self shapeState area.
	mass := area * self shapeState material density.
	^ mass > 0 ifTrue: [ 1.0 / mass ] ifFalse: [ 0.0 ]
]

{ #category : 'material' }
CFPhysicsBodyState >> friction [
	^ self shapeState material friction
]

{ #category : 'material' }
CFPhysicsBodyState >> friction: aNumber [
	self shapeState material friction: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution [
	^ self shapeState material restitution
]

{ #category : 'material' }
CFPhysicsBodyState >> restitution: aNumber [
	self shapeState material restitution: aNumber
]

{ #category : 'material' }
CFPhysicsBodyState >> density [
	^ self shapeState material density
]

{ #category : 'material' }
CFPhysicsBodyState >> density: aNumber [
	self shapeState material density: aNumber
]

{ #category : 'initialization' }
CFPhysicsBodyState >> initialize [
	super initialize.
	position := 0 @ 0.
	rotation := 0.
	velocity := 0 @ 0.
	dynamic := true.
	awake := true.
	sleepTime := 0.0.
	angularVelocity := 0.0.
	torque := 0.0.
	angularDamping := 0.0.
	contacts := IdentitySet new
]

{ #category : 'body type' }
CFPhysicsBodyState >> isDynamic [
	^ dynamic
]

{ #category : 'body type' }
CFPhysicsBodyState >> isStatic [
	^ dynamic not
]

{ #category : 'presenting' }
CFPhysicsBodyState >> present [
	presentation presentTranslation: position rotation: rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position [
	^ position
]

{ #category : 'accessing' }
CFPhysicsBodyState >> position: aPoint [
	position := aPoint.
	self wake.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> presentation [
	^ presentation
]

{ #category : 'controlling' }
CFPhysicsBodyState >> release [
	presentation release
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation [
	^ rotation
]

{ #category : 'accessing' }
CFPhysicsBodyState >> rotation: aNumber [
	rotation := aNumber.
	self wake.
	self present
]



{ #category : 'geometry' }
CFPhysicsBodyState >> shapeState [
	shapeState ifNil: [ shapeState := CFPhysicsShapeState on: element ].
	^ shapeState
]

{ #category : 'ordering' }
CFPhysicsBodyState >> sequence [
	^ sequence
]


{ #category : 'ordering' }
CFPhysicsBodyState >> sequence: anInteger [
	sequence := anInteger
]

{ #category : 'collision' }
CFPhysicsBodyState >> translateBy: aPoint [
	position := position + aPoint
]

{ #category : 'presenting' }
CFPhysicsBodyState >> translation: aPoint rotation: aNumber [
	position := aPoint.
	rotation := aNumber.
	self wake.
	self present
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity [
	^ velocity
]

{ #category : 'accessing' }
CFPhysicsBodyState >> velocity: aPoint [
	velocity := dynamic
		ifTrue: [
			aPoint = (0 @ 0) ifFalse: [ self wake ].
			aPoint ]
		ifFalse: [ 0 @ 0 ]
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world [
	^ world
]

{ #category : 'accessing' }
CFPhysicsBodyState >> world: aWorld [
	world := aWorld
]


{ #category : 'sleeping' }
CFPhysicsBodyState >> isAwake [
	^ dynamic and: [ awake ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> isSleeping [
	^ dynamic and: [ awake not ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> sleep [
	dynamic ifFalse: [ ^ self ].
	Transcript
		cr;
		nextPutAll: 'CFPhysics sleep body='; print: element identityHash;
		nextPutAll: ' position='; print: position;
		nextPutAll: ' rotation='; print: rotation;
		nextPutAll: ' velocity='; print: velocity;
		nextPutAll: ' angularVelocity='; print: angularVelocity;
		nextPutAll: ' accumulatedTime='; print: sleepTime.
	awake := false.
	sleepTime := 0.0.
	velocity := 0 @ 0.
	angularVelocity := 0.0.
	torque := 0.0
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> sleepTime [
	^ sleepTime
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> updateSleepBy: seconds linearThresholdSquared: thresholdSquared angularThresholdSquared: angularThresholdSquared requiredTime: requiredTime [
	| speedSquared angularSpeedSquared eligible previousSleepTime |
	dynamic ifFalse: [ ^ self ].
	speedSquared := velocity x squared + velocity y squared.
	angularSpeedSquared := angularVelocity squared.
	eligible := speedSquared <= thresholdSquared and: [ angularSpeedSquared <= angularThresholdSquared ].
	previousSleepTime := sleepTime.
	eligible
		ifTrue: [
			previousSleepTime = 0.0 ifTrue: [
				Transcript
					cr;
					nextPutAll: 'CFPhysics sleep eligibility began body='; print: element identityHash;
					nextPutAll: ' speedSquared='; print: speedSquared;
					nextPutAll: ' linearThresholdSquared='; print: thresholdSquared;
					nextPutAll: ' angularSpeedSquared='; print: angularSpeedSquared;
					nextPutAll: ' angularThresholdSquared='; print: angularThresholdSquared ].
			sleepTime := sleepTime + seconds.
			sleepTime >= requiredTime ifTrue: [ self sleep ] ]
		ifFalse: [
			previousSleepTime > 0.0 ifTrue: [
				Transcript
					cr;
					nextPutAll: 'CFPhysics sleep eligibility lost body='; print: element identityHash;
					nextPutAll: ' previousSleepTime='; print: previousSleepTime;
					nextPutAll: ' speedSquared='; print: speedSquared;
					nextPutAll: ' linearThresholdSquared='; print: thresholdSquared;
					nextPutAll: ' angularSpeedSquared='; print: angularSpeedSquared;
					nextPutAll: ' angularThresholdSquared='; print: angularThresholdSquared ].
			sleepTime := 0.0.
			awake := true ]
]

{ #category : 'sleeping' }
CFPhysicsBodyState >> wake [
	| wasAwake previousSleepTime |
	dynamic ifFalse: [ ^ self ].
	wasAwake := awake.
	previousSleepTime := sleepTime.
	Transcript
		cr;
		nextPutAll: 'CFPhysics wake body='; print: element identityHash;
		nextPutAll: ' wasAwake='; print: wasAwake;
		nextPutAll: ' previousSleepTime='; print: previousSleepTime;
		nextPutAll: ' sender='; print: thisContext sender.
	awake := true.
	sleepTime := 0.0
]


{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularVelocity [
	^ angularVelocity
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularVelocity: aNumber [
	angularVelocity := dynamic ifTrue: [ aNumber asFloat ] ifFalse: [ 0.0 ].
	angularVelocity = 0.0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularDamping [
	^ angularDamping
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> angularDamping: aNumber [
	angularDamping := aNumber asFloat max: 0.0
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> applyTorque: aNumber [
	dynamic ifFalse: [ ^ self ].
	torque := torque + aNumber.
	aNumber = 0 ifFalse: [ self wake ]
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> addAngularVelocity: aNumber [
	dynamic ifTrue: [ angularVelocity := angularVelocity + aNumber ]
]

{ #category : 'mass' }
CFPhysicsBodyState >> mass [
	| inverse |
	inverse := self inverseMass.
	^ inverse = 0 ifTrue: [ 0.0 ] ifFalse: [ 1.0 / inverse ]
]

{ #category : 'mass' }
CFPhysicsBodyState >> inverseInertia [
	| mass extent inertia |
	dynamic ifFalse: [ ^ 0.0 ].
	mass := self mass.
	mass = 0 ifTrue: [ ^ 0.0 ].
	extent := self shapeState extent.
	inertia := self shapeState isCircle
		ifTrue: [ mass * self shapeState radius squared / 2.0 ]
		ifFalse: [ mass * (extent x squared + extent y squared) / 12.0 ].
	^ inertia > 0 ifTrue: [ 1.0 / inertia ] ifFalse: [ 0.0 ]
]

{ #category : 'geometry' }
CFPhysicsBodyState >> centre [
	^ self shapeState centreAt: position
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> velocityAtWorldPoint: aPoint [
	| radiusVector |
	radiusVector := aPoint - self centre.
	^ velocity + ((angularVelocity * radiusVector y negated) @ (angularVelocity * radiusVector x))
]

{ #category : 'angular dynamics' }
CFPhysicsBodyState >> applyImpulse: anImpulse atWorldPoint: aPoint [
	| radiusVector cross |
	dynamic ifFalse: [ ^ self ].
	self addVelocity: anImpulse * self inverseMass.
	radiusVector := aPoint - self centre.
	cross := (radiusVector x * anImpulse y) - (radiusVector y * anImpulse x).
	self addAngularVelocity: cross * self inverseInertia
]

{ #category : 'collision' }
CFPhysicsBodyState >> rotateBy: anAngle [
	rotation := rotation + anAngle
]
