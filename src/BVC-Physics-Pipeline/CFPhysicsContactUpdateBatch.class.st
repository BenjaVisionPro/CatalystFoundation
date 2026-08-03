"
I represent the outcome of reconciling broadphase pairs with persistent contacts. I retain all contacts whose pairs still exist and identify the touching subset and touching transitions for later stages.
"

Class {
	#name : 'CFPhysicsContactUpdateBatch',
	#superclass : 'Object',
	#instVars : [ 'contacts', 'touchingContacts', 'beganContacts', 'continuedContacts', 'endedContacts' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsContactUpdateBatch class >> contacts: contacts touching: touching began: began continued: continued ended: ended [
	^ self new
		contacts: contacts;
		touchingContacts: touching;
		beganContacts: began;
		continuedContacts: continued;
		endedContacts: ended;
		yourself
]

{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> contacts [ ^ contacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> contacts: aCollection [ contacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> touchingContacts [ ^ touchingContacts ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> touchingContacts: aCollection [ touchingContacts := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsContactUpdateBatch >> activeContacts [ ^ touchingContacts ]
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
