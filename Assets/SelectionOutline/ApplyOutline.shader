Shader "Unlit/ApplyOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1, 0, 0, 1)
        _OutlineThickness("Outline Thickness", Range(0,  1) ) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _OutlineColor;
            float _OutlineThickness;
            sampler2D _SelectionBuffer;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #define DIV_SQRT_2 0.70710678118
                float2 directions[8] =
                {
                    float2(1,0), float2(0,1),float2(-1,0),float2(0,-1),
                    float2(DIV_SQRT_2, DIV_SQRT_2), float2(-DIV_SQRT_2, DIV_SQRT_2),
                    float2(-DIV_SQRT_2, -DIV_SQRT_2), float2(DIV_SQRT_2, -DIV_SQRT_2)
                };
                float aspect = _ScreenParams.x * (_ScreenParams.w - 1);
                float2 sampleDistance = float2(_OutlineThickness / aspect, _OutlineThickness);

                float maxAlpha = 0;
                for(uint index = 0; index < 8; index++)
                {
                    float2 sampleUV = i.uv + directions[index] * sampleDistance;
                    maxAlpha = max(maxAlpha, tex2D(_SelectionBuffer, sampleUV).a);
                }

                float border = max(0, maxAlpha - tex2D(_SelectionBuffer, i.uv).a);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col = lerp(col, _OutlineColor, border);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
