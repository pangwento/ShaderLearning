Shader "Base/Single Texture"
{
    properties 
    {
        _MainTex ("Main Tex", 2D) = "while" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(0.8, 256)) = 20
    }

    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "UniversalForward"}
        
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            sampler2D _MainTex;
            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
                UNITY_DEFINE_INSTANCED_PROP(half4, _Color)
                UNITY_DEFINE_INSTANCED_PROP(float, _Gloss)
                UNITY_DEFINE_INSTANCED_PROP(half4, _Specular)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
            struct a2v
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos :TEXCOORD1;
                float2 uv : TEXTURECOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert(a2v v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                //o.pos = mul(UNITY_MATRIX_MVP, v.positionOS);
                VertexPositionInputs inputVertex = GetVertexPositionInputs(v.positionOS.xyz);
                o.pos = inputVertex.positionCS;
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldPos = inputVertex.positionWS;
                float4 st = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
                o.uv = v.texcoord.xy * st.xy + st.zw;
                //o.uv = TRANSFORM_TEX(v.texcoord,  _MainTex);
                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half3 albedo = tex2D(_MainTex, i.uv).rgb * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color.rgb);
                half3 ambient = unity_AmbientGround.xyz * albedo;

                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize((_MainLightPosition.xyz - i.worldPos));
                half3 diffuse = _MainLightColor.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                half3 viewDir = GetWorldSpaceNormalizeViewDir(i.worldPos);
                half3 halfVector = normalize(viewDir + worldLightDir);

                half3 specular = _MainLightColor.rbg * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Specular.rgb)  * pow(max(0, dot(worldNormal, halfVector)),
                    UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Gloss));

                return half4(ambient + diffuse + specular, 1.0);
            }
            ENDHLSL
        }
    }
}