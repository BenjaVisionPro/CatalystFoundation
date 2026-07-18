Class {
	#name : 'CFPhysicsCleanSlateExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples - status' }
CFPhysicsCleanSlateExamples >> currentImplementationSurface [
	<gtExample>
	^ {
		CFPhysicsStep.
		CFPhysicsBodyStepState.
		CFPhysicsContactFeatureId.
		CFPhysicsPolygonShape.
		CFPhysicsClipVertex.
		CFPhysicsPolygonManifoldBuilder.
		CFPhysicsBlocShapeFactory.
		CFPhysicsBlocManifoldBuilder.
		CFPhysicsPair.
		CFPhysicsPairFinder.
		CFPhysicsContactUpdater.
		CFPhysicsContactPipeline.
		CFPhysicsContactPipelineResult.
		CFPhysicsConstraintBuilder.
		CFPhysicsPreparedConstraint.
		CFPhysicsConstraintPoint.
		CFPhysicsSoftStepSolver }
]
