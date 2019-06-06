Shader "CelShading/Complete/OutlineCelShaded"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal/Bump Map", 2D) = "bump" {}
		_Color ("Tint Color", Color) = (1,1,1,1)
		_Antialiasing("Band Smoothing", Float) = 5.0
		_Glossiness("Glossiness/Shininess", Float) = 400
		_Fresnel("Fresnel/Rim Amount", Range(0, 1)) = 0.5
		_OutlineSize("Outline Size", Float) = 0.01
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

		Stencil
		{
			Ref 1
			Comp always
			Pass replace
			ZFail keep
		}

        CGPROGRAM
		#pragma surface surf Cel

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _Color;
		float _Antialiasing;
		float _Glossiness;
		float _Fresnel;

		float4 LightingCel(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			float3 normal = normalize(s.Normal);

			float diffuse = dot(normal, lightDir);

			float delta = fwidth(diffuse) * _Antialiasing;
			float diffuseSmooth = smoothstep(0, delta, diffuse);

			float3 halfVec = normalize(lightDir + viewDir);
			float specular = dot(normal, halfVec);
			specular = pow(specular * diffuseSmooth, _Glossiness);

			float specularSmooth = smoothstep(0, 0.01 * _Antialiasing, specular);

			float rim = 1 - dot(normal, viewDir);
			rim = rim * pow(diffuse, 0.3);
			float fresnelSize = 1 - _Fresnel;

			float rimSmooth = smoothstep(fresnelSize, fresnelSize * 1.1, rim);

			float3 col = s.Albedo * ((diffuseSmooth + specularSmooth + rimSmooth) * _LightColor0 + unity_AmbientSky);
			return float4(col, s.Alpha);
		}

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
        }

        ENDCG

		Pass
		{
			Cull Front
			ZWrite OFF
			ZTest ON
			Stencil
			{
				Ref 1
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _OutlineSize;
			float4 _OutlineColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float3 normal = normalize(v.normal) * _OutlineSize;
				float3 pos = v.vertex + normal;

				o.vertex = UnityObjectToClipPos(pos);

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return _OutlineColor;
			}

			ENDCG
		}
    }

    FallBack "Diffuse"
}