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
