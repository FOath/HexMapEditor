using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexGridCell : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    void OnDrawGizmos()
    {
        Color oldColor = Gizmos.color;
        Gizmos.color = new Color(1, 0, 0, 0f);
        Gizmos.DrawCube(this.transform.position, new Vector3(1, 1, 1));
        Gizmos.color = oldColor;
    }
}
