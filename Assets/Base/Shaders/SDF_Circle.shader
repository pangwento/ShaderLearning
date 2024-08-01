Shader "Unlit/SDF_Circle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0,0.5,1,1)
        _BackgroundColor ("Background Color", Color) = (0,0,0,0)
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

             // 求出点到圆心的距离，减去半径，得到的值就是点到圆的距离
            float sdfCircle(float2 coord, float2 center, float radius)
            {
                float2 d = coord - center;
                return length(d) - radius;
            }

            float4 render(float d, float3 color, float stroke)
            {
                float anti = fwidth(d) * 1.0;
                float alpha = smoothstep(-anti, anti, d);
                alpha = 1.0 - alpha;
                float4 c = float4(color, alpha);
                if(stroke < 0.000001)
                {
                    return c;
                }
                float4 s = float4(float3(0.05,0.05,0.05), 1.0 - smoothstep(-anti, anti, d - stroke));
                c = float4(lerp(s.rgb, c.rgb, c.a), s.a);
                return c;
            }
            
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
                float4 scrPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _BackgroundColor;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.scrPos = ComputeScreenPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 pixelPos = (i.scrPos.xy / i.scrPos.w) * _ScreenParams.xy;
                float a = sdfCircle(pixelPos, float2(0.5,0.5) * _ScreenParams.xy, 100);
                float4 layer1 = render(a, _Color, fwidth(a) * 2);
                return lerp(_BackgroundColor, layer1, layer1.a);
            }
            ENDCG
        }
    }
}
