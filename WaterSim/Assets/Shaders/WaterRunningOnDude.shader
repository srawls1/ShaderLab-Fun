Shader "Custom/WaterRunningOnDude" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Noise ("Noise Map", 2D) = "bump" {}
        _WaveSpeed ("Wave velocity: layer 1 (x, y), layer 2 (z, w)", Vector) = (1, 1, -1, 1)
        _Distortion ("Distortion", Float) = 1
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Opaque" "IgnoreProjector"="True" }
        ZWrite On
        Lighting Off
        Cull Off
        Fog { Mode Off }
        Blend One Zero

        GrabPass { }

        Pass
        {
    		CGPROGRAM
    		#pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            sampler2D _Noise;
            float4 _WaveSpeed;
            float _Distortion;
            sampler2D _GrabTexture;

    		struct vin_vct
            {
    			float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
    		};

            struct v2f_vct
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
            };

            v2f_vct vert(vin_vct i)
            {
                v2f_vct v;
                v.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
                v.color = i.color;
                v.texcoord = i.texcoord;
                v.uvgrab = ComputeGrabScreenPos(v.vertex);
                return v;
            }

            half4 frag(v2f_vct v) : COLOR
            {
                float4 disp = _WaveSpeed * (_Time[1]);
                half4 c1 = tex2D(_MainTex, v.texcoord) * _Color;

                float4 n1 = tex2D(_Noise, v.texcoord + disp.xy);
                float4 n2 = tex2D(_Noise, v.texcoord + disp.zw);
                float3 dist1 = UnpackNormal(n1) * 0.5f;
                float3 dist2 = UnpackNormal(n2) * 0.5f;
                v.uvgrab.xy += (dist1.xy + dist2.xy) * _Distortion;

#if UNITY_UV_STARTS_AT_TOP
                v.uvgrab.y *= -1;
#endif

                half4 c2 = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(v.uvgrab));
                //float4 col = lerp(c2, c1, c1.a);
                //float4 col = c1 * c1.a + c2 * (1 - c1.a);
                return c2;
            }
            ENDCG
        }
	}
	FallBack "Diffuse"
}
