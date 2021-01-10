#if UNITY_EDITOR
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

public class SkuldsShaderTerrainEditor : SkuldsShaderEditor
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);
        TerrainOptions();
    }

    bool TerrainGroup = false;
    public static Transform location;
    void TerrainOptions()
    {
        TerrainGroup = EditorGUILayout.Foldout(TerrainGroup, "Terrain", skuldHeader);
        if (TerrainGroup)
        {
            EditorGUILayout.BeginVertical(EditorStyles.textArea);
            MaterialProperty fadeRange = FindProperty("_FadeRange", properties);
            materialEditor.FloatProperty(fadeRange, "Fade Range:");

            EditorGUILayout.BeginVertical(EditorStyles.textArea);
            EditorGUILayout.LabelField("Layer 0:", EditorStyles.boldLabel);
            MaterialProperty basetex = FindProperty("_MainTex", properties);
            materialEditor.TextureProperty(basetex, "texture:");
            MaterialProperty basenormal = FindProperty("_NormalTex", properties);
            materialEditor.TextureProperty(basenormal, "normals:");
            EditorGUILayout.EndVertical();
            MaterialProperty[] height = new MaterialProperty[7];
            MaterialProperty[] tex = new MaterialProperty[7];
            MaterialProperty[] normal = new MaterialProperty[7];
            for ( int i = 1; i < 4; i++)
            {
                EditorGUILayout.BeginVertical(EditorStyles.textArea);

                EditorGUILayout.LabelField("Layer " + i + ":", EditorStyles.boldLabel);

                height[i - 1] = FindProperty("_Height"+i, properties);
                materialEditor.FloatProperty(height[i - 1], "Height:");

                tex[i - 1] = FindProperty("_Tex"+i, properties);
                materialEditor.TextureProperty(tex[i - 1], "texture:");

                normal[i - 1] = FindProperty("_Normal"+i, properties);
                materialEditor.TextureProperty(normal[i - 1], "normals:");

                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndVertical();
        }
    }
}
#endif