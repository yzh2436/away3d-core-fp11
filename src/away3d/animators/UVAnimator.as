package away3d.animators
{
	import away3d.arcane;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.core.base.*;
	import away3d.core.managers.*;
	import away3d.materials.*;
	import away3d.materials.passes.*;

	use namespace arcane;
	
	public class UVAnimator extends AnimatorBase implements IAnimator
	{
		private var _activeNode : IUVAnimationNode;
		private var _activeState:VertexAnimationState;
		private var _absoluteTime : Number;
		
		private var _uvAnimationSet:UVAnimationSet;
		private var _deltaFrame : UVAnimationFrame = new UVAnimationFrame();
		
		public function UVAnimator(uvAnimationSet:UVAnimationSet)
		{
			super(uvAnimationSet);
			
			_uvAnimationSet = uvAnimationSet;
		}
		
		public function setRenderState(stage3DProxy : Stage3DProxy, renderable : IRenderable, vertexConstantOffset : int, vertexStreamOffset : int) : void
		{
			var material:TextureMaterial = renderable.material as TextureMaterial;
			var subMesh:SubMesh = renderable as SubMesh;
			
			if (!material || !subMesh)
				return;
			
			if (!material.animateUVs)
				material.animateUVs = true;
			
			subMesh.offsetU = _deltaFrame.offsetU;
			subMesh.offsetV = _deltaFrame.offsetV;
			subMesh.scaleU = _deltaFrame.scaleU;
			subMesh.scaleV = _deltaFrame.scaleV;
			subMesh.uvRotation = _deltaFrame.rotation;
		}
		
		public function play(stateName : String) : void
		{
			_activeState = _uvAnimationSet.getState(stateName) as VertexAnimationState;
			
			if (!_activeState)
				throw new Error("Animation state " + stateName + " not found!");
			
			_activeNode = _activeState.rootNode as IUVAnimationNode;
			
			_absoluteTime = 0;
			
			start();
		}
		
		override protected function updateAnimation(realDT : Number, scaledDT : Number) : void
		{
			_absoluteTime += scaledDT;
			
			_activeNode.update(_absoluteTime);
			
			var currentUVFrame : UVAnimationFrame = _activeNode.currentUVFrame;
			var nextUVFrame : UVAnimationFrame = _activeNode.currentUVFrame;
			var blendWeight : Number = _activeNode.blendWeight;
			
			_deltaFrame.offsetU = currentUVFrame.offsetU + blendWeight * (nextUVFrame.offsetU - currentUVFrame.offsetU);
			_deltaFrame.offsetV = currentUVFrame.offsetV + blendWeight * (nextUVFrame.offsetV - currentUVFrame.offsetV);
			_deltaFrame.scaleU = currentUVFrame.scaleU + blendWeight * (nextUVFrame.scaleU - currentUVFrame.scaleU);
			_deltaFrame.scaleV = currentUVFrame.scaleV + blendWeight * (nextUVFrame.scaleV - currentUVFrame.scaleV);
			_deltaFrame.rotation = currentUVFrame.rotation + blendWeight * (nextUVFrame.rotation - currentUVFrame.rotation);
		}
						
        /**
         * Verifies if the animation will be used on cpu. Needs to be true for all passes for a material to be able to use it on gpu.
		 * Needs to be called if gpu code is potentially required.
         */
        public function testGPUCompatibility(pass : MaterialPassBase) : void
        {
        }
	}
}