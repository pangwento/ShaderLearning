#ifndef BASE_NOISE_INCLUDED
#define BASE_NOISE_INCLUDED

#include "../Shaders/Random.hlsl"

float noise(float x)
{
    float i = floor(x);
    float f = frac(x);

    float a = random1(i);
    float b = random1(i+1.0);

    float u = f * f * (3.0 - 2 * f);
    return lerp(a, b, u);
}

float noise(float2 st)
{
    float2 i = floor(st);
    float2 f = frac(st);
    
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(1.0, 1.0));
    float d = random(i + float2(0.0, 1.0));
    
    float2 u = f * f * (3.0 - 2.0 * f);
    
    float ab = lerp(a, b, u.x);
    float dc = lerp(d, c, u.x);
    
    return lerp(ab, dc, u.y);
}

float noise2D(float2 st)
{
    float c = noise(st * 8.0);
    c += noise(st * 16.0) * 0.5;
    c += noise(st * 32.0) * 0.25;
    c += noise(st * 64.0) * 0.125;
    c /= 2.0;
    return c;
}


#endif