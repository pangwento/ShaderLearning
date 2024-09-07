Shader "Unlit/ShapingFunctions"
{
    Properties
    {
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            float plot(float2 st)
            {
                return smoothstep(0.01, 0, abs(st.y -st.x));
            }
            float plot(float2 st, float pct)
            {
                return smoothstep(pct - 0.01, pct, st.y) -
                    smoothstep(pct, pct + 0.01, st.y);
            }
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float y = pow(i.uv.x, 5.0);
                fixed3 col = fixed3(y, y, y);
                float p = plot(i.uv, y);
                col = (1 - p)*col + p*fixed4(0.0, 1.0, 0.0, 1.0);
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
