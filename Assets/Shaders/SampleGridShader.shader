Shader "Custom/SampleGridShader"
{
    Properties
    {
        _FragSize("FragSize", Float) = 1.0
        _FragCenter("FragCenter", Float) = 1.0
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalRenderPipeline"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            Cull off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 nearPoint : TEXCOORD0;
                float3 farPoint : TEXCOORD1;
            };

            float _fragSize;
            float _fragCenter;

            float3 TransformHClipToWorld(float3 positionCS, float4x4 inv_VP)
            {
                float4 unprojectedPoint = mul(inv_VP, float4(positionCS, 1.0));
                return unprojectedPoint.xyz / unprojectedPoint.w;
            }

            half RectGrid(float2 uv)
            {
                float2 derivative = fwidth(uv);
                uv = frac(uv - 0.5);
                uv.x *= 0.57735 * 2.0;
                uv.y += fmod(floor(uv.x), 2.0) * 0.5;
                uv = abs((fmod(uv, 1.0) - 0.5));
                return 1.0 - abs(max(uv.x * 1.5 + uv.y, uv.y * 2.0) - 1.0);
            }

            half HexGrid(float2 uv)
            {
                float2 derivative = fwidth(uv);
                // World Coordinate Offset
                //float2 offset = float2(0.0, 0.0);
                uv += float2(0.3, 0.5);
                // Adjust Cell Center (Make the inverted line cotinuous)
                
                uv = abs(uv) + 0.5;
                uv.x *= 0.57735 *  2.0;
                uv.y += fmod(floor(uv.x), 2.0) * 0.5;
                uv = abs((fmod(uv, 1.0) - 0.5));
                //uv = uv / derivative;
                return step(0.95, 1.0 - abs(max(uv.x * 1.5 + uv.y, uv.y * 2.0) - 1.0));
            }

            float computeViewZ(float3 pos)
            {
                float4 clip_space_pos = mul(UNITY_MATRIX_VP, float4(pos.xyz, 1.0));
                float viewZ = clip_space_pos.w;
                return viewZ;
            }
            
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float2 uv = IN.uv * 2.0 - 1.0;
                float depth = 1;
                half farPlane = 1;
                half nearPlane = 0;
                #if defined(UNITY_REVERSED_Z)
                    farPlane = 1 - farPlane;
                    nearPlane = 1 - nearPlane;
                #endif

                float4 position = float4(uv, farPlane, 1);
                float3 nearPoint = TransformHClipToWorld(float3(position.xy, nearPlane), UNITY_MATRIX_I_VP);
                float3 farPoint = TransformHClipToWorld(float3(position.xy, farPlane), UNITY_MATRIX_I_VP);
                OUT.positionCS = position;
                OUT.nearPoint = nearPoint;
                OUT.farPoint = farPoint;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // 计算地平面
                float t = -IN.nearPoint.y / (IN.farPoint.y - IN.nearPoint.y);
                float3 positionWS = IN.nearPoint + t * (IN.farPoint - IN.nearPoint);
                half ground = step(0, t);

                float3 cameraPos = _WorldSpaceCameraPos;
                float fromOrigin = abs(cameraPos.y);

                float viewZ = computeViewZ(positionWS);
                float2 uv = positionWS.xz;

                // 计算Grid
                float fading = max(0.0, 1.0 - viewZ / 40);
                half grid = HexGrid(uv);
                
                return half4(0.5, 0.5, 0.5, ground * grid * fading * 0.5);
            }
            ENDHLSL
        }
    }
}
