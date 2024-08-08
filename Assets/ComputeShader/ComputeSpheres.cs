using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeSpheres : MonoBehaviour
{
    public int SphereAmount = 10;
    public GameObject Template;
    public ComputeShader ComputeShader;
    private ComputeBuffer resultBuffer;
    private int kernel;
    private uint threadGroupSize;

    private Vector3[] output;
    private Transform[] instances;

    void Start()
    {
        kernel = ComputeShader.FindKernel("Spheres");
        ComputeShader.GetKernelThreadGroupSizes(kernel, out threadGroupSize, out _, out _);
        resultBuffer = new ComputeBuffer(SphereAmount, sizeof(float) * 3);
        output = new Vector3[SphereAmount];

        instances = new Transform[SphereAmount];
        for (var i = 0; i < SphereAmount; i++)
        {
            instances[i] = Instantiate(Template, transform).transform;
        }
    }

    // Update is called once per frame
    void Update()
    {
        ComputeShader.SetFloat("Time", Time.time);
        ComputeShader.SetBuffer(kernel, "Result", resultBuffer);
        var threadGroups = (int) ((SphereAmount + (threadGroupSize - 1)) / threadGroupSize);
        ComputeShader.Dispatch(kernel, threadGroups,1,1);
        resultBuffer.GetData(output);

        for (var i = 0; i < instances.Length; i++)
        {
            instances[i].localPosition = output[i];
        }
    }

    private void OnDestroy()
    {
        resultBuffer.Dispose();
    }
}
