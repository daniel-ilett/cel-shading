Shader "CelShading/Complete/DiffuseFrag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Albedo color", Color) = (1, 1, 1, 1)
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;

				float3 normal = normalize(i.worldNormal);
				float diffuse = dot(_WorldSpaceLightPos0, normal);

				fixed4 col = albedo * (diffuse * _LightColor0 + unity_AmbientSky);
                return col;
            }
            ENDCG
        }
    }
}
