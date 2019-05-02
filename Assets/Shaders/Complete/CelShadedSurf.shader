Shader "CelShading/Complete/CelShadedSurf"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
		#pragma surface surf Cel

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		half4 LightingCel(SurfaceOutput s, half3 lightDir, half atten)
		{
			float3 normal = normalize(s.Normal);
			half diffuse = dot(normal, lightDir);

			diffuse = diffuse > 0 ? 1 : 0;

			half3 col = s.Albedo * (diffuse * _LightColor0 + unity_AmbientSky);
			return half4(col, s.Alpha);
		}

        struct Input
        {
            float2 uv_MainTex;
        };

		sampler2D _MainTex;
		fixed4 _Color;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
        }

        ENDCG
    }

    FallBack "Diffuse"
}
