Shader "Complete/retr0/TextureBlend"
{
   Properties
   {
       _MainTexture("Main Texture", 2D) = "white" {}
       _BlendTexture("Blend Texture", 2D) = "white" {}
       _BlendFactor("Blend Factor", Range(0, 1)) = 1
       [KeywordEnum(Add, Subtract, Multiply, Overlay)] _BlendMode("Blend Mode", Float) = 0
   }
  
   SubShader
   {
       Pass
       {
           HLSLPROGRAM
           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           #pragma vertex vert
           #pragma fragment frag
                      
           #pragma multi_compile _BLENDMODE_ADD _BLENDMODE_SUBTRACT _BLENDMODE_MULTIPLY _BLENDMODE_OVERLAY
          
           Texture2D _MainTexture;
           SamplerState sampler_MainTexture;
          
           Texture2D _BlendTexture;
           SamplerState sampler_BlendTexture;
          
           float _BlendFactor;
                      
           struct VertexInput
           {
               float3 vertex : POSITION;
               float2 uv : TEXCOORD0;
           };
          
           struct FragmentInput
           {
               float4 positionHCS : SV_POSITION;
               float2 uv : TEXCOORD0;
           };
          
           FragmentInput vert(VertexInput input)
           {
               FragmentInput output;
               output.positionHCS = TransformObjectToHClip(input.vertex);
               output.uv = input.uv;
               return output;
           }
          
           half4 frag(FragmentInput input) : SV_Target
           {
               half4 baseColor = SAMPLE_TEXTURE2D(_MainTexture, sampler_MainTexture, input.uv);
               half4 blendColor = SAMPLE_TEXTURE2D(_BlendTexture, sampler_BlendTexture, input.uv);
  
               half4 result = half4(0, 0, 0, 0);
               #if defined(_BLENDMODE_ADD)
                   result = baseColor + blendColor;
               #elif defined(_BLENDMODE_SUBTRACT)
                   result = baseColor - blendColor;
               #elif defined(_BLENDMODE_MULTIPLY)
                   result = baseColor * blendColor;
               #elif defined(_BLENDMODE_OVERLAY)
                   result.rgb = (baseColor.rgb < 0.5) ? (2.0 * baseColor.rgb * blendColor.rgb)
               : (1.0 - 2.0 * (1.0 - baseColor.rgb) * (1.0 - blendColor.rgb));
               #endif
               
               result = lerp(baseColor, result, _BlendFactor);
               // 알파는 블랜드 하지 않고 메인 텍스처의 것을 그대로 사용
               result.a = baseColor.a;

               return result;
           }

           ENDHLSL
       }
   }
}


