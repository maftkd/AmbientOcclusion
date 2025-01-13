Shader "Hidden/AmbientOcclusion"
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
            float _SSAOKernel[300];

            fixed4 frag (v2f i) : SV_Target
            {
                //tmp
                int index = 1;
                float3 kernelTest = float3(_SSAOKernel[index * 3], _SSAOKernel[index * 3 + 1], _SSAOKernel[index * 3 + 2]);
                return float4(kernelTest, 1);

                
                if(i.uv.x < 0.3333)
                {
                    fixed3 albedo = tex2D(_GAlbedo, i.uv);
                    return fixed4(albedo, 1);
                }
                else if(i.uv.x < 0.6667)
                {
                    fixed3 norm = tex2D(_GNormal, i.uv);
                    return fixed4(norm, 1);
                }
                else
                {
                    fixed3 pos = tex2D(_GPosition, i.uv);
                    return fixed4(pos, 1);
                }
            }
            ENDCG
        }
    }
}
