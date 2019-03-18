Shader "Custom/WaterSim2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "bump" {}
        _NormamMap ("Normal Map", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        _WaveHeight ("Wave Height", Float) = 1.0
        waveDir ("Wave Direction", Vector) = (1,1,0,0)
        tex1Dir ("Texture Scroll Direction 1", Float) = 0
        tex2Dir ("Texture Scroll Direction 2", Float) = 0
        waveSpeed ("Wave Speed", Float) = 0
        tex1Speed ("Texture Scroll Speed 1", Float) = 0
        tex2Speed ("Texture Scroll Speed 2", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
        #pragma vertex vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
        sampler2D _HeightMap;
        sampler2D _NormalMap;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
        half _WaveHeight;
        float4 waveDir;
        half waveSpeed;
        half tex1Dir;
        half tex1Speed;
        half tex2Dir;
        half tex2Speed;

        void vert (inout appdata_full v)
        {
            float disp = waveSpeed * _Time[1];
            float4 offset = waveDir * disp;
            float4 amount = tex2Dlod(_HeightMap, v.texcoord + offset) * _WaveHeight;
            //float4 normal = tex2Dlod(_NormalMap, v.texcoord + offset);
            //float3 normal2 = UnpackNormal(normal);
            v.vertex.y += amount.r;
        }

		void surf (Input IN, inout SurfaceOutputStandard o) {
            float disp1 = _Time[1] * tex1Speed;
            float disp2 = _Time[1] * tex2Speed;
            float2 offset1 = (cos(tex1Dir) * disp1, sin(tex1Dir) * disp1);
            float2 offset2 = (cos(tex2Dir) * disp2, sin(tex2Dir) * disp2);
            fixed4 c1 = tex2D(_MainTex, IN.uv_MainTex.xy + offset1);
            fixed4 c2 = tex2D(_MainTex, IN.uv_MainTex.xy + offset2);
			fixed4 c = (c1 + c2) / 2 * _Color;
            float disp = waveSpeed * _Time[1];
            float2 offset = (cos(waveDir) * disp, sin(waveDir) * disp);
            half amount = tex2D (_HeightMap, IN.uv_MainTex.xy + offset) * _WaveHeight;
            float4 normal = tex2D(_NormalMap, IN.uv_MainTex.xy + offset);
            o.Normal = UnpackNormal(normal);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.r;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
