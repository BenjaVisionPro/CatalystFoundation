Class {
	#name : 'CFPhysicsContactUpdateBatch',
	#superclass : 'Object',
	#instVars : [ 'activeContacts', 'beganContacts', 'continuedContacts', 'endedContacts' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdateBatch class >> active: active began: began continued: continued ended: ended [
	^ self new
		activeContacts: active;
		beganContacts: began;
		continuedContacts: continued;
		endedContacts: ended;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> activeContacts [ ^ activeContacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> activeContacts: aCollection [ activeContacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> beganContacts [ ^ beganContacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> beganContacts: aCollection [ beganContacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> continuedContacts [ ^ continuedContacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> continuedContacts: aCollection [ continuedContacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> endedContacts [ ^ endedContacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> endedContacts: aCollection [ endedContacts := aCollection asArray ]
