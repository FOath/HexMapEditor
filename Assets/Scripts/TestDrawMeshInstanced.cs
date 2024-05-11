using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class TestDrawMeshInstanced : MonoBehaviour
{
    public int width = 300;
    public int height = 300;

    public Material mat;

    public Mesh mesh;

    public Bounds bounds;

    private ComputeBuffer argsBuffer;
    private ComputeBuffer meshPropertiesBuffer;

    private struct MeshProperties
    {
        public Matrix4x4 mat;
        public static int Size()
        { 
            return sizeof(float) * 4 * 4;
        }
    }

    private void InitializeBuffers()
    {
        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
        args[0] = (uint)mesh.GetIndexCount(0);
        args[1] = (uint)(width * height);
        args[2] = (uint)mesh.GetIndexStart(0);
        args[3] = (uint)mesh.GetBaseVertex(0);
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(args);

        MeshProperties[] properties = new MeshProperties[width * height];
        for(int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                MeshProperties pros = new MeshProperties();
                Vector3 pos = new Vector3(i, 0, j);
                pros.mat = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one);
                properties[i * width + j] = pros;
            }
        }

        meshPropertiesBuffer = new ComputeBuffer(width * height, MeshProperties.Size());
        meshPropertiesBuffer.SetData(properties);
        mat.SetBuffer("_Properties", meshPropertiesBuffer);
    }

    private void Start()
    {
        InitializeBuffers();
    }

    private void Update()
    {
        Graphics.DrawMeshInstancedIndirect(mesh, 0, mat, bounds, argsBuffer);
    }
}
