using UnityEngine;

public class AmbientOcclusion : MonoBehaviour
{
    public Shader finalComposite;
    private Material _finalCompositeMat;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_finalCompositeMat == null)
        {
            _finalCompositeMat = new Material(finalComposite);
        }
        
        Graphics.Blit(null, dest, _finalCompositeMat);
    }
}
