"I define the explicit object-supply seam used before an Atelier operation is created.

Providers materialize one candidate object for an interaction. Atelier operations receive that materialized candidate; they do not retain or repeatedly invoke the provider during assessment/reassessment. This keeps provider/storage policy outside operation semantics and preserves candidate identity across hover and apply.

Concrete providers make supply semantics explicit."
Class {
	#name : 'CFAtelierObjectProvider',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Atelier-Supply',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'Supply'
}

{ #category : 'materializing' }
CFAtelierObjectProvider >> materialize [
	self subclassResponsibility
]
