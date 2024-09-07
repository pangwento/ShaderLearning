Shader "Unlit/Shapes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", Range(0.0, 1.0)) = 0.1 
        _Border("Border Smooth", Range(0, 0.5)) = 0.01
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
            float _Radius;
            float _Border;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float rectangle(float2 st, float r)
            {
                float2 lb = step(r, st);
                float2 rt = step(r, 1.0 - st);
                return lb.x * lb.y * rt.x * rt.y;
            }

            float smoothRectangle(float2 st, float r, float b)
            {
                float2 lb = smoothstep(r, r + b, st);
                float2 rt = smoothstep(r, r + b, 1.0 - st);
                return lb.x * lb.y * rt.x * rt.y;
            }
            float floorRectangle(float2 st, float r)
            {
                float2 lb = floor(st + 1.0 - r);
                float2 rt = floor(1.0 - st + 1.0 - r);
                return lb.x * lb.y * rt.x * rt.y;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float pct = rectangle(i.uv, _Radius);
                //float pct = smoothRectangle(i.uv, _Radius, _Border);
                float pct = floorRectangle(i.uv, _Radius);
                
                fixed4 col = fixed4(pct,pct,pct,1.0);
                return col;
            }
            ENDCG
        }
    }
}
