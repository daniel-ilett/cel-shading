Shader "CelShading/Complete/CelShadedSurf"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
		_Antialiasing("Band Smoothing", Float) = 5.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
		#pragma surface surf Cel

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;
		float _Antialiasing;

		float4 LightingCel(SurfaceOutput s, half3 lightDir, half atten)
		{
			float3 normal = normalize(s.Normal);
			float diffuse = dot(normal, lightDir);

			float delta = fwidth(diffuse) * _Antialiasing;
			float diffuseSmooth = smoothstep(0, delta, diffuse);

			float3 col = s.Albedo * (diffuseSmooth * _LightColor0 + unity_AmbientSky);
			return float4(col, s.Alpha);
		}

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
        }

        ENDCG
    }

    FallBack "Diffuse"
}
