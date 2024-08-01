using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Serialization;

namespace Outline
{
    public class OutlineRenderFeature : ScriptableRendererFeature
    {
        private OutlineRenderPass _outlineRenderPass;
        public Material WriteObjectMat;
        public Material ApplyOutlineMat;
        public override void Create()
        {
            _outlineRenderPass = new OutlineRenderPass();
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            _outlineRenderPass.SetMaterial(WriteObjectMat, ApplyOutlineMat);
            renderer.EnqueuePass(_outlineRenderPass);
        }
    }

    public class OutlineRenderPass : ScriptableRenderPass
    {
        private const string PROFILER_TAG = "OutlinePass";
        private static readonly int SelectionBuffer = Shader.PropertyToID("_SelectionBuffer");

        private Material writeObjectMat;
        private Material applyOutlineMat;
        private RenderTargetIdentifier source;
        private RenderTargetIdentifier destination;
        public OutlineRenderPass()
        {
            renderPassEvent = RenderPassEvent.AfterRenderingSkybox;
            profilingSampler = new ProfilingSampler(PROFILER_TAG);
        }

        public void SetMaterial(Material writeObj, Material applyOutline)
        {
            writeObjectMat = writeObj;
            applyOutlineMat = applyOutline;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get(PROFILER_TAG);
            var rtDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            rtDescriptor.depthBufferBits = 0;
            rtDescriptor.graphicsFormat = GraphicsFormat.R16G16B16A16_SFloat;
            cmd.GetTemporaryRT(SelectionBuffer, rtDescriptor);
            cmd.SetRenderTarget(SelectionBuffer);
            cmd.ClearRenderTarget(true, true, Color.clear);

            if (SelectionOutlineObject.SelectedObject != null)
            {
                cmd.DrawRenderer(SelectionOutlineObject.SelectedObject, writeObjectMat);
            }

            source = renderingData.cameraData.renderer.cameraColorTargetHandle;
            destination = source;

            cmd.Blit(source, source, applyOutlineMat);
            cmd.ReleaseTemporaryRT(SelectionBuffer);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
