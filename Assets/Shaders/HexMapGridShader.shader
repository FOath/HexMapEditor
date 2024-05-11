Shader "Custom/HexMapGridShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _GridSize("GridSize", Float) = 0.5
        _LineWidth("LineWidth", Float) = 0.05
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Transparent"
        }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            const float2 s = float2(1.7320508, 1);
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 positionOS : TEXCOORD0;
            };

            half4 _Color;
            float _GridSize;
            float _LineWidth;

            float hex(float2 p)
            {
                p = abs(p);
                return max(dot(p, s * 0.5), p.y);
            }
            // This function returns the hexagonal grid coordinate for the grid cell, and the corresponding 
            // hexagon cell ID -- in the form of the central hexagonal point. That's basically all you need to 
            // produce a hexagonal grid.
            //
            // When working with 2D, I guess it's not that important to streamline this particular function.
            // However, if you need to raymarch a hexagonal grid, the number of operations tend to matter.
            // This one has minimal setup, one "floor" call, a couple of "dot" calls, a ternary operator, etc.
            // To use it to raymarch, you'd have to double up on everything -- in order to deal with 
            // overlapping fields from neighboring cells, so the fewer operations the better.
            float4 getHex(float2 p)
            {
                // The hexagon centers: Two sets of repeat hexagons are required to fill in the space, and
                // the two sets are stored in a "vec4" in order to group some calculations together. The hexagon
                // center we'll eventually use will depend upon which is closest to the current point. Since 
                // the central hexagon point is unique, it doubles as the unique hexagon ID.
                float4 hC = floor(float4(p, p - float2(1, 0.5))) + 0.5;

                // Centering the coordinates with the hexagon centers above.
                float4 h = float4(p - hC.xy * s, p - (hC.zw + 0.5) * s);
                return dot(h.xy, h.xy) < dot(h.zw, h.zw)
                    ? half4(h.xy, hC.xy) 
                    : half4(h.zw, hC.zw + 0.5);
            }

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionOS = IN.positionOS.xz;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                float2 h = getHex(IN.positionOS);

                float4 eDist = hex(h.xy);

                float col = lerp(1.0, 0.0, smoothstep(0, 0.03, eDist - 0.5 + 0.04));

                return half4(col, col, col, 0.5);
            }

            ENDHLSL
        }
    }
}
