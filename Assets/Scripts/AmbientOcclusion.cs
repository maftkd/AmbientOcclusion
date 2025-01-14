using UnityEngine;

public class AmbientOcclusion : MonoBehaviour
{
    public Shader finalComposite;
    private Material _finalCompositeMat;

    public Shader ambientOcclusionShader;
    private Material _ambientOcclusionMat;

    [Range(0, 2)]
    public float radius;
    
    [Range(0, 1f)]
    public float bias;

    // Start is called before the first frame update
    void Start()
    {
        GenerateKernel();
    }

    void GenerateKernel()
    {
        int numSamples = 64;
        Vector4[] samples = new Vector4[numSamples];
        //float[] sampleData = new float[numSamples * 3];
        for (int i = 0; i < numSamples; i++)
        {
            Vector3 sample = new Vector3(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), Random.Range(0f, 1.0f));
            sample = sample.normalized * Random.Range(0, 1f);
            float scale = (float)i / numSamples;
            scale = Mathf.Lerp(0.1f, 1.0f, scale * scale);
            sample *= scale;
            samples[i] = new Vector4(sample.x, sample.y, sample.z, 0);
        }
        Shader.SetGlobalVectorArray("_SSAOKernel", samples);
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
        
        _ambientOcclusionMat.SetFloat("_Radius", radius);
        _ambientOcclusionMat.SetFloat("_Bias", bias);

        //tmp - in final this only needs one channel
        RenderTexture ambientOcclusion = RenderTexture.GetTemporary(dest.width, dest.height, 0, RenderTextureFormat.ARGBHalf);
        _finalCompositeMat.SetTexture("_AmbientOcclusion", ambientOcclusion);
        
        Graphics.Blit(null, ambientOcclusion, _ambientOcclusionMat);
        
        Graphics.Blit(null, dest, _finalCompositeMat);
        
        RenderTexture.ReleaseTemporary(ambientOcclusion);
    }
}
