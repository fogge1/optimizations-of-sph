from setuptools import setup
from Cython.Build import cythonize
import numpy as np

setup(
    name="sph_cython_app",
    ext_modules=cythonize("sph_core.pyx", compiler_directives={'language_level': "3"}),
    include_dirs=[np.get_include()]
)
