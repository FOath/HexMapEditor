using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(GridManager))]
public class GenerateMapEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("生成地图"))
        {
            GridManager gridManager = (GridManager)target;
            if (gridManager != null)
            {
                gridManager.GenerateMap();
            }
        }

        if (GUILayout.Button("清除地图"))
        {
            GridManager gridManager = (GridManager)target;
            if (gridManager != null)
            {
                gridManager.DestroyMap();
            }
        }
    }
}
