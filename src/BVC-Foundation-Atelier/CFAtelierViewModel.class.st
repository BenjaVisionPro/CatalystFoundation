"I am the public view-model entry point for editing an ordinary Magritte-described object as a Foundation Atelier.

I deliberately inherit Foundation Magritte's rendering and memento behaviour unchanged. Atelier does not choose a parallel presentation: the object's Magritte container continues to select its Foundation presentation through the existing CFMaViewModel machinery.

My separate type gives Atelier a stable public surface on which composition interaction can grow without changing the Foundation Magritte view model itself."
Class {
	#name : 'CFAtelierViewModel',
	#superclass : 'CFMaViewModel',
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}
