create function to_embed(text text) returns vector
    language plpython3u
as
$$
import os
from sentence_transformers import SentenceTransformer
import numpy as np

cache_dir = os.getenv('PG_TRANSFORMERS_CACHE')
model_name = os.getenv('DEFAULT_MODEL')
model = SentenceTransformer(model_name_or_path=model_name, cache_folder=cache_dir)
return np.array2string(model.encode(text), formatter=None, separator=',')
$$;

alter function to_embed(text) owner to postgres;

