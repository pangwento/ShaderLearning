using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectionOutlineObject : MonoBehaviour
{
    public static Renderer SelectedObject;
    private Camera _camera;
    private bool _isCameraNotNull;

    // Update is called once per frame
    private void Start()
    {
        _camera = Camera.main;
        _isCameraNotNull = _camera != null;
    }
    
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            if (_isCameraNotNull)
            {
                var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
                var isHit = Physics.Raycast(ray, out var hit) && hit.transform.CompareTag("Selectable");
                if (isHit)
                {
                    SelectedObject = hit.transform.GetComponent<Renderer>();
                }
                else
                {
                    SelectedObject = null;
                }
            }
        }
    }
}
