using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class Spawn : MonoBehaviour
{
    public int SpawnCount = 100;
    public float Radius = 5.0f;
    public List<GameObject> templates = new List<GameObject>();
    void Start()
    {
        var all = templates.Count;
        if (all == 0) return;
        var index = 0;
        while (index < SpawnCount)
        {
            var i = index % all;
            var t = templates[i];

            // var r = Random.Range(1, Radius);
            // var theta = Random.Range(0, 2 * Mathf.PI);
            //
            // var x = r * Mathf.Cos(theta);
            // var z = r * Mathf.Sin(theta);
            var vec2 = Random.insideUnitCircle * Radius;
            var p = transform.position + new Vector3(vec2.x, 0, vec2.y);
            var go = Instantiate(t, p, Quaternion.identity);
            go.transform.SetParent(transform);
            index++;
        }
    }
}