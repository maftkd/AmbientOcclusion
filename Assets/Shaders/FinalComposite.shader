Shader "Hidden/FinalComposite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _GAlbedo;
            sampler2D _GNormal;
            sampler2D _GPosition;
            
            sampler2D _AmbientOcclusion;
            float4x4 _ViewMatrix;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 col = 0;
                float3 albedo = tex2D(_GAlbedo, i.uv).rgb;
                float3 normal = tex2D(_GNormal, i.uv).rgb;
                //return float4(normal, 1);
                float ssao = tex2D(_AmbientOcclusion, i.uv).r;
                float3 lightPos = _WorldSpaceLightPos0.xyz;
                lightPos = mul(_ViewMatrix, float4(lightPos, 0)).xyz;
                //return float4(lightPos, 1);
                float lightDot = saturate(dot(lightPos, normal));
                //return lightDot;
                float3 diffuse = albedo * lightDot;
                float3 ambient = albedo * 0.25;
                col += diffuse + ambient;
                col *= ssao;
                return float4(col, 1);
                return float4(albedo, 1) * ssao;
                return ssao;
            }
            ENDCG
        }
    }
}
