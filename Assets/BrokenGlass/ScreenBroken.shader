﻿Shader "Custom/RenderImage/ScreenBroken" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}

		_BrokenNormalMap("BrokenNormal Map",2D)="bump"{}

		_LuminanceScale("LuminanceScale", Range(0, 1.0))=0.25

		_BrokenScale("BrokenScale",Range(0, 0.2))=0.1


	}
	SubShader {
		
 
		Pass{
			Tags { "LightMode"="ForwardBase" }
 
			CGPROGRAM
 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
 
			#pragma vertex vert
			#pragma fragment frag
 
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BrokenNormalMap;
			float4 _BrokenNormalMap_ST;
			float _BrokenScale;
			float _LuminanceScale;
 
			

			struct a2v{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
 
			//输出部分要和输入部分对应起来
			//而输出部分又要由片元着色器里的计算模型来确定
			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};
 
			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex);

				o.uv.zw=TRANSFORM_TEX(v.texcoord, _BrokenNormalMap);
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target{
				//读取片元对应法线贴图的颜色
				fixed4 packedNormal = tex2D(_BrokenNormalMap,i.uv.zw);

				fixed3 tangentNormal;
				//将颜色转换成法线方向
				tangentNormal=UnpackNormal(packedNormal);
				
				//将法线方向按照原来倾斜的方向倾斜更多
				tangentNormal.xy *= _BrokenScale;


				float2 offset =  tangentNormal.xy;
				
				//如果没有offset 则每个片元则按照
				//自己在主帖图的原uv位置读取颜色值
				//加了offset表示的意思是原uv位置基础上
				//加上片元对应玻璃破碎法线贴图上法线偏移值来
				//读取颜色值
				//一般法线贴图除了碎痕，某个片区都是一边倒的
				//因为一个片区的颜色一般都一致 所以片区的法线的xy值是一致的
				//这样就呈现出了片区的图像是原图往一个方向偏移的效果
				fixed3 col= tex2D(_MainTex, i.uv.xy + offset).rgb;
				

				
				//取得片元本身颜色的平均值
				//片元本身颜色值越深 其平均值越大
				fixed luminance = (col.r + col.g + col.b) / 3;

				//将颜色的rgb值变得一样
				//rgb值一致的时候 颜色是属于白灰黑色系
				//值越小越偏黑 越偏大越偏白 中间过渡阶段是各种灰色
				fixed3 gray = fixed3(luminance,luminance,luminance);

				//lerp函数使得
				//finalCol的范围在gray和col之间
				//_LuminanceScale为0的时候是gray
				//_LuminanceScale为1的时候是col
				fixed3 finalCol = lerp(gray, col,
				_LuminanceScale);
				
				return fixed4(finalCol, 1.0f);//这里如果不需要有灰度值变化，也可以直接使用col作为输出
			}
			ENDCG
			}
		
		}
	FallBack "Diffuse"
}
