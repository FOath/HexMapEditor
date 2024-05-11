using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SearchService;
using UnityEngine;


[ExecuteInEditMode]
public class GridManager : MonoBehaviour
{
    [SerializeField]
    private Vector2Int mapSize = new Vector2Int(100, 100);

    [SerializeField]
    private List<GameObject> prefabs = new List<GameObject>();

    public static float sqrt3 = Mathf.Sqrt(3);

    private void Awake()
    {
        SceneView.duringSceneGui += OnSceneView;
    }

    private void OnDestroy()
    {
        SceneView.duringSceneGui -= OnSceneView;
    }
    
    private void OnSceneView(SceneView sceneView)
    {
        if (Selection.activeGameObject != this.gameObject)
        {
            return;
        }
    }

    public void GenerateMap()
    {
        for (int x = 0; x < mapSize.x; ++x)
        {
            GameObject parent = new GameObject();
            parent.name = "line" + x.ToString();
            parent.transform.SetParent(this.transform, false);
            parent.transform.localPosition = Vector3.zero;
            for (int y = 0; y < mapSize.y; ++y)
            {
                int prefabTypeIndex = Random.Range(0, prefabs.Count);
                GameObject cell = Instantiate(prefabs[prefabTypeIndex]);
                cell.transform.SetParent(parent.transform, false);
                cell.transform.position = new Vector3(0.75f * x, 0, (x % 2) * sqrt3 * 0.25f + sqrt3 * 0.5f * y);
            }
        }
    }

    public void DestroyMap()
    {
        int childCount = transform.childCount;
        for(int i = childCount - 1; i >= 0; --i)
        {
            DestroyImmediate(transform.GetChild(i).gameObject);
        }
    }
}
