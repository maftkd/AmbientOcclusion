using UnityEngine;

public class AmbientOcclusion : MonoBehaviour
{
    public Shader finalComposite;
    private Material _finalCompositeMat;

    public Shader ambientOcclusionShader;
    private Material _ambientOcclusionMat;

    public Shader blurShader;
    private Material _blurMat;

    [Range(0, 2)]
    public float radius;
    
    [Range(0, 1f)]
    public float bias;
    
    [Range(0, 8)]
    public int blurRadius;

    // Start is called before the first frame update
    void Start()
    {
        GenerateKernel();
        GenerateRandomRotations();
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
            //sample *= scale;
            samples[i] = new Vector4(sample.x, sample.y, sample.z, 0);
        }
        Shader.SetGlobalVectorArray("_SSAOKernel", samples);
    }
    
    void GenerateRandomRotations()
    {
        int rotationDimensionSize = 4;
        int numRotations = rotationDimensionSize * rotationDimensionSize;
        //Vector4[] rotations = new Vector4[numRotations];
        Texture2D rotations = new Texture2D(rotationDimensionSize, rotationDimensionSize, TextureFormat.RGFloat, false);
        rotations.wrapMode = TextureWrapMode.Repeat;
        
        for (int i = 0; i < numRotations; i++)
        {
            Vector2 rotation = new Vector2(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f));
            rotation.Normalize();
            rotations.SetPixel(i % rotationDimensionSize, i / rotationDimensionSize, new Color(rotation.x, rotation.y, 0, 0));
        }
        rotations.Apply();
        Shader.SetGlobalTexture("_SSAORotations", rotations);
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
        if(_blurMat == null)
        {
            _blurMat = new Material(blurShader);
        }
        
        _ambientOcclusionMat.SetFloat("_Radius", radius);
        _ambientOcclusionMat.SetFloat("_Bias", bias);

        RenderTexture ambientOcclusion = RenderTexture.GetTemporary(dest.width, dest.height, 0, RenderTextureFormat.R8);
        _finalCompositeMat.SetTexture("_AmbientOcclusion", ambientOcclusion);
        Graphics.Blit(null, ambientOcclusion, _ambientOcclusionMat);
        
        RenderTexture blur = RenderTexture.GetTemporary(dest.width, dest.height, 0, RenderTextureFormat.R8);
        
        _blurMat.SetFloat("_Radius", blurRadius);
        Graphics.Blit(ambientOcclusion, blur, _blurMat, 0);
        Graphics.Blit(blur, ambientOcclusion, _blurMat, 1);
        
        Graphics.Blit(null, dest, _finalCompositeMat);
        
        RenderTexture.ReleaseTemporary(blur);
        RenderTexture.ReleaseTemporary(ambientOcclusion);
    }
}
