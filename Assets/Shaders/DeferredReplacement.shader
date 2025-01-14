Shader "Unlit/DeferredReplacement"
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewPos : TEXCOORD2;
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = normalize(mul((float3x3)UNITY_MATRIX_MV, v.normal));
                o.viewPos = UnityObjectToViewPos(v.vertex);
                return o;
            }

            fragmentOutput frag (v2f i) : SV_Target
            {
                fragmentOutput o;
                o.albedo = _Color;
                o.normal = float4(i.normal, 1.0);
                o.position = float4(i.viewPos, 1.0);
                return o;
            }
            ENDCG
        }
    }
}
