using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 脚本挂载在摄像机
/// </summary>
[ExecuteInEditMode]
public class ScreenBroken : MonoBehaviour
{

    public Material mat;
    [Range(0, 0.1f)]
    public float NormalScale = 0;
    [Range(0, 1f)]
    public float LuminanceScale = 0.25f;


    /// <summary>
    /// 这个函数是在摄像机完成所有的渲染之后调用
    /// 让开发者对最后的屏幕片元进行后处理
    /// source参数是摄像机进行完所有渲染后传给开发者的
    /// destination参数是开发者处理完后传回给系统的
    /// 调用 unity好些地方都有这种做法 具体原因可以自行百度
    /// </summary>
    /// <param name="source"></param>
    /// <param name="destination"></param>
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //设置参数图像根据法线贴图的方向偏移的程度
        mat.SetFloat("_BrokenScale", NormalScale);
        mat.SetFloat("_LuminanceScale", LuminanceScale);
        

        //将source的图像通过mat的shader的
        //第1个pass渲染后传回给destination
        Graphics.Blit(source, destination, mat, 0);
    }
}
