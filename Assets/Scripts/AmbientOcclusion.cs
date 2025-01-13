using UnityEngine;

public class AmbientOcclusion : MonoBehaviour
{
    public Shader finalComposite;
    private Material _finalCompositeMat;

    public Shader ambientOcclusionShader;
    private Material _ambientOcclusionMat;

    // Start is called before the first frame update
    void Start()
    {
        GenerateKernel();
    }

    void GenerateKernel()
    {
        int numSamples = 64;
        float[] sampleData = new float[numSamples * 3];
        for (int i = 0; i < numSamples; i++)
        {
            sampleData[i * 3] = Random.Range(-1.0f, 1.0f);
            sampleData[i * 3 + 1] = Random.Range(-1.0f, 1.0f);
            sampleData[i * 3 + 2] = Random.Range(0.0f, 1.0f);
        }
        Shader.SetGlobalFloatArray("_SSAOKernel", sampleData);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (_finalCompositeMat == null)
        {
            _finalCompositeMat = new Material(finalComposite);
        }
        if(_ambientOcclusionMat == null)
        {
            _ambientOcclusionMat = new Material(ambientOcclusionShader);
        }

        //tmp - in final this only needs one channel
        RenderTexture ambientOcclusion = RenderTexture.GetTemporary(dest.width, dest.height, 0, RenderTextureFormat.ARGBHalf);
        _finalCompositeMat.SetTexture("_AmbientOcclusion", ambientOcclusion);
        
        Graphics.Blit(null, ambientOcclusion, _ambientOcclusionMat);
        
        Graphics.Blit(null, dest, _finalCompositeMat);
        
        RenderTexture.ReleaseTemporary(ambientOcclusion);
    }
}
