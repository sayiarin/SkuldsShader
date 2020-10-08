#if UNITY_EDITOR
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System;

public class SkuldsShaderLFRTEditor : SkuldsShaderEditor
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        LFRTOptions();
    }

    bool LFRTGroup = false;
    public static Transform location;
    void LFRTOptions()
    {
        LFRTGroup = EditorGUILayout.Foldout(LFRTGroup, "Light From Render Texture", skuldHeader);
        if (LFRTGroup)
        {
            EditorGUILayout.BeginVertical(EditorStyles.textArea);
            MaterialProperty renderTexture = FindProperty("_ETex", properties);
            materialEditor.TextureProperty(renderTexture, "Texture:");

            MaterialProperty locationV = FindProperty("_EPosition", properties);
            materialEditor.VectorProperty(locationV, "Light Location:");

            EditorGUILayout.BeginHorizontal();
            location = (Transform)EditorGUILayout.ObjectField("Set From Transform:", location, typeof(Transform), true);
            if (GUILayout.Button("Set"))
            {
                if (location != null)
                {
                    material.SetVector("_EPosition", location.position);
                }
            }
            EditorGUILayout.EndHorizontal();

            MaterialProperty eIntensity = FindProperty("_EBrightness", properties);
            materialEditor.FloatProperty(eIntensity, "Intensity:");

            MaterialProperty eRange = FindProperty("_ERange", properties);
            materialEditor.FloatProperty(eRange, "Range:");

            MaterialProperty eSample = FindProperty("_ESamples", properties);
            materialEditor.VectorProperty(eSample, "Samples (X*Y):");

            EditorGUILayout.EndVertical();
        }
    }
}
#endif