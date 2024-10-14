# ShaderLearning
 shader学习工程  
---
### Batching 合批
+ srp batcher:相同shader变体，不使用MaterialPropertyBlock
+ gpu instancing:相同mesh, 相同material，可以使用MaterialPropertyBlock
+ dynamic batching:相同material, mesh有顶点属性数量限制
  
![image](https://github.com/user-attachments/assets/e1a46fb1-528a-4bf1-b265-fc531a0ca454)
![image](https://github.com/user-attachments/assets/f0555b6f-f088-4815-9d3f-2f0d332ccdd7)

---
### Bloom 后处理
原文：https://catlikecoding.com/unity/tutorials/custom-srp/post-processing/

泛光效果，表示颜色色散，可以通过模糊图片方式实现
明亮的像素流向临近的较暗的像素，从而表现出泛光效果。(Bright pixels will bleed into adjacent darker pixels)

#### Bilinear downsampling下采样
最简单最快的模糊贴图方式是，将贴图拷贝到另一张宽高只有它一半大小的贴图中。双线性过滤，4x4像素平均到2x2像素块中。  
一次下采样只能模糊一点点。所以重复这个过程，逐步下采样直到达到一个期望的水平，建立一个金字塔纹理。

控制迭代次数的两种方式：
+ maxIterations 循环迭代次数
+ downscaleLimit 下采样尺寸
```hlsl
PostFXSettings.BloomSettings bloom = settings.Bloom;
int width = camera.pixelWidth / 2, height = camera.pixelHeight / 2;
RenderTextureFormat format = RenderTextureFormat.Default;
int fromId = sourceId, toId = bloomPyramidId;
int i;
for (i = 0; i < bloom.maxIterations; i++) {
    if (height < bloom.downscaleLimit || width < bloom.downscaleLimit) {
        break;
     }
     buffer.GetTemporaryRT(toId, width, height, 0, FilterMode.Bilinear, format);
     …
}
```
#### Gaussian Filtering 高斯模糊
2x2滤波器下采样产生块状模糊。用更大的滤波核提升效果。URP和HDRP用的是9x9高斯滤波器。   
81个采样可以拆分成水平和竖直两个pass，混合单行或者单列的9个采样。这样需要采样18次，每次迭代画两次。
``` hlsl
float4 BloomHorizontalPassFragment(Varing input) : SV_TAEGET{
    float3 color = 0.0;
    float offsets[] = {
        -4.0, -3.0,-2.0,-1.0, 0.0, 1.0, 2.0, 3.0, 4.0
    };
    float weights[] = {
            0.01621622, 0.05405405, 0.12162162, 0.19459459, 0.22702703,
            0.19459459, 0.12162162, 0.05405405, 0.01621622
    };
    for(int i = 0; i < 9; i++){
        float offset = offsets[i] * 2.0 * GetSourceTexelSize().x;
        color += GetSource(input.screenUV + float2(offset, 0.0)).rgb * weights[i];    
    }                         
    return float4(color, 1.0);
}
```
+ weights权重如何得到的？
权重来自帕斯卡三角形。对于一个合适的9×9高斯滤波器，我们会选择三角形的第九行，它是1 8 28 56 70 56 28 81 1。但这使得滤波器边缘的样本的贡献太弱而无法注意到，因此我们向下移动到第13行并切断其边缘，得到66 220 495 792 924 792 495 220 66。这些数的和是4070，所以每个数除以这个数得到最终的权重。
+ BloomVerticalPassFragment，同理进行竖直方向模糊,每次下采样会额外再需要一张rt，即：from 下采样 -> 水平模糊mid->垂直模糊to, 其中mid与to尺寸一致，均为from的1/2。  
+ 竖直方向的高斯模糊可以进一步优化，使用双线性滤波在高斯采样点之间以适当的偏移量采样可以减少采样数量。这样9个样本可以减少到5个。
+ 水平方向的高斯模糊不能这么做是因为在下采样的过程中已经进行了双线性过滤，9个采样点平均到了2x2的源像素。
```hlsl
float offsets[] = {-3.23076923, -1.38461538, 0.0, 1.38461538, 3.23076923    };
float weights[] = {0.07027027, 0.31621622, 0.22702703, 0.31621622, 0.07027027    };
```
#### Upsampling上采样 叠加模糊
使用金字塔顶部的贴图作为最终图得不到泛光效果。
进行逐步上采样回到金字塔底，在一个图像中积累每个层的效果。
```hlsl
float4 BloomCombinePassFragment (Varyings input) : SV_TARGET {    
    float3 lowRes = GetSource(input.screenUV).rgb;    
    float3 highRes = GetSource2(input.screenUV).rgb;    
    return float4(lowRes + highRes, 1.0);
}
```
#### 屏幕1/2分辨率开始采样
性能消耗比较大，可以从屏幕1/2分辨率开始生产贴图，跳过第一代，因为这个效果是柔和的，所以这样做没有问题。
#### Threshold阈值
使用亮度阈值提取贡献效果的像素，不能突然从效果中消除颜色，因为这会在期望逐渐过渡的地方引入尖锐的边界。所以将颜色乘以权值w=max(0,b−t)/max(b,0.00001).
还是有明显拐点，所以使用公式<img width="313" alt="image" src="https://github.com/user-attachments/assets/cb99a028-9562-47b5-8653-c07a9f41ccfb">

#### Intensity强度
```hlsl
float _BloomIntensity;
float4 BloomCombinePassFragment (Varyings input) : SV_TARGET {
    …    
     return float4(lowRes * _BloomIntensity + highRes, 1.0);
 }
```
---
### Screenspace coordinates
变换到裁剪空间 xy范围[-w,w]  
变换到屏幕空间 xy范围[0,1]
```hlsl
o.vertex = UnityObjectToClipPos(v.vertex);
o.screenUV = ComputeScreenPos(o.vertex)/o.vertex.w;
// float2 position = o.vertex / o.vertex.w;
// position = (position + 1) * 0.5;
// o.screenUV = position.xy;
// o.screenUV.y = 1 - o.screenUV.y;
```
<img width="554" alt="image" src="https://github.com/user-attachments/assets/371ee4e9-7a13-448a-be8c-451708fa66bd">

--- 
### 噪声
- 2D噪声扰动圆半径
<img width="1135" alt="image" src="https://github.com/user-attachments/assets/a3819294-59b1-40cd-9952-c36a289bc19b">

--- 
### SDF  
```hlsl
// 圆 
float Circle(float2 st, float r)
{
    const float2 dist = st - float2(0.5, 0.5);
    return 1 - smoothstep(r - r*0.01, r + r*0.01, dot(dist, dist) * 4);
}
```
<img width="554" alt="image" src="https://github.com/user-attachments/assets/63c0cac2-f7c0-4cd1-a09f-1874bfa8574e">

---
### ComputeShader 计算着色器
- kernel  计算函数
- [numthreads(x,y,z)] 线程组大小
- Dispatch  执行
- 线程和线程组的ID
- GetData 从buffer中获取数据写回到ram中
<img width="554" alt="image" src="https://github.com/user-attachments/assets/23d5b21b-2d51-4f4d-8a40-19b15a1e1817">

---
### SelectionOutline 选中物体描边
- 创建OutlineRenderFeature，在OutlineRenderPass中，将选中的物体画到RenderTexture(带alpha)中
- 采样像素周围8方向RT的alpha值，取最大值
- 最大alpha值减去RT的alpha，清除物体正常绘制部分alpha(1-1=0)，得到描边边缘的alpha(~=1)
- 用新alpha值插值绘制颜色和描边颜色值
<img width="554" alt="image" src="https://github.com/user-attachments/assets/4a011068-2a70-4ff5-bc3e-47dcfe16fd54">

---
### Outline  描边
- 额外增加一个pass, 延法线方向外扩顶点
<img width="554" alt="image" src="https://github.com/user-attachments/assets/70e66143-265e-4f5f-9ad4-907f9b9a7e49">
