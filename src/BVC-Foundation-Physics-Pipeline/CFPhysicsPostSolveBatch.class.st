Class {
	#name : 'CFPhysicsPostSolveBatch',
	#superclass : 'Object',
	#instVars : [ 'contactResults', 'hitEvents' ],
	#category : 'BVC-Foundation-Physics-Pipeline',
	#package : 'BVC-Foundation-Physics-Pipeline'
}

{ #category : 'instance creation' }
CFPhysicsPostSolveBatch class >> contactResults: results hitEvents: events [
	^ self new
		contactResults: results;
		hitEvents: events;
		yourself
]

{ #category : 'accessing' }
CFPhysicsPostSolveBatch >> contactResults [ ^ contactResults ]
{ #category : 'accessing' }
CFPhysicsPostSolveBatch >> contactResults: aCollection [ contactResults := aCollection asArray ]
{ #category : 'accessing' }
CFPhysicsPostSolveBatch >> hitEvents [ ^ hitEvents ]
{ #category : 'accessing' }
CFPhysicsPostSolveBatch >> hitEvents: aCollection [ hitEvents := aCollection asArray ]
