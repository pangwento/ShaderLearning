#ifndef BASE_RANDOM_INCLUDED
#define BASE_RANDOM_INCLUDED
float random(float x)
{
    return frac(sin(x) * 100000.0);
}

float rand1dTo1d(float value, float mutator = 0.546){
    return frac(sin(value + mutator) * 43758.5453);
}

float rand2dTo1d(float2 st)
{
    return frac(sin(dot(st.xy, float2(12.9898,78.233)) * 43758.5453123));
}

float2 rand1dTo2d(float value)
{
    return float2(
        rand2dTo1d(float2(value, 3.9812)),
        rand2dTo1d(float2(value, 7.1536))
    );
}
float3 rand1dTo3d(float value){
    return float3(
        rand1dTo1d(value, 3.9812),
        rand1dTo1d(value, 7.1536),
        rand1dTo1d(value, 5.7241)
    );
}
#endif