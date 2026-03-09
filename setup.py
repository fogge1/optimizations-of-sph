from setuptools import setup
from Cython.Build import cythonize
import numpy as np

setup(
    ext_modules=cython%%writefile prove_memory.py
from memory_profiler import profile
import sph_core  
import sph      

@profile
def test_old_python():
    print("Kör gammal Python...")
    sph.main(400)

@profile
def test_new_cython():
    print("Kör ny Cython...")
    sph_core.run_sph_cython(400)

if __name__ == "__main__":
    test_old_python()
    test_new_cython()ize("sph_core.pyx", compiler_directives={'language_level': "3"}),
    include_dirs=[np.get_include()]
)
