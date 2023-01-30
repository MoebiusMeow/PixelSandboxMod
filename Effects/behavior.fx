﻿float uTime;

float2 uStep;

texture2D uTex0;
sampler2D uImage0 = sampler_state
{
    Texture = <uTex0>;
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture2D uTex1;
sampler2D uImage1 = sampler_state
{
    Texture = <uTex1>;
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture2D uTex2;
sampler2D uImageMask = sampler_state
{
    Texture = <uTex2>;
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture2D uTex3;
sampler2D uImageLight = sampler_state
{
    Texture = <uTex3>;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

// Compute

struct ComputeFragmentIn
{
    float4 pos : POSITION0;
    float2 coords : TEXCOORD0;
};

float4 computeFrag(ComputeFragmentIn input) : COLOR0
{
    float4 center = tex2D(uImage1, input.coords);
    float4 centerm = tex2D(uImageMask, input.coords);
    float4 down   = tex2D(uImageMask, input.coords + float2(0, uStep.y));
    float4 downm  = tex2D(uImage1, input.coords + float2(0, uStep.y));
    float4 up     = tex2D(uImage1, input.coords + float2(0, -uStep.y));
    float4 left   = tex2D(uImage1, input.coords + float2(-uStep.x, 0));
    float4 leftm  = tex2D(uImageMask, input.coords + float2(-uStep.x, 0));
    float4 right  = tex2D(uImage1, input.coords + float2(uStep.x, 0));
    float4 upl    = tex2D(uImage1, input.coords + float2(-uStep.x, -uStep.y));
    float4 downr  = tex2D(uImage1, input.coords + float2(uStep.x, uStep.y));
    float4 downrm = tex2D(uImageMask, input.coords + float2(uStep.x, uStep.y));
    // float upr = tex2D(uImage1, input.coords + float2( uStep.x, -uStep.y));
    // if (input.coords.y + 2 * uStep.y >= 1.0) return float4(1, 0, 0, 1);
    if (centerm.a > 0)
        return float4(0, 0, 0, 0);
    if (center.a > 0)
    {
		if ((down.a > 0 || downm.a > 0) && (downr.a > 0 || downrm.a > 0))
			return center;
        return float4(0, 0, 0, 0);
    }
    if (up.a > 0)
    {
        return up;
    }
    else if ((left.a > 0 || leftm.a > 0) && upl.a > 0)
    {
        return upl;
    }
    else
    {
        return float4(0, 0, 0, 0);
    }
}

float4 displayFrag(ComputeFragmentIn input) : COLOR0
{
    float4 center = tex2D(uImage1, input.coords);
    float4 light = tex2D(uImageLight, input.coords);
    if (center.a > 0)
		return float4(center.rgb * light.rgb, 1);
    return float4(0, 0, 0, 0);
}

technique Technique233
{
    pass Compute
    {
        PixelShader  = compile ps_3_0 computeFrag(); 
    }

    pass Display
    {
        PixelShader  = compile ps_3_0 displayFrag(); 
    }
}
