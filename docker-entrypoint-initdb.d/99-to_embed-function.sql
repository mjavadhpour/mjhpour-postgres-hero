create function to_embed(text text, model_name text) returns vector
    language plpython3u
as
$$
from sentence_transformers import SentenceTransformer
import numpy as np 
model = SentenceTransformer(model_name_or_path=model_name, cache_folder="/root/.cache")
return np.array2string(model.encode(text), formatter=None, separator=',')
$$;

alter function to_embed(text, text) owner to postgres;

