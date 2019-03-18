Shader "Custom/Toon" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (0,0,0,0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_ShadowThreshold ("Shadow Threshold", Range(0,1)) = 0.5
        _OutlineThreshold ("Outline Threshold", Range(-1, 1)) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Toon
        #include "UnityCG.cginc"

		struct Input {
			float2 uv_MainTex;
            float3 viewDir;
		};

        half4 _Color;
        half4 _OutlineColor;
        sampler2D _MainTex;
        half _ShadowThreshold;
        half _OutlineThreshold;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half angle = dot(IN.viewDir, o.Normal);
            half outlined = step(angle, _OutlineThreshold);
			fixed4 c1 = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 c2 = _OutlineColor;
            fixed4 c = outlined * c2 + (1 - outlined) * c1;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

        half4 LightingToon(SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, -lightDir) * 0.5 + 0.5;
            half light = step(NdotL * atten, _ShadowThreshold);
            float4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * light;
            c.a = s.Alpha;
            return c;
        }

		ENDCG
	}
	FallBack "Diffuse"
}
