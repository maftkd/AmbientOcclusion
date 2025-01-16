Shader "Unlit/DeferredReplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                LIGHTING_COORDS(1, 2)
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD3;
                float3 viewPos : TEXCOORD4;
                float3 worldPos : TEXCOORD5;
            };

            struct fragmentOutput
            {
                float4 albedo : SV_Target0;
                float4 normal : SV_Target1;
                float4 position : SV_Target2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = normalize(mul((float3x3)UNITY_MATRIX_MV, v.normal));
                o.viewPos = UnityObjectToViewPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fragmentOutput frag (v2f i) : SV_Target
            {
                fragmentOutput o;
                float receivedShadow = 1 - UNITY_SHADOW_ATTENUATION(i, i.worldPos);
                //receivedShadow *= 0.2;
                if(i.worldPos.y < 0.01)
                {
                    //_Color = float4(1, 0, 0, 1);
                }
                o.albedo = lerp(_Color, float4(0.9, 0.95, 1.0, 1.0) * _Color * 0.8,receivedShadow);
                o.normal = float4(i.normal, 1.0);
                o.position = float4(i.viewPos, 1.0);
                return o;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
