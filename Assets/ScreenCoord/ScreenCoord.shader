Shader "Base/ScreenCoord"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 screenUV : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // float2 position = o.vertex / o.vertex.w;
                // position = (position + 1) * 0.5;
                // o.screenUV = position.xy;
                // o.screenUV.y = 1 - o.screenUV.y;
                o.screenUV = ComputeScreenPos(o.vertex)/o.vertex.w;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float aspect = _ScreenParams.x / _ScreenParams.y;
                float2 screenUV = i.screenUV;
                screenUV.x = screenUV.x * aspect;
                screenUV = TRANSFORM_TEX(screenUV, _MainTex);
                fixed4 col = tex2D(_MainTex, screenUV);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
