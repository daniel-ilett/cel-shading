Shader "CelShading/Diffuse"
{
    Properties
    {

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
		#pragma surface surf Standard

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = 1.0;
        }

        ENDCG
    }

    FallBack "Diffuse"
}
