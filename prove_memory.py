from memory_profiler import profile
import sph_core  
import sph      

@profile
def test_old_python():
    print("run sph.py")
    sph.main(400)

@profile
def test_new_cython():
    print("run cython_sph.py")
    sph_core.run_sph_cython(400)

if __name__ == "__main__":
    test_old_python()
    test_new_cython()
