Shader "Custom/WaterSim" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _TexDir ("Texture Direction", Vector) = (0, 0, 0, 0)
        _HeightDir ("Wave Direction", Vector) = (0, 0, 0, 0)
	}
	SubShader {
		Tags { "RenderType"="Fade" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
        sampler2D _HeightMap;
        float2 _TexDir;
        float2 _HeightDir;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

        void vert (inout appdata_full v)
        {
			float4 texcoord = v.texcoord;
			texcoord.xy += _Time * _HeightDir;
			texcoord.w = 0;
            v.vertex.y += tex2Dlod(_HeightMap, texcoord).r;
        }

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex.xy + _Time * _TexDir.xy) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			/*o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;*/
		}
		ENDCG
	}
	FallBack "Diffuse"
}
