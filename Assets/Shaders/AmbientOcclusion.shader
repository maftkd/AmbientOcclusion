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
            float3 _SSAOKernel[64];
            float _Radius;
            float _Bias;
            float4x4 _ProjectionMatrix;

            fixed4 frag (v2f IN) : SV_Target
            {
                float3 myPos = tex2D(_GPosition, IN.uv).rgb;
                float3 normal = tex2D(_GNormal, IN.uv).rgb;
                float myDepth = myPos.z;

                float3 tangent = cross(normal, float3(0, 1, 0));
                //float3 tangent   = normalize(0 - normal * dot(0, normal));
                float3 bitangent = cross(normal, tangent);
                float3x3 TBN = float3x3(tangent, bitangent, normal);
                
                float occlusion = 0;
                float4 coords = 0;
                for(int i = 0; i < 64; i++)
                {
                    float3 rayDir = _SSAOKernel[i];
                    rayDir = mul(TBN, rayDir);
                    float3 samplePos = myPos + rayDir * _Radius;

                    //convert from view space back to a uv coordinate we can use to resample the position
                    coords = float4(samplePos, 1);
                    coords = mul(_ProjectionMatrix, coords);
                    coords.xyz /= coords.w;
                    coords.xy = coords.xy * 0.5 + 0.5;

                    float sampleDepth = tex2D(_GPosition, coords.xy).z;

                    occlusion += sampleDepth >= myDepth + _Bias ? 1 : 0;
                }

                occlusion = occlusion / 64;
                return occlusion;
                //return -occlusion * 0.01;
                
                /*
                //tmp
                int index = 1;
                float3 kernelTest = float3(_SSAOKernel[index * 3], _SSAOKernel[index * 3 + 1], _SSAOKernel[index * 3 + 2]);
                return float4(kernelTest, 1);
                */

                /*
                fixed3 pos = tex2D(_GPosition, IN.uv);
                return -pos.z * 0.01;
                */
                fixed3 norm = tex2D(_GNormal, IN.uv);
                return fixed4(norm, 1);

                if(IN.uv.x < 0.3333)
                {
                    fixed3 albedo = tex2D(_GAlbedo, IN.uv);
                    return fixed4(albedo, 1);
                }
                else if(IN.uv.x < 0.6667)
                {
                    fixed3 norm = tex2D(_GNormal, IN.uv);
                    return fixed4(norm, 1);
                }
                else
                {
                    fixed3 pos = tex2D(_GPosition, IN.uv);
                    return fixed4(pos, 1);
                }
            }
            ENDCG
        }
    }
}
