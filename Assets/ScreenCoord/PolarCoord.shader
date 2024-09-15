Shader "Unlit/PolarCoord"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed", float) = 0.5
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
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            float2 toPolar(float2 cartesian)
            {
                float distance = length(cartesian);
                float angle = atan2(cartesian.y, cartesian.x);
                return float2(angle / UNITY_TWO_PI, distance);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                i.uv -= 0.5;
                i.uv *= 2;
                float2 uv = toPolar(i.uv);
                uv.x *= 3;
                uv.x += _Time.y * _Speed;
                fixed4 col = tex2D(_MainTex, uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }
    }
}
