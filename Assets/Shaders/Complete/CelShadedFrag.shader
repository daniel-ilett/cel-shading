Shader "CelShading/Complete/CelShadedFrag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Albedo color", Color) = (1, 1, 1, 1)
		_Antialiasing("Band Smoothing", Float) = 5.0
		_Glossiness("Glossiness/Shininess", Float) = 400
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque" 
			"LightMode"  = "ForwardBase"
			"PassFlags"  = "OnlyDirectional"
		}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
			float _Antialiasing;
			float _Glossiness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;

				float3 normal = normalize(i.worldNormal);
				float diffuse = dot(normal, _WorldSpaceLightPos0);

				float delta = fwidth(diffuse) * _Antialiasing;
				float diffuseSmooth = smoothstep(0, delta, diffuse);

				float3 halfVec = normalize(_WorldSpaceLightPos0 + i.viewDir);
				float specular = dot(normal, halfVec);
				specular = pow(specular * diffuseSmooth, _Glossiness);

				float specularSmooth = smoothstep(0, 0.01 * _Antialiasing, specular);

				fixed4 col = albedo * ((diffuseSmooth + specularSmooth) * _LightColor0 + unity_AmbientSky);
                return col;
            }
            ENDCG
        }
    }
}
