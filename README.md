# ShaderLearning
 shader学习工程  
 
---
### SelectionOutline 选中的物体进行描边
- 创建OutlineRenderFeature，在OutlineRenderPass中，将选中的物体画到RenderTexture(带alpha)中
- 采样像素周围8方向RT的alpha值，取最大值
- 最大alpha值减去RT的alpha，清除物体正常绘制部分alpha(1-1=0)，得到描边边缘的alpha(~=1)
- 用新alpha值插值绘制颜色和描边颜色值
<img width="554" alt="image" src="https://github.com/user-attachments/assets/4a011068-2a70-4ff5-bc3e-47dcfe16fd54">

---
### Outline  描边
- 额外增加一个pass, 延法线方向外扩顶点
<img width="605" alt="image" src="https://github.com/user-attachments/assets/70e66143-265e-4f5f-9ad4-907f9b9a7e49">
