"
I represent the observable results collected after constraint solving. I contain contact solve results and hit events for the completed step.
"

Class {
	#name : 'CFPhysicsPostSolveBatch',
	#superclass : 'Object',
	#instVars : [ 'contactResults', 'hitEvents' ],
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
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
